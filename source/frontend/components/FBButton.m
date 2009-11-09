//
//  FBButton.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 11/9/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "FBButton.h"


@implementation FBButton

@synthesize padding, minWidth;

- (id)initWithFrame:(NSRect)frameRect
{
  if (self = [super initWithFrame:frameRect]) {
    self.padding = 8;
    self.minWidth = 60;
  }
  return self;
}

- (void)setTitle:(NSString*)aTitle
{
  [super setTitle:aTitle];
  
  NSSize labelSize = [aTitle sizeWithAttributes:[NSDictionary dictionaryWithObject:self.font
                                                                            forKey:NSFontAttributeName]];
  labelSize.height = self.frame.size.height;
  labelSize.width += padding * 2;
  labelSize.width = MAX(minWidth, labelSize.width);
  [self setFrameSize:labelSize];
}

@end
