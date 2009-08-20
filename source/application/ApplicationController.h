//
//  ApplicationController.h
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Sparkle/Sparkle.h>
#import "BubbleManager.h"
#import "MenuManager.h"
#import "NotificationManager.h"
#import "MessageManager.h"
#import "ImageDictionary.h"
#import "QueryManager.h"

@class StatusUpdateWindow;

@interface ApplicationController : NSObject {
  IBOutlet SUUpdater*  updater;

  MenuManager*         menu;
  NotificationManager* notifications;
  MessageManager*      messages;
  BubbleManager*       bubbleManager;
  QueryManager*        queryManager;

  ImageDictionary*     profilePics;
  ImageDictionary*     appIcons;

  NSString*            lastStatusUpdate;
  StatusUpdateWindow*  statusUpdateWindow;
}

@property(retain) MenuManager*          menu;
@property(retain) NotificationManager*  notifications;
@property(retain) MessageManager*       messages;
@property(retain) BubbleManager*        bubbleManager;
@property(retain) ImageDictionary*      profilePics;
@property(retain) ImageDictionary*      appIcons;


- (void)markNotificationAsRead:(FBNotification*)notification withSimilar:(BOOL)markSimilar;
- (void)markMessageAsRead:(FBMessage*)message;
- (void)updateMenu;

- (IBAction)menuShowNewsFeed:(id)sender;
- (IBAction)menuShowProfile:(id)sender;
- (IBAction)menuShowInbox:(id)sender;
- (IBAction)menuComposeMessage:(id)sender;
- (IBAction)beginUpdateStatus:(id)sender;
- (IBAction)menuShowNotification:(id)sender;
- (IBAction)menuShowMessage:(id)sender;
- (IBAction)menuShowAllNotifications:(id)sender;
- (IBAction)changedStartAtLoginStatus:(id)sender;
- (IBAction)logout:(id)sender;

@end
