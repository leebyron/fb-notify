//
//  BubbleView.m
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import "BubbleView.h"
#import "BubbleDimensions.h"

static NSDictionary *attrs = nil;
static NSDictionary *subAttrs = nil;

@implementation BubbleView

+ (void)initialize
{
  attrs = [[NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:11.0],
            NSFontAttributeName, [NSColor colorWithCalibratedWhite:1.0 alpha:0.85],
            NSForegroundColorAttributeName, nil] retain];
  subAttrs = [[NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:10.0],
               NSFontAttributeName, [NSColor colorWithCalibratedWhite:1.0 alpha:0.85],
               NSForegroundColorAttributeName, nil] retain];
}

+ (float)heightOfText:(NSString *)text subText:(NSString *)subText maxWidth:(float)width
{
  NSSize size = [text boundingRectWithSize:NSMakeSize(width, 1.0)
                     options:NSStringDrawingUsesLineFragmentOrigin
                  attributes:attrs].size;

  if (subText && [subText length] > 0) {
    NSSize size2 = [subText boundingRectWithSize:NSMakeSize(width, 1.0)
                                         options:NSStringDrawingTruncatesLastVisibleLine
                                      attributes:subAttrs].size;
    return ceil(size.height + size2.height);
  } else {
    return ceil(size.height);
  }
}

+ (float)widthOfText:(NSString *)text subText:(NSString *)subText maxWidth:(float)width
{
  NSSize size = [text boundingRectWithSize:NSMakeSize(width, 1.0)
                                   options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:attrs].size;

  if (subText && [subText length] > 0) {
    NSSize size2 = [subText boundingRectWithSize:NSMakeSize(width - kBubblePadding, 1.0)
                                         options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                      attributes:subAttrs].size;
    return ceil(MAX(size.width, size2.width + kBubblePadding));
  } else {
    return ceil(size.width);
  }
}

+ (NSSize)totalSizeWithText:(NSString *)text subText:(NSString *)subText withImage:(BOOL)hasImage maxWidth:(float)maxWidth
{
  float textHeight = [self heightOfText:text subText:subText maxWidth:maxWidth];
  float totalHeight;
  if (hasImage) {
    totalHeight = MAX(textHeight, kBubbleIconSize) + 2 * kBubblePadding;
  } else {
    totalHeight = textHeight + 4 * kBubblePadding;
  }

  float textWidth = [self widthOfText:text subText:subText maxWidth:(maxWidth - (hasImage?(kBubbleIconSize + kBubblePadding):0))];
  float totalWidth = textWidth + 4 * kBubblePadding;
  if (hasImage) {
    totalWidth += kBubbleIconSize + kBubblePadding;
  }

  return NSMakeSize(totalWidth, totalHeight);
}

- (id)initWithFrame:(NSRect)frame
              image:(NSImage *)img
               text:(NSString *)aString
            subText:(NSString *)bString
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

  // create shadow
  [NSGraphicsContext saveGraphicsState];
  NSShadow *shadow = [[NSShadow alloc] init];
  [shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.5]];
  [shadow setShadowBlurRadius:kBubbleShadowRadius];
  [shadow setShadowOffset:NSMakeSize(0, -kBubbleShadowOffset)];
  [shadow set];

  // draw background space in order to get a knocked-out shadow
  NSBezierPath *roundedRect = [NSBezierPath bezierPathWithRoundedRect:trueBounds
                                                              xRadius:kBubbleRadius
                                                              yRadius:kBubbleRadius];
  NSBezierPath *knockOut = [NSBezierPath bezierPathWithRect:rect];
  [knockOut appendBezierPath:roundedRect];
  [knockOut setWindingRule:NSEvenOddWindingRule];
  [knockOut addClip];

  [[NSColor blackColor] set];
  [roundedRect fill];

  // remove shadow
  [NSGraphicsContext restoreGraphicsState];
  [shadow release];

  // draw the background for real
  [[NSColor colorWithCalibratedWhite:0.0 alpha:0.75] set];
  [roundedRect fill];

  // draw thin stroke on background
  [[NSColor colorWithCalibratedWhite:0.0 alpha:0.25] set];
  [roundedRect stroke];

  NSRect textRect;
  textRect.origin.x = 2 * kBubblePadding;
  if (image != nil) {
    textRect.origin.x += kBubbleIconSize + kBubblePadding;
  }
  textRect.size.width = trueBounds.size.width - textRect.origin.x;

  // draw white notify text
  float fullHeight = [BubbleView heightOfText:text
                                      subText:subText
                                     maxWidth:textRect.size.width];

  textRect.size.height = [BubbleView heightOfText:text
                                          subText:nil
                                         maxWidth:textRect.size.width];

  textRect.origin.y = (rect.size.height - fullHeight) / 2 + (fullHeight - textRect.size.height);
  textRect.origin.y += 1.0;
  textRect.origin.x += kBubbleShadowSpacing;

  [text drawWithRect:textRect
             options:NSStringDrawingUsesLineFragmentOrigin
          attributes:attrs];

  if (subText && [subText length] > 0) {
    textRect.size.height = [BubbleView heightOfText:nil
                                            subText:subText
                                           maxWidth:textRect.size.width];
    textRect.origin.y -= textRect.size.height + 2;
    [subText drawWithRect:textRect
                  options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
               attributes:subAttrs];
  }

  // draw rounded profile pic
  [NSGraphicsContext saveGraphicsState];
  NSRect imageRect = NSMakeRect(kBubbleShadowSpacing + kBubblePadding,
                                kBubbleShadowSpacing + trueBounds.size.height - kBubblePadding - kBubbleIconSize,
                                kBubbleIconSize,
                                kBubbleIconSize);
  NSBezierPath *imgRoundedRect = [NSBezierPath bezierPathWithRoundedRect:imageRect
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
