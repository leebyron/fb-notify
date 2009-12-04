//
//  FBButton.h
//  FBDesktopNotifications
//
//  Created by Lee Byron on 11/9/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FBButton : NSButton {
  NSUInteger padding;
  NSUInteger minWidth;
  BOOL isChromeless;
  BOOL isHovering;
  NSTrackingRectTag trackingRect;
}

@property NSUInteger padding;
@property NSUInteger minWidth;
@property BOOL isChromeless;
@property(readonly) BOOL isHovering;

- (void)setTextColor:(NSColor*)aColor;

@end
