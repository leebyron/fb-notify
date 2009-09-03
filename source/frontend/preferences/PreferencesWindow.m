//
//  PreferencesWindow.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 8/20/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "PreferencesWindow.h"
#import "ApplicationController.h"
#import "StatusKeyShortcut.h"
#import "LoginItemManager.h"
#import "BubbleDimensions.h"
#import "GlobalSession.h"
#import "NetConnection.h"

@implementation PreferencesWindow

static PreferencesWindow* currentWindow;
static ApplicationController* parent;

+(void) setupWithParent:(ApplicationController*)p
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
  [lightMode setState:[[NSUserDefaults standardUserDefaults] boolForKey:kBubbleLightMode]];

  // Status Update Key Shortcut
  KeyCombo hotkey;
  hotkey.code = [[StatusKeyShortcut instance] keyCode];
  if (hotkey.code) {
    hotkey.flags = [[StatusKeyShortcut instance] keyFlags];
    [statusKeyShortcut setKeyCombo:hotkey];
  }

  // Notification Duration
  [notificationDuration setIntegerValue:[[NSUserDefaults standardUserDefaults] integerForKey:kDisplayTimeKey]];

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
  NSImage* userpic   = [[parent profilePics] imageForKey:[connectSession uid]];
  NSString* username = [[parent names] objectForKey:[connectSession uid]];
  if ([connectSession isLoggedIn] && userpic && username) {
    [pic setImage:userpic];
    [name setStringValue:username];
    [logoutButton setEnabled:YES];
  } else {
    [pic setImage:[[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"silhouette" ofType:@"png"]]];
    [name setStringValue:@"Not Logged In"];
    [logoutButton setEnabled:NO];
  }
}

- (IBAction) logoutButtonPressed:(id) sender
{
  if ([[NetConnection netConnection] isOnline] && [connectSession isLoggedIn]) {
    [[NSApp delegate] logout:self];
  }
}

- (IBAction) startAtLoginChanged:(id) sender
{
  [[LoginItemManager manager] setIsLoginItem:([sender state] == NSOnState)];
}

- (IBAction) lightModeChanged:(id) sender
{
  [[NSUserDefaults standardUserDefaults] setBool:([sender state] == NSOnState) forKey:kBubbleLightMode];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)shortcutRecorder:(SRRecorderControl*)recorder keyComboDidChange:(KeyCombo)hotkey
{
  [[StatusKeyShortcut instance] registerKeyShortcutWithCode:hotkey.code flags:hotkey.flags];
}

- (IBAction) notificationDurationChanged:(id) sender
{
  [[NSUserDefaults standardUserDefaults] setInteger:[sender integerValue] forKey:kDisplayTimeKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
