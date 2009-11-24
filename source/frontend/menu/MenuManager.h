//
//  MenuManager.h
//  Facebook
//
//  Created by Lee Byron on 7/29/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ImageDictionary.h"
#import "NotificationManager.h"
#import "MessageManager.h"


typedef enum {
  FBJewelStatusOffline,
  FBJewelStatusNotLoggedIn,
  FBJewelStatusConnecting,
  FBJewelStatusEmpty,
  FBJewelStatusUnread,
  FBJewelStatusUnseen,
} FBJewelStatus;


@class MenuIcon;

@interface MenuManager : NSObject {
  MenuIcon* icon;

  FBJewelStatus status;

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

@property(readonly) MenuIcon* icon;
@property(assign) FBJewelStatus status;
@property(retain) NSStatusItem* statusItem;
@property(retain) NSString* userName;
@property(retain) NSString* profileURL;
@property(retain) ImageDictionary* profilePics;
@property(retain) ImageDictionary* appIcons;

+ (MenuManager*)manager;

- (void)constructWithNotifications:(NotificationManager*)notifications
                          messages:(MessageManager*)messages;
- (void)openMenu;

@end
