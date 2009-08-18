//
//  ApplicationController.h
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <FBCocoa/FBCocoa.h>
#import "BubbleManager.h"
#import "MenuManager.h"
#import "NotificationManager.h"
#import "MessageManager.h"
#import "IXSCNotificationManager.h"

@class StatusUpdateWindow;

@interface ApplicationController : NSObject {
  NSImage *silhouette;
  NSImage *userPic;

  MenuManager *menu;
  NotificationManager *notifications;
  MessageManager *messages;

  NSMutableDictionary *profilePics;

  BubbleManager *bubbleManager;
  
  NSTimer *queryTimer;
  
  BOOL hasInitialLoad;
  NSString *lastStatusUpdate;
  StatusUpdateWindow *statusUpdateWindow;

  IXSCNotificationManager *systemConfigNotificationManager;
}

@end
