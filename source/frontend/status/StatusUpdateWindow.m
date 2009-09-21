//
//  StatusUpdateWindow.m
//  Facebook
//
//  Created by Lee Byron on 8/13/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "StatusUpdateWindow.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+.h"

#define kAnimationDuration 0.1
#define kAnimationDurationOut 0.2
#define kSlideDistance 10


@implementation StatusUpdateWindow

- (id)initWithTarget:(id)obj selector:(SEL)sel
{
  self = [super initWithWindowNibName:@"status"];
  if (self) {
    target       = obj;
    selector     = sel;
    isClosed     = NO;
    disappearing = NO;

    // Force the window to be loaded
    [[self window] setLevel:NSFloatingWindowLevel];
    [[self window] display];
  }

  return self;
}

- (void)windowDidLoad
{
  // set up fade in/out animation
  CAAnimation *fadeAni = [CABasicAnimation animation];
  [fadeAni setDelegate:self];
  [fadeAni setDuration:kAnimationDuration];

  // set up drop-in animation
  CAKeyframeAnimation *moveAni = [CAKeyframeAnimation animation];
  [moveAni setDuration:kAnimationDuration];
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathMoveToPoint(path, NULL, [[self window] frame].origin.x, [[self window] frame].origin.y - kSlideDistance);
  CGPathAddLineToPoint(path, NULL, [[self window] frame].origin.x, [[self window] frame].origin.y);
  [moveAni setPath:path];
  CGPathRelease(path);

  // assign animations
  [[self window] setAnimations:[NSDictionary dictionaryWithObjectsAndKeys:fadeAni, @"alphaValue",
                                moveAni, @"frameOrigin", nil]];

  // open er up.
  [NSApp activateIgnoringOtherApps:YES];
  [[self window] setAlphaValue:0.0];
  [[self window] makeKeyAndOrderFront:self];
  [[[self window] animator] setAlphaValue:1.0];
  [[[self window] animator] setFrameOrigin:[[self window] frame].origin];
}

- (IBAction)cancel:(id)sender
{
  [[self window] performClose:self];
}

- (IBAction)share:(id)sender
{
  if ([[statusField string] length] > 0) {
    [target performSelector:selector withObject:self];
    [[self window] performClose:self];
  }
}

- (BOOL)windowShouldClose:(id)window
{
  if (!disappearing) {
    disappearing = YES;
    [[[self window] animationForKey:@"alphaValue"] setDuration:kAnimationDurationOut];
    [[[self window] animator] setAlphaValue:0.0];
    [self performSelector:@selector(close)
               withObject:nil
               afterDelay:kAnimationDurationOut];
    return NO;
  }
  return YES;
}

- (void)close
{
  [[self window] close];
  [NSApp deactivate];
}

- (void)windowWillClose:(NSNotification *)notification
{
  isClosed = YES;
}

- (BOOL)isClosed
{
  return isClosed;
}

- (NSString *)statusMessage
{
  return [statusField string];
}

@end
