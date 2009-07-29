//
//  BubbleManager.m
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import "BubbleManager.h"
#import "BubbleWindow.h"
#import "BubbleView.h"

#define kBUBBLE_WIDTH 400.0
#define kSPACING 10.0

@implementation BubbleManager

- (id)init
{
  self = [super init];
  if (self) {
    windows = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)dealloc
{
  [windows release];
  [super dealloc];
}

- (void)addBubbleWithText:(NSString *)text duration:(NSTimeInterval)secs
{
  float windowHeight = [BubbleView totalHeightWithText:text inWidth:kBUBBLE_WIDTH];
  float menuBarHeight = [[[NSApplication sharedApplication] menu] menuBarHeight];
  NSSize screen = [[NSScreen mainScreen] frame].size;
  float windowY = screen.height - menuBarHeight - windowHeight - kSPACING;
  float windowX = screen.width - kBUBBLE_WIDTH - kSPACING;

  NSRect windowRect = NSMakeRect(windowX, windowY, kBUBBLE_WIDTH, windowHeight);
  BubbleWindow *window = [[BubbleWindow alloc] initWithFrame:windowRect
                                                        text:text];

  for (BubbleWindow *w in windows) {
    [w slideDown:windowHeight + kSPACING];
  }

  [window appear];
  [windows addObject:window];
  [self performSelector:@selector(killWindow:)
             withObject:window
             afterDelay:secs];
//  [window release];
}

- (void)killWindow:(BubbleWindow *)window
{
  [window disappear];
  [windows removeObject:window];
}

@end
