//
//  MenuIcon.h
//  FBDesktopNotifications
//
//  Created by Lee Byron on 9/17/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MenuManager.h"


@interface MenuIcon : NSView {
  MenuManager* manager;

  NSImage* fbActiveIcon;
  NSImage* fbEmptyIcon;
  NSImage* fbFullIcon;
  NSImage* fbOfflineIcon;
  NSImage* fbShareIcon1;
  NSImage* fbShareIcon2;
  NSImage* fbShareIcon3;
  NSImage* fbShareIcon4;

  BOOL menuOpen;
  int iconStatus;
  BOOL animateUp;
}

- (id)initWithManager:(MenuManager*)mngr;

@end
