//
//  BubbleManager.h
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>
#import "FBNotification.h"
#import "FBMessage.h"

#define kUseGrowlOption @"UseGrowl"

enum {
  GROWL_UNKNOWN     = 0,
  GROWL_USE         = 1,
  GROWL_DO_NOT_USE  = 2
};


@interface BubbleManager : NSObject <GrowlApplicationBridgeDelegate> {
  NSMutableArray* windows;
  NSMutableDictionary* pendingGrowls;
}

@property(retain) NSMutableArray* windows;

+ (BubbleManager*)manager;

- (BOOL)useGrowl;

- (void)addBubbleWithText:(NSString *)text
                  subText:(NSString *)subText
                    image:(NSImage *)image
                   action:(id)action;

- (void)executeAction:(id)action;

@end
