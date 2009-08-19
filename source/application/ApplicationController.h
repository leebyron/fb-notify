//
//  ApplicationController.h
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <FBCocoa/FBCocoa.h>
#import <Sparkle/Sparkle.h>
#import "BubbleManager.h"
#import "MenuManager.h"
#import "NotificationManager.h"
#import "MessageManager.h"
#import "IXSCNotificationManager.h"

@class StatusUpdateWindow;

@interface ApplicationController : NSObject {
  IBOutlet SUUpdater *updater;

  NSImage *silhouette;
  NSImage *userPic;

  MenuManager *menu;
  NotificationManager *notifications;
  MessageManager *messages;

  NSMutableDictionary *profilePics;
  NSMutableDictionary *profileURLs;

  BubbleManager *bubbleManager;
  
  NSTimer *queryTimer;
  
  NSTimeInterval lastQuery;
  NSString *lastStatusUpdate;
  StatusUpdateWindow *statusUpdateWindow;

  IXSCNotificationManager *systemConfigNotificationManager;
  BOOL isOnline;
}

@end
