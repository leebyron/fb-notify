//
//  PreferencesWindow.h
//  FBDesktopNotifications
//
//  Created by Lee Byron on 8/20/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SRRecorderControl.h"

@class ApplicationController;

@interface PreferencesWindow : NSWindowController {
  IBOutlet NSTextField*       version;

  IBOutlet NSImageView*       pic;
  IBOutlet NSTextField*       name;
  IBOutlet NSButton*          logoutButton;

  IBOutlet NSButton*          startAtLogin;
  IBOutlet NSButton*          lightMode;
  IBOutlet SRRecorderControl* statusKeyShortcut;
  IBOutlet NSSlider*          notificationDuration;
}

+ (void) setupWithParent:(ApplicationController*)p;
+ (void) show;
+ (void) refresh;
- (void) refresh;

- (IBAction) logoutButtonPressed:(id) sender;

- (IBAction) startAtLoginChanged:(id) sender;
- (IBAction) lightModeChanged:(id) sender;
- (void)shortcutRecorder:(SRRecorderControl*)recorder keyComboDidChange:(KeyCombo)hotkey;
- (IBAction) notificationDurationChanged:(id) sender;

@end
