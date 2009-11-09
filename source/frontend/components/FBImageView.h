//
//  FBImageView.h
//  FBDesktopNotifications
//
//  Created by Lee Byron on 11/9/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FBImageView : NSControl {
  NSImage* image;
  NSColor* backgroundColor;
  NSImageScaling imageScaling;
  NSArray* acceptedPBoardTypes;
}

@property(retain) NSImage* image;
@property(copy) NSColor* backgroundColor;
@property NSImageScaling imageScaling;

@end
