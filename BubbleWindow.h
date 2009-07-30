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

@interface BubbleWindow : NSWindow {
  BubbleManager *manager;
  BubbleView *view;
  NSTextField *textField;

  FBNotification *notification;

  CAKeyframeAnimation *moveAnim;
  
  BOOL disappearing;
}

- (id)initWithManager:(BubbleManager *)mngr
                frame:(NSRect)frame
                image:(NSImage *)image
                 text:(NSString *)text
         notification:(FBNotification *)notif;
- (void)appear;
- (void)disappear;
- (void)slideDown:(float)distance;

@end
