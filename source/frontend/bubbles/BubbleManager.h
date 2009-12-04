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
