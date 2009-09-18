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

  BOOL menuOpen;
  BOOL iconIlluminated;
}

-(id)initWithManager:(MenuManager*)mngr;
-(void)setIconIlluminated:(BOOL)illuminated;

@end
