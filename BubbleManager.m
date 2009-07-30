//
//  BubbleManager.m
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import "BubbleManager.h"
#import "BubbleWindow.h"
#import "BubbleView.h"

#define kBUBBLE_MAX_WIDTH 400.0
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

- (void)addBubbleWithText:(NSString *)text
                    image:(NSImage *)image
                 duration:(NSTimeInterval)secs
{
  NSSize windowSize = [BubbleView totalSizeWithText:text withImage:(image != nil) maxWidth:kBUBBLE_MAX_WIDTH];  
  float menuBarHeight = [[[NSApplication sharedApplication] menu] menuBarHeight];
  NSSize screen = [[NSScreen mainScreen] frame].size;
  
  float windowX = screen.width - windowSize.width - kSPACING;
  float windowY = screen.height - menuBarHeight - windowSize.height - kSPACING;
  for (BubbleWindow *w in windows) {
    windowY = MIN([w frame].origin.y - windowSize.height - kSPACING, windowY);
  }
  NSRect windowRect = NSMakeRect(windowX, windowY, windowSize.width, windowSize.height);

  BubbleWindow *window = [[BubbleWindow alloc] initWithFrame:windowRect
                                                       image:image
                                                        text:text];
  [window appear];
  [windows addObject:window];
  [self performSelector:@selector(killWindow:)
             withObject:window
             afterDelay:secs];
  [window release];
}

- (void)killWindow:(BubbleWindow *)window
{
  [window disappear];
  [windows removeObject:window];
}

@end
