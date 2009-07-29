//
//  BubbleWindow.m
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import "BubbleWindow.h"
#import <QuartzCore/QuartzCore.h>
#import <ApplicationServices/ApplicationServices.h>

#define kANIMATION_DURATION 0.2
#define kCLOSE_SLIDE_DISTANCE 20


@implementation BubbleWindow

- (id)initWithFrame:(NSRect)frame text:(NSString *)text
{
  [self initWithFrame:frame text:text image:nil];
}

- (id)initWithFrame:(NSRect)frame text:(NSString *)text image:(NSURL *)image
{
  self = [super initWithContentRect:frame
                          styleMask:NSBorderlessWindowMask
                            backing:NSBackingStoreBuffered
                              defer:YES];
  if (self) {
    // Set up the BubbleView, which draws the black rounded-rect background
    NSRect viewFrame = frame;
    viewFrame.origin = NSZeroPoint;
    view = [[BubbleView alloc] initWithFrame:frame text:text];
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
  }
  return self;
}

- (void)appear
{
  [self setAlphaValue:0.0];
  [self makeKeyAndOrderFront:self];
  [[self animator] setAlphaValue:1.0];
}

- (void)disappear
{
  [self setAlphaValue:1.0];
  [[self animator] setAlphaValue:0.0];
  [self slideDown:kCLOSE_SLIDE_DISTANCE];
}

- (void)slideDown:(float)distance
{
  NSPoint point = [self frame].origin;
  point.y -= distance;
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathMoveToPoint(path, NULL, [self frame].origin.x, [self frame].origin.y);
  CGPathAddLineToPoint(path, NULL, point.x, point.y);
  [moveAnim setPath:path];
  CGPathRelease(path);
  [[self animator] setFrameOrigin:point];
}

- (void)mouseUp:(NSEvent *)event
{
  [self disappear];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
  // If the alpha value is 0, this means the "fade out" animation just finished
  // as part of the window going away.
  if ([self alphaValue] == 0.0) {
    [self orderOut:self];
  }
}

@end
