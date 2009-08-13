//
//  BubbleManager.m
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import "BubbleManager.h"
#import "BubbleWindow.h"
#import "BubbleView.h"
#import "BubbleDimensions.h"

@implementation BubbleManager

@synthesize windows;

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

- (void)addBubbleWithText:(NSString *)text
                    image:(NSImage *)image
             notification:(FBNotification *)notif
{
  NSSize windowSize = [BubbleView totalSizeWithText:text withImage:(image != nil) maxWidth:kBubbleMaxWidth];
  float menuBarHeight = [[[NSApplication sharedApplication] menu] menuBarHeight];
  NSSize screen = [[NSScreen mainScreen] frame].size;

  float windowX = screen.width - windowSize.width - kBubbleSpacing;
  float windowY = screen.height - menuBarHeight - windowSize.height - kBubbleSpacing;
  for (BubbleWindow *w in windows) {
    windowY = MIN([w frame].origin.y - windowSize.height - kBubbleSpacing + kBubbleShadowSpacing, windowY);
  }
  NSRect windowRect = NSMakeRect(windowX, windowY, windowSize.width, windowSize.height);

  BubbleWindow *window = [[BubbleWindow alloc] initWithManager:self
                                                         frame:windowRect
                                                         image:image
                                                          text:text
                                                  notification:notif];
  [window appear];
  [windows addObject:window];
  [window release];
}

@end
