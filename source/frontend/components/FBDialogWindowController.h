//
//  FBDialogWindowController.h
//  FBDesktopNotifications
//
//  Created by Lee Byron on 11/4/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface FBDialogWindowController : NSWindowController {
  BOOL trackingChange;
  BOOL isOpen;
  BOOL isClosed;
  BOOL isClosing;
  BOOL isReleased;
  
  NSPoint location;
  NSUInteger screenNum;

  NSView* mainView;
  NSText* editor;  
}

@property BOOL isClosed;
@property BOOL isClosing;

@property NSPoint location;
@property NSUInteger screenNum;

@property(retain) NSText* editor;

- (id)initWithLocation:(NSPoint)aLocation
             screenNum:(NSUInteger)aScreenNum;

- (void)addSubview:(NSView*)view;
- (void)sizeToFit;

- (void)close;

@end
