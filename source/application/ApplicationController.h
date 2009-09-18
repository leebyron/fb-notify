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
#import "SRCommon.h"
#import "StatusUpdateWindow.h"


@class StatusUpdateWindow;

@interface ApplicationController : NSObject {
  IBOutlet SUUpdater*  updater;

  MenuManager*         menu;
  NotificationManager* notifications;
  MessageManager*      messages;
  BubbleManager*       bubbleManager;
  QueryManager*        queryManager;

  NSMutableDictionary* names;
  ImageDictionary*     profilePics;
  ImageDictionary*     appIcons;

  NSString*            lastStatusUpdate;
  StatusUpdateWindow*  statusUpdateWindow;
}

@property(retain) MenuManager*          menu;
@property(retain) NotificationManager*  notifications;
@property(retain) MessageManager*       messages;
@property(retain) BubbleManager*        bubbleManager;
@property(retain) NSMutableDictionary*  names;
@property(retain) ImageDictionary*      profilePics;
@property(retain) ImageDictionary*      appIcons;

- (void)invalidate;

- (IBAction)menuShowNewsFeed:(id)sender;
- (IBAction)menuShowProfile:(id)sender;
- (IBAction)menuShowInbox:(id)sender;
- (IBAction)menuComposeMessage:(id)sender;
- (IBAction)beginUpdateStatus:(id)sender;
- (IBAction)menuShowNotification:(id)sender;
- (IBAction)menuShowMessage:(id)sender;
- (IBAction)menuShowAllNotifications:(id)sender;
- (IBAction)menuMarkAsReadAllNotifications:(id)sender;
- (IBAction)logout:(id)sender;
- (IBAction)showPreferences:(id)sender;

@end
