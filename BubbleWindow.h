//
//  BubbleWindow.h
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "BubbleView.h"

@interface BubbleWindow : NSWindow {
  BubbleView *view;
  NSTextField *textField;

  CAKeyframeAnimation *moveAnim;
}

- (id)initWithFrame:(NSRect)frame text:(NSString *)text;
- (id)initWithFrame:(NSRect)frame text:(NSString *)text image:(NSURL *)url;
- (void)appear;
- (void)disappear;
- (void)slideDown:(float)distance;

@end
