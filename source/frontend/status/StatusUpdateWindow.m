//
//  StatusUpdateWindow.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 11/4/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "StatusUpdateWindow.h"

#define kStatusUpdateWindowX @"statusUpdateWindowX"
#define kStatusUpdateWindowY @"statusUpdateWindowY"
#define kStatusUpdateWindowScreen @"statusUpdateWindowScreen"


@implementation StatusUpdateWindow

- (id)initWithTarget:(id)obj selector:(SEL)sel
{
  // get prefered window position if set
  NSPoint loc;
  loc.x = [[NSUserDefaults standardUserDefaults] floatForKey:kStatusUpdateWindowX];
  loc.y = [[NSUserDefaults standardUserDefaults] floatForKey:kStatusUpdateWindowY];
  NSUInteger screen = [[NSUserDefaults standardUserDefaults] integerForKey:kStatusUpdateWindowScreen];
  if (loc.x == 0 && loc.y == 0) {
    loc.x = 0.5;
    loc.y = 0.75;
  }

  if (self = [super initWithLocation:loc screenNum:screen]) {
    target   = obj;
    selector = sel;

    messageBox = [[FBExpandingTextView alloc] initWithFrame:NSMakeRect(0, 0, 400, 46)];
    messageBox.delegate = self;
    [self addSubview:messageBox];

    NSButton* button = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 60, 18)];
    button.bezelStyle = NSRoundRectBezelStyle;//NSShadowlessSquareBezelStyle;//NSSmallSquareBezelStyle;
    button.title = @"Share";
    button.target = self;
    button.action = @selector(share:);
    [self addSubview:button];
    [button release];
  }
  return self;
}

- (void)dealloc
{
  [messageBox release];
  [super dealloc];
}

- (void)windowDidMove:(NSNotification*)notif
{
  [super windowDidMove:notif];

  // record to prefs
  [[NSUserDefaults standardUserDefaults] setFloat:self.location.x forKey:kStatusUpdateWindowX];
  [[NSUserDefaults standardUserDefaults] setFloat:self.location.y forKey:kStatusUpdateWindowY];
  [[NSUserDefaults standardUserDefaults] setInteger:self.screenNum forKey:kStatusUpdateWindowScreen];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)cancel:(id)sender
{
  [self close];
}

- (IBAction)share:(id)sender
{
  if ([[self statusMessage] length] > 0) {
    [target performSelector:selector withObject:self];
    [self close];
  }
}

- (NSDictionary*)streamPost
{
  return [NSDictionary dictionaryWithObjectsAndKeys:nil];
}

- (NSString *)statusMessage
{
  return [[messageBox documentView] string];
}

@end
