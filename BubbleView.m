//
//  BubbleView.m
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import "BubbleView.h"
#import "BubbleDimensions.h"

static NSDictionary *attrs = nil;

@implementation BubbleView

+ (void)initialize
{
  attrs = [[NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:11.0],
            NSFontAttributeName, [NSColor colorWithCalibratedWhite:1.0 alpha:0.85],
            NSForegroundColorAttributeName, nil] retain];
}

+ (float)heightOfText:(NSString *)text maxWidth:(float)width
{
  NSSize size = [text boundingRectWithSize:NSMakeSize(width, 1.0)
                     options:NSStringDrawingUsesLineFragmentOrigin
                  attributes:attrs].size;
  return ceil(size.height);
}

+ (float)widthOfText:(NSString *)text maxWidth:(float)width
{
  NSSize size = [text boundingRectWithSize:NSMakeSize(width, 1.0)
                                   options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:attrs].size;
  return ceil(size.width);
}

+ (NSSize)totalSizeWithText:(NSString *)text withImage:(BOOL)hasImage maxWidth:(float)maxWidth
{
  float textHeight = [self heightOfText:text maxWidth:maxWidth];
  float totalHeight;
  if (hasImage) {
    totalHeight = MAX(textHeight, kBubbleIconSize) + 2 * kBubblePadding;
  } else {
    totalHeight = textHeight + 4 * kBubblePadding;
  }

  float textWidth = [self widthOfText:text maxWidth:(maxWidth - (hasImage?(kBubbleIconSize + kBubblePadding):0))];
  float totalWidth = textWidth + 4 * kBubblePadding;
  if (hasImage) {
    totalWidth += kBubbleIconSize + kBubblePadding;
  }

  return NSMakeSize(totalWidth, totalHeight);
}

- (id)initWithFrame:(NSRect)frame
              image:(NSImage *)img
               text:(NSString *)aString
{
  self = [super initWithFrame:frame];
  if (self) {
    text = [aString retain];
    image = [img retain];
  }
  return self;
}

- (void)dealloc
{
  [text release];
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
  [shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.6]];
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
  [[NSColor colorWithCalibratedWhite:0.0 alpha:0.3] set];
  [roundedRect stroke];

  // draw white notify text
  NSRect textRect;
  textRect.origin.x = 2 * kBubblePadding;
  if (image != nil) {
    textRect.origin.x += kBubbleIconSize + kBubblePadding;
  }
  textRect.size.width = trueBounds.size.width - textRect.origin.x;
  textRect.size.height = [BubbleView heightOfText:text
                                         maxWidth:textRect.size.width];

  if (textRect.size.height < kBubbleIconSize) {
    textRect.origin.y = ([self bounds].size.height - textRect.size.height) / 2;
  } else {
    textRect.origin.y = [self bounds].size.height - textRect.size.height;
  }
  textRect.origin.y += 1.0;
  textRect.origin.x += kBubbleShadowSpacing;

  [text drawInRect:textRect withAttributes:attrs];

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
