//
//  BubbleWindow.m
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import "BubbleWindow.h"
#import "NotificationResponder.h"
#import <QuartzCore/QuartzCore.h>
#import <ApplicationServices/ApplicationServices.h>

#define kANIMATION_DURATION 0.2
#define kCLOSE_SLIDE_DISTANCE 5
#define kDisplayTime 6

@implementation BubbleWindow

- (id)initWithManager:(BubbleManager *)mngr
                frame:(NSRect)frame
                image:(NSImage *)image
                 text:(NSString *)text
         notification:(FBNotification *)notif
{
  self = [super initWithContentRect:frame
                          styleMask:NSBorderlessWindowMask
                            backing:NSBackingStoreBuffered
                              defer:YES];
  if (self) {
    manager      = mngr;
    notification = [notif retain];
    disappearing = NO;

    // Set up the BubbleView, which draws the black rounded-rect background
    view = [[BubbleView alloc] initWithFrame:frame image:image text:text];
    [self setContentView:view];
    [view release];

    // set up fade in/out animation
    CAAnimation *fadeAni = [CABasicAnimation animation];
    [fadeAni setDelegate:self];
    [fadeAni setDuration:kANIMATION_DURATION];

    // set up drop-in animation
    CAKeyframeAnimation *moveAni = [CAKeyframeAnimation animation];
    [moveAni setDuration:kANIMATION_DURATION];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, [self frame].origin.x, [self frame].origin.y + kCLOSE_SLIDE_DISTANCE);
    CGPathAddLineToPoint(path, NULL, [self frame].origin.x, [self frame].origin.y);
    [moveAni setPath:path];
    CGPathRelease(path);

    // assign animations
    [self setAnimations:[NSDictionary dictionaryWithObjectsAndKeys:fadeAni, @"alphaValue",
                                                                   moveAni, @"frameOrigin", nil]];

    // Set some attributes of the window to make it work/look right
    [self setLevel:NSFloatingWindowLevel];
    [self setOpaque:NO];
    [self setAlphaValue:1.0];
    [self setReleasedWhenClosed:NO];

    // allows mouse enter/leave handlers to work
    [view addTrackingRect:[view bounds] owner:self userData:nil assumeInside:NO];

    // Prep to remove it
    [self performSelector:@selector(disappear)
               withObject:nil
               afterDelay:kDisplayTime];
  }
  return self;
}

- (void)dealloc
{
  [notification release];
  [super dealloc];
}

- (void)appear
{
  [self setAlphaValue:0.0];
  [self makeKeyAndOrderFront:self];
  [[self animator] setAlphaValue:1.0];
  [[self animator] setFrameOrigin:[self frame].origin];
}

- (void)disappear
{
  if (disappearing) {
    return;
  }
  disappearing = YES;
  [NSObject cancelPreviousPerformRequestsWithTarget:self
                                           selector:@selector(disappear)
                                             object:nil];
  [[self animator] setAlphaValue:0.0];
}

- (void)mouseEntered:(NSEvent *)event
{
  if (disappearing) {
    return;
  }
  [self setAlphaValue:1.0];
  [NSObject cancelPreviousPerformRequestsWithTarget:self
                                           selector:@selector(disappear)
                                             object:nil];
}

- (void)mouseExited:(NSEvent *)event
{
  if (disappearing) {
    return;
  }
  if (notification != nil) {
    [[NSApp delegate] markNotificationAsRead:notification];
  }
  [self disappear];
}

- (void)mouseUp:(NSEvent *)event
{
  if (notification != nil) {
    [[NSApp delegate] readNotification:notification];
  }
  [self disappear];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
  // If the alpha value is near 0, this means the "fade out" animation just finished
  // as part of the window going away.
  if ([self alphaValue] < 0.01) {
    [self close];
    [[manager windows] removeObject:self];
  }
}

@end
