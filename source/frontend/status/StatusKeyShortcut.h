//
//  StatusKeyShortcut.h
//  FBDesktopNotifications
//
//  Created by Lee Byron on 8/21/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>


#define kStatusKeyShortcutCode @"StatusUpdateShorcutCode"
#define kStatusKeyShortcutFlags @"StatusUpdateShorcutFlags"


@interface StatusKeyShortcut : NSObject {
  EventHotKeyRef statusKeyRef;
  id target;
  SEL selector;
}

+ (void)setupWithTarget:(id)t selector:(SEL)s;
+ (StatusKeyShortcut*)instance;

- (void)registerKeyShortcutWithCode:(int)code flags:(int)flags;
- (int)keyCode;
- (NSString*)keyCodeString;
- (int)keyFlags;
- (int)keyCarbonFlags;

@end
