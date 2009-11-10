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
  BubbleView* view;
  id windowAction;
  BOOL disappearing;
}

- (id)initWithFrame:(NSRect)frame
              image:(NSImage*)image
               text:(NSString*)text
            subText:(NSString*)subText
             action:(id)action;

- (void)appear;
- (void)disappear;

@end
