//
//  BubbleView.m
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import "BubbleView.h"

#define kBUBBLE_PADDING 5.0
#define kBUBBLE_RADIUS 5.0
#define kPIC_RADIUS 3.0
#define kBUBBLE_ICON_SIZE 32.0

static NSDictionary *attrs = nil;

@implementation BubbleView

+ (void)initialize
{
  attrs = [[NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:11.0],
            NSFontAttributeName, [NSColor whiteColor],
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
    totalHeight = MAX(textHeight, kBUBBLE_ICON_SIZE) + 2 * kBUBBLE_PADDING;
  } else {
    totalHeight = textHeight + 4 * kBUBBLE_PADDING;
  }
  
  float textWidth = [self widthOfText:text maxWidth:(maxWidth - (hasImage?(kBUBBLE_ICON_SIZE + kBUBBLE_PADDING):0))];
  float totalWidth = textWidth + 4 * kBUBBLE_PADDING;  
  if (hasImage) {
    totalWidth += kBUBBLE_ICON_SIZE + kBUBBLE_PADDING;
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
  // draw background space
  [[NSColor clearColor] set];
  NSRectFill([self bounds]);
  NSBezierPath *roundedRect = [NSBezierPath bezierPathWithRoundedRect:[self bounds]
                                                              xRadius:kBUBBLE_RADIUS
                                                              yRadius:kBUBBLE_RADIUS];
  [[NSColor colorWithCalibratedWhite:0.0 alpha:0.8] set];
  [roundedRect fill];
  
  // draw white notify text
  NSRect textRect;
  textRect.origin.x = 2 * kBUBBLE_PADDING;
  if (image != nil) {
    textRect.origin.x += kBUBBLE_ICON_SIZE + kBUBBLE_PADDING;
  }
  textRect.size.width = [self bounds].size.width - textRect.origin.x;
  textRect.size.height = [BubbleView heightOfText:text
                                         maxWidth:textRect.size.width];
  
  if (textRect.size.height < kBUBBLE_ICON_SIZE) {
    textRect.origin.y = ([self bounds].size.height - textRect.size.height) / 2;
  } else {
    textRect.origin.y = [self bounds].size.height - textRect.size.height;
  }
  textRect.origin.y += 1.0;

  [[NSColor whiteColor] set];
  [text drawInRect:textRect withAttributes:attrs];
  
  // draw rounded profile pic
  [NSGraphicsContext saveGraphicsState];
  NSRect imageRect = NSMakeRect(kBUBBLE_PADDING,
                                [self bounds].size.height - kBUBBLE_PADDING - kBUBBLE_ICON_SIZE,
                                kBUBBLE_ICON_SIZE,
                                kBUBBLE_ICON_SIZE);
  NSBezierPath *imgRoundedRect = [NSBezierPath bezierPathWithRoundedRect:imageRect
                                                                 xRadius:kPIC_RADIUS
                                                                 yRadius:kPIC_RADIUS];
  [imgRoundedRect addClip];
  [image drawInRect:imageRect
           fromRect:NSZeroRect
          operation:NSCompositeSourceOver
           fraction:1.0];
  [NSGraphicsContext restoreGraphicsState];
}

@end
