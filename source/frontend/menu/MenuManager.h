//
//  MenuManager.h
//  Facebook
//
//  Created by Lee Byron on 7/29/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ImageDictionary.h"
#import "HashArray.h"


@class MenuIcon;

@interface MenuManager : NSObject {
  MenuIcon* fbMenuIcon;

  NSImage* newsFeedIcon;
  NSImage* profileIcon;
  NSImage* notifsIcon;
  NSImage* messageIcon;
  NSImage* inboxIcon;

  NSImage* notifsGhostIcon;
  NSImage* inboxGhostIcon;

  ImageDictionary* profilePics;
  ImageDictionary* appIcons;

  NSStatusItem* statusItem;
  NSMenu*       statusItemMenu;

  NSString* userName;
  NSString* profileURL;
}

@property(retain) NSStatusItem* statusItem;
@property(retain) NSString* userName;
@property(retain) NSString* profileURL;
@property(retain) ImageDictionary* profilePics;
@property(retain) ImageDictionary* appIcons;

- (void)setIconIlluminated:(BOOL)illuminated;
- (void)constructWithNotifications:(HashArray*)notifications
                          messages:(HashArray*)messages;
- (void)openMenu;

@end
