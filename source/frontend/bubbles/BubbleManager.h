//
//  BubbleManager.h
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FBNotification.h"
#import "FBMessage.h"

@interface BubbleManager : NSObject {
  NSMutableArray* windows;
}

@property(retain) NSMutableArray* windows;

- (void)addBubbleWithText:(NSString *)text
                  subText:(NSString *)subText
                    image:(NSImage *)image
             notification:(FBNotification *)notif
                  message:(FBMessage *)msg;

@end
