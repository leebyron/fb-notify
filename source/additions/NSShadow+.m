//
//  NSShadow+.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 12/3/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "NSShadow+.h"


@implementation NSShadow (Additions)

- (id)initWithColor:(NSColor *)color offset:(NSSize)offset blurRadius:(CGFloat)blur
{
  if (self = [self init]) {
    self.shadowColor = color;
    self.shadowOffset = offset;
    self.shadowBlurRadius = blur;
  }  
  return self;
}

@end
