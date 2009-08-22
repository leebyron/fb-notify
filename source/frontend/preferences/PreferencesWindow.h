//
//  PreferencesWindow.h
//  FBDesktopNotifications
//
//  Created by Lee Byron on 8/20/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SRRecorderControl.h"


@interface PreferencesWindow : NSWindowController {
  IBOutlet NSTextField*       version;
  IBOutlet NSButton*          startAtLogin;
  IBOutlet SRRecorderControl* statusKeyShortcut;
  IBOutlet NSSlider*          notificationDuration;
}

+(void) show;

- (void)shortcutRecorder:(SRRecorderControl*)recorder keyComboDidChange:(KeyCombo)hotkey;
- (IBAction) startAtLoginChanged:(id) sender;

@end
