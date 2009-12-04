//
//  BubbleView.m
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import "BubbleView.h"
#import "BubbleDimensions.h"
#import "FBPreferenceManager.h"
#import "NSString+.h"


static NSDictionary* attrs = nil;
static NSDictionary* subAttrs = nil;

@implementation BubbleView

+ (void)initialize
{
  NSMutableParagraphStyle *paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
  [paraStyle setTighteningFactorForTruncation:0.0];
  [paraStyle setLineBreakMode:NSLineBreakByWordWrapping];
  attrs = [[NSDictionary dictionaryWithObjectsAndKeys:[NSFont labelFontOfSize:12.0],
            NSFontAttributeName, [NSColor colorWithCalibratedWhite:1.0 alpha:0.8],
            NSForegroundColorAttributeName, paraStyle, NSParagraphStyleAttributeName, nil] retain];
  subAttrs = [[NSDictionary dictionaryWithObjectsAndKeys:[NSFont labelFontOfSize:10.0],
               NSFontAttributeName, [NSColor colorWithCalibratedWhite:1.0 alpha:0.8],
               NSForegroundColorAttributeName, paraStyle, NSParagraphStyleAttributeName, nil] retain];
}

+ (float)heightOfText:(NSString*)text subText:(NSString*)subText maxWidth:(float)width
{
  NSSize size = [text boundingRectWithSize:NSMakeSize(width, 0.0)
                     options:NSStringDrawingUsesLineFragmentOrigin
                  attributes:attrs].size;

  if ([NSString exists:subText]) {
    NSSize size2 = [subText boundingRectWithSize:NSMakeSize(width, 26.0)
                                         options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading
                                      attributes:subAttrs].size;
    return ceil(size.height + MIN(26.0, size2.height));
  } else {
    return ceil(size.height);
  }
}

+ (float)widthOfText:(NSString*)text subText:(NSString*)subText maxWidth:(float)width
{
  NSSize size = [text boundingRectWithSize:NSMakeSize(width, 0.0)
                                   options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:attrs].size;

  if ([NSString exists:subText]) {
    NSSize size2 = [subText boundingRectWithSize:NSMakeSize(width, 26.0)
                                         options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading
                                      attributes:subAttrs].size;
    return ceil(MAX(size.width, size2.width));
  } else {
    return ceil(size.width);
  }
}

+ (NSSize)totalSizeWithText:(NSString*)text subText:(NSString*)subText withImage:(BOOL)hasImage maxWidth:(float)maxWidth
{
  float maxTextWidth = maxWidth - 4 * kBubblePadding;
  if (hasImage) {
    maxTextWidth - kBubbleIconSize + kBubblePadding;
  }

  float textHeight = [self heightOfText:text subText:subText maxWidth:maxTextWidth];
  float textWidth = [self widthOfText:text subText:subText maxWidth:maxTextWidth];

  float totalWidth = textWidth + 4 * kBubblePadding;
  float totalHeight;
  if (hasImage) {
    totalHeight = MAX(textHeight, kBubbleIconSize) + 2 * kBubblePadding;
    totalWidth += kBubbleIconSize + kBubblePadding;
  } else {
    totalHeight = textHeight + 4 * kBubblePadding;
  }

  return NSMakeSize(totalWidth, totalHeight);
}

- (id)initWithFrame:(NSRect)frame
              image:(NSImage*)img
               text:(NSString*)aString
            subText:(NSString*)bString
{
  self = [super initWithFrame:frame];
  if (self) {
    text    = [aString retain];
    subText = [bString retain];
    image   = [img retain];
  }
  return self;
}

- (void)dealloc
{
  [text release];
  [subText release];
  if (image != nil) {
    [image release];
  }
  [super dealloc];
}

- (void)drawRect:(NSRect)rect {

  // true bounds
  NSRect trueBounds = NSMakeRect(rect.origin.x + kBubbleShadowSpacing,
                                 rect.origin.y + kBubbleShadowSpacing,
                                 rect.size.width - 2.0 * kBubbleShadowSpacing,
                                 rect.size.height - 2.0 * kBubbleShadowSpacing);

  // clear everything
  [[NSColor clearColor] set];
  NSRectFill(rect);

  // light mode?
  BOOL lightMode = [[FBPreferenceManager manager] boolForKey:kBubbleLightMode];

  // create shadow
  [NSGraphicsContext saveGraphicsState];
  NSShadow* shadow = [[NSShadow alloc] init];
  [shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.5]];
  [shadow setShadowBlurRadius:kBubbleShadowRadius];
  [shadow setShadowOffset:NSMakeSize(0, -kBubbleShadowOffset)];
  [shadow set];

  // draw background space in order to get a knocked-out shadow
  NSBezierPath* roundedRect = [NSBezierPath bezierPathWithRoundedRect:trueBounds
                                                              xRadius:kBubbleRadius
                                                              yRadius:kBubbleRadius];
  NSBezierPath* knockOut = [NSBezierPath bezierPathWithRect:rect];
  [knockOut appendBezierPath:roundedRect];
  [knockOut setWindingRule:NSEvenOddWindingRule];
  [knockOut addClip];

  [[NSColor blackColor] set];
  [roundedRect fill];

  // remove shadow
  [NSGraphicsContext restoreGraphicsState];
  [shadow release];

  // draw an edge shadow in light mode
  if (lightMode) {
    NSRect edgeBounds = NSMakeRect(trueBounds.origin.x - 0.5,
                                   trueBounds.origin.y - 0.5,
                                   trueBounds.size.width + 1.0,
                                   trueBounds.size.height + 1.0);
    NSBezierPath* edgeRect = [NSBezierPath bezierPathWithRoundedRect:edgeBounds
                                                             xRadius:kBubbleRadius
                                                             yRadius:kBubbleRadius];
    [[NSColor colorWithCalibratedWhite:0.0 alpha:0.1] set];
    [edgeRect stroke];
  }

  // draw the background for real
  if (lightMode) {
    [[NSColor colorWithCalibratedWhite:1.0 alpha:0.9] set];
  } else {
    [[NSColor colorWithCalibratedWhite:0.0 alpha:0.7] set];
  }
  [roundedRect fill];

  // draw inner stroke for dark mode
  if (!lightMode) {
    NSRect strokeBounds = NSMakeRect(trueBounds.origin.x + 0.5,
                                     trueBounds.origin.y + 0.5,
                                     trueBounds.size.width - 1.0,
                                     trueBounds.size.height - 1.0);
    NSBezierPath* strokeRect = [NSBezierPath bezierPathWithRoundedRect:strokeBounds
                                                               xRadius:kBubbleRadius
                                                               yRadius:kBubbleRadius];
    [[NSColor colorWithCalibratedWhite:0.0 alpha:0.25] set];
    [strokeRect stroke];
  }

  // text rect
  NSRect textRect;
  textRect.origin.x = 2 * kBubblePadding;
  if (image != nil) {
    textRect.origin.x += kBubbleIconSize + kBubblePadding;
  }
  textRect.size.width = trueBounds.size.width - textRect.origin.x - 2 * kBubblePadding;

  // draw white notify text
  float fullHeight = [BubbleView heightOfText:text
                                      subText:subText
                                     maxWidth:textRect.size.width];

  textRect.size.height = [BubbleView heightOfText:text
                                          subText:nil
                                         maxWidth:textRect.size.width];

  textRect.origin.y = (rect.size.height - fullHeight) / 2 + (fullHeight - textRect.size.height);
  textRect.origin.y += [NSString exists:subText] ? 2.0 : 1.0;
  textRect.origin.x += kBubbleShadowSpacing;

  NSMutableDictionary* textAttrs = [NSMutableDictionary dictionaryWithDictionary:attrs];
  NSMutableDictionary* subTextAttrs = [NSMutableDictionary dictionaryWithDictionary:subAttrs];
  if (lightMode) {
    [textAttrs setObject:[NSColor colorWithCalibratedWhite:0.0 alpha:1.0]
                  forKey:NSForegroundColorAttributeName];
    [subTextAttrs setObject:[NSColor colorWithCalibratedWhite:0.0 alpha:1.0]
                     forKey:NSForegroundColorAttributeName];
  }

  [text drawWithRect:textRect
             options:NSStringDrawingUsesLineFragmentOrigin
          attributes:textAttrs];

  if ([NSString exists:subText]) {
    textRect.size.height = [BubbleView heightOfText:nil
                                            subText:subText
                                           maxWidth:textRect.size.width];
    textRect.origin.y -= textRect.size.height + 2;
    [subText drawWithRect:textRect
                  options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine
               attributes:subTextAttrs];
  }

  // draw rounded profile pic
  [NSGraphicsContext saveGraphicsState];
  NSRect imageRect = NSMakeRect(kBubbleShadowSpacing + kBubblePadding,
                                kBubbleShadowSpacing + trueBounds.size.height - kBubblePadding - kBubbleIconSize,
                                kBubbleIconSize,
                                kBubbleIconSize);
  NSBezierPath* imgRoundedRect = [NSBezierPath bezierPathWithRoundedRect:imageRect
                                                                 xRadius:kPicRadius
                                                                 yRadius:kPicRadius];
  [imgRoundedRect addClip];
  [image drawInRect:imageRect
           fromRect:NSZeroRect
          operation:NSCompositeSourceOver
           fraction:1.0];
  [NSGraphicsContext restoreGraphicsState];
}

@end
