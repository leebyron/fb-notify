//
//  MenuManager.h
//  Facebook
//
//  Created by Lee Byron on 7/29/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kStartAtLoginOption @"StartAtLogin"

enum {
  START_AT_LOGIN_UNKNOWN,
  START_AT_LOGIN_NO,
  START_AT_LOGIN_YES,
};


@interface MenuManager : NSObject {
  NSImage *userIcon;

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

  NSMutableDictionary *appIcons;
  NSDictionary *profilePics;

  NSStatusItem *statusItem;
  NSMenu *statusItemMenu;

  NSString *userName;
  NSString *profileURL;
}

@property(retain) NSString *userName;
@property(retain) NSString *profileURL;
@property(retain) NSMutableDictionary *appIcons;

- (void)setName:(NSString *)name profileURL:(NSString *)url userPic:(NSImage *)pic;
- (void)setIconByAreUnread:(BOOL)areUnread;
- (void)constructWithNotifications:(NSArray *)notifications messages:(NSArray *)messages isOnline:(BOOL)isOnline;
- (void)setProfilePics:(NSDictionary *)pics;

@end
