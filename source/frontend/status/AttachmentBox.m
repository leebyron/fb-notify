//
//  AttachmentBox.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 11/7/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "AttachmentBox.h"
#import "NSBezierPath+.h"

#define kAttachmentWellRadius 3

@implementation AttachmentBox

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.boxType = NSBoxCustom;
    self.borderWidth = 0;
    self.contentViewMargins = NSZeroSize;
  }
  return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
  NSBezierPath* edge = [NSBezierPath bezierPathWithRoundedRect:[self bounds]
                                                       xRadius:kAttachmentWellRadius
                                                       yRadius:kAttachmentWellRadius];

  [[NSColor colorWithCalibratedWhite:0.0 alpha:0.05] set];
  [edge fill];

  NSShadow* innerShadow = [[NSShadow alloc] init];
  innerShadow.shadowOffset = NSMakeSize(0.0, -1.0);
  innerShadow.shadowBlurRadius = 3.0;
  innerShadow.shadowColor = [NSColor colorWithCalibratedWhite:0.0 alpha:0.2];
  [edge fillWithInnerShadow:innerShadow];
  [innerShadow release];
}

@end
