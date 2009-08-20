//
//  MenuManager.h
//  Facebook
//
//  Created by Lee Byron on 7/29/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ImageDictionary.h"

#define kStartAtLoginOption @"StartAtLogin"
#define kStartAtLoginOptionPath @"StartAtLoginPath"

enum {
  START_AT_LOGIN_UNKNOWN,
  START_AT_LOGIN_NO,
  START_AT_LOGIN_YES,
};


@interface MenuManager : NSObject {
  NSImage *fbActiveIcon;
  NSImage *fbEmptyIcon;
  NSImage *fbFullIcon;

  NSImage *newsFeedIcon;
  NSImage *profileIcon;
  NSImage *notificationsIcon;
  NSImage *messageIcon;
  NSImage *inboxIcon;

  NSImage *notificationsGhostIcon;
  NSImage *inboxGhostIcon;

  ImageDictionary *profilePics;
  ImageDictionary *appIcons;

  NSStatusItem *statusItem;
  NSMenu *statusItemMenu;

  NSString *userName;
  NSString *profileURL;
}

@property(retain) NSString *userName;
@property(retain) NSString *profileURL;
@property(retain) ImageDictionary *profilePics;
@property(retain) ImageDictionary *appIcons;

- (void)setIconByAreUnread:(BOOL)areUnread;
- (void)constructWithNotifications:(NSArray *)notifications messages:(NSArray *)messages;

@end
