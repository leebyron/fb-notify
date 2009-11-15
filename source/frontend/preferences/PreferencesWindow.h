//
//  PreferencesWindow.h
//  FBDesktopNotifications
//
//  Created by Lee Byron on 8/20/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SRRecorderControl.h"

@class FacebookNotifierController;

@interface PreferencesWindow : NSWindowController {
  IBOutlet NSTextField*       version;

  IBOutlet NSImageView*       pic;
  IBOutlet NSButton*          logoutButton;
  IBOutlet NSButton*          startAtLogin;

  IBOutlet NSButton*          useGrowl;
  IBOutlet NSTextField*       growlNotRunning;
  IBOutlet NSButton*          lightMode;
  IBOutlet SRRecorderControl* statusKeyShortcut;
  IBOutlet NSSlider*          notificationDuration;
}

+ (void) setupWithParent:(FacebookNotifierController*)p;
+ (void) show;
+ (void) refresh;
- (void) refresh;

- (IBAction) logoutButtonPressed:(id)sender;
- (IBAction) startAtLoginChanged:(id)sender;

- (IBAction) useGrowlChanged:(id)sender;
- (IBAction) lightModeChanged:(id)sender;
- (void)shortcutRecorder:(SRRecorderControl*)recorder keyComboDidChange:(KeyCombo)hotkey;
- (IBAction) notificationDurationChanged:(id)sender;

@end
