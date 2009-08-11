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

@interface ApplicationController : NSObject {
  NSImage *silhouette;

  MenuManager *menu;
  NotificationManager *notifications;

  NSMutableDictionary *profilePics;

  BubbleManager *bubbleManager;
}

@end
