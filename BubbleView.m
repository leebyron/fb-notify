//
//  BubbleView.m
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import "BubbleView.h"

#define kBUBBLE_PADDING 6.0
#define kBUBBLE_ICON_SIZE 32.0

static NSDictionary *attrs = nil;

@implementation BubbleView

+ (void)initialize
{
  attrs = [[NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:11.0],
            NSFontAttributeName, [NSColor whiteColor],
            NSForegroundColorAttributeName, nil] retain];
}

+ (float)heightOfText:(NSString *)text inWidth:(float)width
{
  return [text boundingRectWithSize:NSMakeSize(width, 1.0)
                            options:NSStringDrawingUsesLineFragmentOrigin
                         attributes:attrs].size.height;
}

+ (float)totalHeightWithText:(NSString *)text inWidth:(float)width
{
  float textHeight = [self heightOfText:text inWidth:width];
  return (textHeight < kBUBBLE_ICON_SIZE + 2 * kBUBBLE_PADDING
          ? kBUBBLE_ICON_SIZE + 2 * kBUBBLE_PADDING
          : textHeight);
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
  [image release];
  [super dealloc];
}

- (void)drawRect:(NSRect)rect {
  [[NSColor clearColor] set];
  NSRectFill([self bounds]);

  NSBezierPath *roundedRect = [NSBezierPath bezierPathWithRoundedRect:[self bounds]
                                                              xRadius:kBUBBLE_PADDING
                                                              yRadius:kBUBBLE_PADDING];
  [[NSColor colorWithCalibratedWhite:0.0 alpha:0.8] set];
  [roundedRect fill];

  NSRect imageRect = NSMakeRect(kBUBBLE_PADDING,
                                [self bounds].size.height - kBUBBLE_PADDING
                                  - kBUBBLE_ICON_SIZE,
                                kBUBBLE_ICON_SIZE, kBUBBLE_ICON_SIZE);
  [image drawInRect:imageRect
           fromRect:NSZeroRect
          operation:NSCompositeSourceOver
           fraction:1.0];

  [[NSColor whiteColor] set];
  NSRect textRect;
  textRect.origin.x = kBUBBLE_PADDING + kBUBBLE_ICON_SIZE + kBUBBLE_PADDING;
  textRect.size.width = [self bounds].size.width - textRect.origin.x;
  textRect.size.height = [BubbleView heightOfText:text
                                          inWidth:textRect.size.width];
  if (textRect.size.height < kBUBBLE_ICON_SIZE) {
    textRect.origin.y = ([self bounds].size.height - textRect.size.height) / 2;
  } else {
    textRect.origin.y = [self bounds].size.height - textRect.size.height;
  }
  textRect.origin.y += 2.0;

  [text drawInRect:textRect withAttributes:attrs];
}

@end
