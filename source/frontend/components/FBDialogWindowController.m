//
//  FBDialogWindowController.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 11/4/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "FBDialogWindowController.h"

#define kAnimationDuration 0.1
#define kAnimationDurationOut 0.2
#define kSlideDistance 10
#define kDialogBorderRadius 10
#define kDialogBorderPadding 12
#define kDialogMargin 7
#define kDialogPadding 5
#define kDialogInnerRadius 3


//=====================================================================
// Subview private interfaces

@interface FBDialogWindow : NSWindow
@end

@interface FBDialogView : NSBox
@end


//=====================================================================
// Main controller implementation

@implementation FBDialogWindowController

@synthesize isClosed, isClosing, location, screenNum, editor;

- (id)initWithLocation:(NSPoint)aLocation
             screenNum:(NSUInteger)aScreenNum
{
  NSWindow* win =
  [[[FBDialogWindow alloc] initWithContentRect:NSZeroRect
                                     styleMask:NSBorderlessWindowMask
                                       backing:NSBackingStoreBuffered
                                         defer:NO] autorelease];

  if (self = [super initWithWindow:win]) {
    // remember thyself!
    [self retain];

    // remember positions
    self.location  = aLocation;
    self.screenNum = aScreenNum;

    // set window properties
    [[self window] setOpaque:NO];
    if ([[self window] respondsToSelector:@selector(setCollectionBehavior:)]) {
      [[self window] setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
    }
    [[self window] setDelegate:self];
    [[self window] setLevel:NSFloatingWindowLevel];
    [[self window] setHasShadow:YES];
    [[self window] setMovableByWindowBackground:YES];

    // add the window view
    mainView = [[FBDialogView alloc] initWithFrame:NSZeroRect];
    [[self window] setContentView:mainView];

    [self performSelector:@selector(fadeIn) withObject:nil afterDelay:0];
  }

  return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [editor release];
  [mainView release];
  [super dealloc];
}

- (void)fadeIn
{
  // set up fade in/out animation
  CABasicAnimation* fadeAni = [CABasicAnimation animation];
  [fadeAni setDelegate:self];
  [fadeAni setDuration:kAnimationDuration];

  // set up drop-in animation
  CAKeyframeAnimation* moveAni = [CAKeyframeAnimation animation];
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
  [[self window] makeFirstResponder:self];
  [[self window] setAlphaValue:0.0];
  [[[self window] animator] setAlphaValue:1.0];
  [[[self window] animator] setFrameOrigin:[[self window] frame].origin];

  // focus window
  [[self window] makeKeyAndOrderFront:self];
  [NSApp activateIgnoringOtherApps:YES];
}

- (void)addSubview:(NSView*)view
{
  [[[self window] contentView] addSubview:view];
  [self sizeToFit];

  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(subviewFrameDidChange:)
   name:NSViewFrameDidChangeNotification
   object:view];
}

- (BOOL)canBecomeKeyWindow
{
  return YES;
}

- (void)subviewFrameDidChange:(NSNotification*)notification
{
  if (trackingChange) {
    return;
  }
  trackingChange = YES;
  [self sizeToFit];
  trackingChange = NO;
}

- (id)windowWillReturnFieldEditor:(NSWindow *)sender toObject:(id)anObject
{
  if (!editor) {
    editor = [[NSTextView alloc] initWithFrame:NSZeroRect];
  }
  return editor;
}

- (void)sizeToFit
{
  FBDialogView* contentView = (FBDialogView*)[[self window] contentView];
  [contentView sizeToFit];

  // determine frame based on positioning as close as possible to percentage coordinates
  NSScreen* screen = [[NSScreen screens] objectAtIndex:MIN(screenNum, [[NSScreen screens] count])];
  NSRect screenFrame = [screen visibleFrame];

  NSRect contentBounds = [contentView bounds];
  NSPoint offset = NSMakePoint(round(contentBounds.size.width * 0.5), 0);
  NSPoint center = NSMakePoint(round(location.x * screenFrame.size.width),
                               round(location.y * screenFrame.size.height));
  center.x = screenFrame.origin.x + CLAMP(center.x, offset.x, screenFrame.size.width - offset.x);
  center.y = screenFrame.origin.y + CLAMP(center.y, offset.y, screenFrame.size.height - offset.y);

  NSRect winFrame = NSMakeRect(center.x - round(contentBounds.size.width * 0.5),
                               center.y - contentBounds.size.height,
                               contentBounds.size.width,
                               contentBounds.size.height);

  [contentView setFrameOrigin:NSZeroPoint];
  [[self window] setFrame:winFrame display:YES];
}

- (void)windowDidMove:(NSNotification*)notif
{
  if (!isOpen) {
    return;
  }

  // get and set new location
  NSScreen* screen = [[self window] screen];
  NSRect screenFrame = [screen visibleFrame];
  NSRect windowFrame = [[self window] frame];
  screenNum = [[NSScreen screens] indexOfObject:screen];

  location.x = (windowFrame.origin.x - screenFrame.origin.x + round(windowFrame.size.width * 0.5)) / screenFrame.size.width;
  location.y = (windowFrame.origin.y - screenFrame.origin.y + windowFrame.size.height) / screenFrame.size.height;
}

- (void)close
{
  [NSApp deactivate];
  if (!isClosing) {
    isClosing = YES;

    // create fade out animation
    CABasicAnimation* fadeAni = [CABasicAnimation animation];
    [fadeAni setDelegate:self];
    [fadeAni setDuration:kAnimationDurationOut];

    // assign animation
    [[self window] setAnimations:[NSDictionary dictionaryWithObjectsAndKeys:fadeAni, @"alphaValue", nil]];

    // fade out
    [[[self window] animationForKey:@"alphaValue"] setDuration:kAnimationDurationOut];
    [[[self window] animator] setAlphaValue:0.0];
  }
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
  if (flag) {
    isOpen = YES;
    [[self window] setAnimations:nil];
  }
  if (isClosing && !isClosed) {
    isClosed = YES;
    [[self window] close];

    // release thyself!
    [self release];
  }
}

@end


//=================================================================
// Dialog Window

@implementation FBDialogWindow

- (BOOL)canBecomeKeyWindow {
  return YES;
}

@end


//=================================================================
// Dialog View

@implementation FBDialogView

- (id)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self setBoxType:NSBoxCustom];
    [self setBorderWidth:0];
    CGFloat viewMargins = kDialogBorderPadding + kDialogMargin;
    [self setContentViewMargins:NSMakeSize(viewMargins, viewMargins)];
  }
  return self;
}

- (void)sizeToFit
{
  NSView* contentView = self.contentView;
  NSSize margins = self.contentViewMargins;

  // calculate total height
  NSPoint position = NSMakePoint(0, 0);
  for (NSView* view in contentView.subviews) {
    if (view.frame.size.height == 0) {
      continue;
    }
    position.y += view.frame.size.height + kDialogPadding;
    position.x = MAX(position.x, view.frame.size.width);
  }

  // set margins for whole box
  [self setFrame:NSMakeRect(0, 0, position.x + margins.width * 2,
                            position.y + margins.height * 2 - kDialogPadding)];

  // place each object at the appropriate place
  for (NSView* view in contentView.subviews) {
    if (view.frame.size.height == 0) {
      continue;
    }
    position.y -= view.frame.size.height + kDialogPadding;
    position.x = contentView.frame.size.width - view.frame.size.width;
    [view setFrameOrigin:position];
  }
}

- (void)drawRect:(NSRect)dirtyRect
{
  NSRect frameRect = [self bounds];

  [[NSColor clearColor] set];
  NSRectFill(frameRect);

  // clear everything
  [[NSColor clearColor] set];
  NSRectFill(frameRect);

  // draw border
  NSBezierPath* dialogBorderRect =
  [NSBezierPath bezierPathWithRoundedRect:frameRect
                                  xRadius:kDialogBorderRadius
                                  yRadius:kDialogBorderRadius];
  [[NSColor colorWithCalibratedWhite:0.0 alpha:0.4] set];
  [dialogBorderRect fill];

  // draw filling
  NSRect fillingRect = NSInsetRect(frameRect, kDialogBorderPadding, kDialogBorderPadding);

  [[NSColor colorWithCalibratedWhite:0.88 alpha:1.0] set];
  [[NSBezierPath bezierPathWithRoundedRect:fillingRect
                                   xRadius:kDialogInnerRadius
                                   yRadius:kDialogInnerRadius] fill];

  // fillings 3dness
  NSRect lightEdge = NSMakeRect(fillingRect.origin.x + kDialogInnerRadius * 0.5,
                                fillingRect.origin.y + fillingRect.size.height - 1,
                                fillingRect.size.width - kDialogInnerRadius, 1);
  [[NSColor colorWithCalibratedWhite:1.0 alpha:0.3] set];
  [[NSBezierPath bezierPathWithRect:lightEdge] fill];

  NSRect darkEdge = NSIntegralRect(lightEdge);
  darkEdge.origin.y = fillingRect.origin.y;
  [[NSColor colorWithCalibratedWhite:0.0 alpha:0.1] set];
  [[NSBezierPath bezierPathWithRect:darkEdge] fill];
}

@end
