//
//  ApplicationController.h
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <FBCocoa/FBCocoa.h>
#import "BubbleManager.h"

@interface ApplicationController : NSObject {
  NSImage *silhouette;

  FBSession *fbSession;
  NSString *userName;
  NSString *profileURL;

  NSMenu *statusItemMenu;
  NSStatusItem *statusItem;
  NSMutableArray *notificationMenuItems;

  NSMutableDictionary *profilePics;

  BubbleManager *bubbleManager;
}

@property(retain) NSString *userName;
@property(retain) NSString *profileURL;

@end
