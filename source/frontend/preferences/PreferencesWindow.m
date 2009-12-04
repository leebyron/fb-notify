//
//  PreferencesWindow.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 8/20/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "PreferencesWindow.h"
#import <Growl/Growl.h>
#import "FacebookNotifierController.h"
#import "StatusKeyShortcut.h"
#import "LoginItemManager.h"
#import "BubbleManager.h"
#import "BubbleDimensions.h"
#import "GlobalSession.h"
#import "NetConnection.h"
#import "NSImage+.h"
#import "FBPreferenceManager.h"


@implementation PreferencesWindow

static PreferencesWindow* currentWindow = nil;
static FacebookNotifierController* parent = nil;

+(void) setupWithParent:(FacebookNotifierController*)p
{
  parent = p;
}

+(void) show
{
  if (currentWindow != nil) {
    [currentWindow refresh];
    [NSApp activateIgnoringOtherApps:YES];
    [[currentWindow window] makeKeyAndOrderFront:nil];
  } else {
    currentWindow = [[PreferencesWindow alloc] init];
    [currentWindow refresh];
  }
}

-(id) init
{
  self = [super initWithWindowNibName:@"preferences"];
  if (self) {
    // Force the window to be loaded
    [[self window] center];
  }

  return self;
}

-(void) dealloc
{
  currentWindow = nil;
  [super dealloc];
}

- (void)windowDidLoad
{
  // Version
  NSString* v = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
  [version setStringValue:[NSString stringWithFormat:@"Version %@", v]];

  // Start at Login
  [startAtLogin setState:[[LoginItemManager manager] isLoginItem]];
  [lightMode setState:[[FBPreferenceManager manager] boolForKey:kBubbleLightMode]];

  // Status Update Key Shortcut
  KeyCombo hotkey;
  hotkey.code = [[StatusKeyShortcut instance] keyCode];
  if (hotkey.code) {
    hotkey.flags = [[StatusKeyShortcut instance] keyFlags];
    [statusKeyShortcut setKeyCombo:hotkey];
  }

  // Notification Duration
  [notificationDuration setIntegerValue:[[FBPreferenceManager manager] intForKey:kDisplayTimeKey]];

  // Setup the rest!
  [self refresh];

  // Load window to front
  [NSApp activateIgnoringOtherApps:YES];
  [[self window] makeKeyAndOrderFront:self];
}

+ (void)refresh
{
  if (!currentWindow) {
    return;
  }
  [currentWindow refresh];
}

- (void)refresh
{
  // Set the image and title
  NSImage* userpic = [[parent profilePics] imageForKey:[connectSession uid]];
  if ([connectSession isLoggedIn] && userpic) {
    [pic setImage:userpic];
    [logoutButton setEnabled:YES];
  } else {
    [pic setImage:[NSImage bundlePNG:@"silhouette"]];
    [logoutButton setEnabled:NO];
  }

  // Growl?
  BOOL hasGrowl = [GrowlApplicationBridge isGrowlInstalled];
  [growlNotRunning setHidden:[GrowlApplicationBridge isGrowlRunning]];
  [useGrowl setEnabled:hasGrowl];

  [useGrowl setState:([[FBPreferenceManager manager] boolForKey:kUseGrowlOption] &&
                      hasGrowl)];
}

- (IBAction)logoutButtonPressed:(id)sender
{
  if ([[NetConnection netConnection] isOnline] && [connectSession isLoggedIn]) {
    [[NSApp delegate] logout:self];
  }
}

- (IBAction)startAtLoginChanged:(id)sender
{
  [[LoginItemManager manager] setIsLoginItem:([sender state] == NSOnState)];
}

- (IBAction)useGrowlChanged:(id)sender
{
  NSLog(@"changed use growl to %i", [sender state] == NSOnState);
  [[FBPreferenceManager manager] setBool:([sender state] == NSOnState) forKey:kUseGrowlOption];
}

- (IBAction)lightModeChanged:(id)sender
{
  [[FBPreferenceManager manager] setBool:([sender state] == NSOnState) forKey:kBubbleLightMode];
}

- (void)shortcutRecorder:(SRRecorderControl*)recorder keyComboDidChange:(KeyCombo)hotkey
{
  [[StatusKeyShortcut instance] registerKeyShortcutWithCode:hotkey.code flags:hotkey.flags];
}

- (IBAction)notificationDurationChanged:(id)sender
{
  [[FBPreferenceManager manager] setInt:[sender intValue] forKey:kDisplayTimeKey];
}

@end
