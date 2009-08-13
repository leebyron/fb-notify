//
//  StatusUpdateWindow.m
//  Facebook
//
//  Created by Lee Byron on 8/13/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "StatusUpdateWindow.h"


@implementation StatusUpdateWindow

- (id)initWithTarget:(id)obj selector:(SEL)sel
{
  self = [super initWithWindowNibName:@"status"];
  if (self) {
    target   = obj;
    selector = sel;
    isClosed = NO;
    
    // what was the last active window?    
    NSDictionary *app = [[NSWorkspace sharedWorkspace] activeApplication];

    if ([[app objectForKey:@"NSApplicationBundleIdentifier"] isEqual:@"com.facebook.notifications"]) {
      lastApp = nil;
    } else {
      lastApp = [app objectForKey:@"NSApplicationName"];
    }

    // Force the window to be loaded
    [[self window] center];
  }
  
  return self;
}

- (void)windowDidLoad
{
  [NSApp activateIgnoringOtherApps:YES];
  [[self window] makeKeyAndOrderFront:self];
}

- (BOOL)control: (NSControl *)control textView:(NSTextView *)textView doCommandBySelector: (SEL)commandSelector {
  if ([NSStringFromSelector(commandSelector) isEqual:@"insertNewline:"] &&
      [[statusField stringValue] length] > 0) {
    [target performSelector:selector withObject:self];
    [[self window] performClose:self];
    return YES;
  }
  return NO;
}

- (void)windowWillClose:(NSNotification *)notification
{
  isClosed = YES;

  // refocus last app!
  [NSApp deactivate];
  if (lastApp && [lastApp length] > 0) {
    [[NSWorkspace sharedWorkspace] launchApplication:lastApp];
  }
}

- (BOOL)isClosed
{
  return isClosed;
}

- (NSString *)statusMessage
{
  return [statusField stringValue];
}

@end
