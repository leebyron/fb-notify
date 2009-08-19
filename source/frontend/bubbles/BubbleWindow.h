//
//  BubbleWindow.h
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "BubbleView.h"
#import "BubbleManager.h"
#import "FBNotification.h"
#import "FBMessage.h"

@interface BubbleWindow : NSWindow {
  BubbleManager *manager;
  BubbleView *view;
  FBNotification *notification;
  FBMessage *message;
  BOOL disappearing;
}

- (id)initWithManager:(BubbleManager *)mngr
                frame:(NSRect)frame
                image:(NSImage *)image
                 text:(NSString *)text
              subText:(NSString *)subText
         notification:(FBNotification *)notif
              message:(FBMessage *)msg;
- (void)appear;
- (void)disappear;

@end
