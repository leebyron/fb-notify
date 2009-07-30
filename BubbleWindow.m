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
    disappearing = NO;
    notification = [notif retain];

    // Set up the BubbleView, which draws the black rounded-rect background
    NSRect viewFrame = frame;
    viewFrame.origin = NSZeroPoint;
    view = [[BubbleView alloc] initWithFrame:frame image:image text:text];
    [self setContentView:view];
    [view release];

    // Set up the animations which make the window appear/disappear coolly
    CAAnimation *fadeAnim = [CABasicAnimation animation];
    [fadeAnim setDuration:kANIMATION_DURATION];
    [fadeAnim setDelegate:self];

    // This animation gets a new path every time it is used, since the path
    // needs to change depending on where the window is and where it's going.
    // We don't bother setting its delegate; we only need to know about one
    // animation finishing.
    moveAnim = [CAKeyframeAnimation animation];
    [moveAnim setDuration:kANIMATION_DURATION];

    [self setAnimations:[NSDictionary dictionaryWithObjectsAndKeys:fadeAnim,
                         @"alphaValue", moveAnim, @"frameOrigin", nil]];

    // Set some attributes of the window to make it work/look right
    [self setLevel:NSFloatingWindowLevel];
    [self setOpaque:NO];
    [self setAlphaValue:1.0];
    
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
  [self slideDown:kCLOSE_SLIDE_DISTANCE];
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
  [self setAlphaValue:1.0];
  [[self animator] setAlphaValue:0.0];
}

- (void)slideDown:(float)distance
{
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathMoveToPoint(path, NULL, [self frame].origin.x, [self frame].origin.y + distance);
  CGPathAddLineToPoint(path, NULL, [self frame].origin.x, [self frame].origin.y);
  [moveAnim setPath:path];
  CGPathRelease(path);
  [[self animator] setFrameOrigin:[self frame].origin];
}

- (void)mouseEntered:(NSEvent *)event
{
  [NSObject cancelPreviousPerformRequestsWithTarget:self
                                           selector:@selector(disappear)
                                             object:nil];
}

- (void)mouseExited:(NSEvent *)event
{
  [notification markAsRead];
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
    [[manager windows] removeObject:self];
    [self orderOut:self];
  }
}

@end
