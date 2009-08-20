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
#import "ImageDictionary.h"

@class StatusUpdateWindow;

@interface ApplicationController : NSObject {
  IBOutlet SUUpdater *updater;

  MenuManager *menu;
  NotificationManager *notifications;
  MessageManager *messages;

  ImageDictionary *profilePics;
  ImageDictionary *appIcons;

  BubbleManager *bubbleManager;

  NSTimer *queryTimer;

  NSTimeInterval lastQuery;
  NSString *lastStatusUpdate;
  StatusUpdateWindow *statusUpdateWindow;
}

@end
