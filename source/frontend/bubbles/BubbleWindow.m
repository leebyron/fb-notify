//
//  BubbleWindow.m
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import "BubbleWindow.h"
#import <QuartzCore/QuartzCore.h>
#import <ApplicationServices/ApplicationServices.h>
#import "BubbleDimensions.h"
#import "FacebookNotifierController.h"
#import "FBPreferenceManager.h"


@implementation BubbleWindow

- (id)initWithFrame:(NSRect)frame
              image:(NSImage*)image
               text:(NSString*)text
            subText:(NSString*)subText
             action:(id)action
{
  // need to make space for a shadow, add a 10px border
  NSRect wideFrame = NSMakeRect(frame.origin.x - kBubbleShadowSpacing,
                                frame.origin.y - kBubbleShadowSpacing,
                                frame.size.width + 2.0 * kBubbleShadowSpacing,
                                frame.size.height + 2.0 * kBubbleShadowSpacing);

  self = [super initWithContentRect:wideFrame
                          styleMask:NSBorderlessWindowMask
                            backing:NSBackingStoreBuffered
                              defer:YES];
  if (self) {
    windowAction = [action retain];
    disappearing = NO;

    // Set up the BubbleView, which draws the rounded-rect background
    view = [[BubbleView alloc] initWithFrame:frame
                                       image:image
                                        text:text
                                     subText:subText];
    [self setContentView:view];
    [view release];

    // set up fade in/out animation
    CAAnimation* fadeAni = [CABasicAnimation animation];
    [fadeAni setDelegate:self];
    [fadeAni setDuration:kAnimationDuration];

    // set up drop-in animation
    CAKeyframeAnimation* moveAni = [CAKeyframeAnimation animation];
    [moveAni setDuration:kAnimationDuration];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, [self frame].origin.x, [self frame].origin.y + kCloseSlideDistance);
    CGPathAddLineToPoint(path, NULL, [self frame].origin.x, [self frame].origin.y);
    [moveAni setPath:path];
    CGPathRelease(path);

    // assign animations
    [self setAnimations:[NSDictionary dictionaryWithObjectsAndKeys:fadeAni, @"alphaValue",
                                                                   moveAni, @"frameOrigin", nil]];

    // Set some attributes of the window to make it work/look right
    if ([self respondsToSelector:@selector(setCollectionBehavior:)]) {
      [self setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
    }
    [self setLevel:NSStatusWindowLevel];
    [self setOpaque:NO];
    [self setAlphaValue:1.0];
    [self setReleasedWhenClosed:NO];

    // allows mouse enter/leave handlers to work
    [view addTrackingRect:[view bounds] owner:self userData:nil assumeInside:NO];

    // Prep to remove it
    [self performSelector:@selector(disappear)
               withObject:nil
               afterDelay:[[FBPreferenceManager manager] intForKey:kDisplayTimeKey]];
  }
  return self;
}

- (void)dealloc
{
  [windowAction release];
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

- (void)mouseEntered:(NSEvent*)event
{
  if (disappearing) {
    return;
  }

  if ([windowAction isKindOfClass:[FBNotification class]]) {
    [windowAction markAsSeen];
  } else if ([windowAction isKindOfClass:[FBMessage class]]) {
    [windowAction markAsSeen];
  }
  [[NSApp delegate] invalidate];
  [self setAlphaValue:1.0];
  [NSObject cancelPreviousPerformRequestsWithTarget:self
                                           selector:@selector(disappear)
                                             object:nil];
}

- (void)mouseExited:(NSEvent*)event
{
  if (disappearing) {
    return;
  }
  // if there is a notification, mark it as read since they're usually short
  if ([windowAction isKindOfClass:[FBNotification class]]) {
    [windowAction markAsReadWithSimilar:NO];
  }
  // we could mark messages as read if dismissed, but I don't think we should
  [self disappear];
}

- (void)mouseUp:(NSEvent*)event
{
  [[BubbleManager manager] executeAction:windowAction];
  [self disappear];
}

- (void)animationDidStop:(CAAnimation*)theAnimation finished:(BOOL)flag
{
  // If the alpha value is near 0, this means the "fade out" animation just finished
  // as part of the window going away.
  if ([self alphaValue] < 0.01) {
    [self close];
    [[[BubbleManager manager] windows] removeObject:self];
  }
}

@end
