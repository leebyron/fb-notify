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

    // Force the window to be loaded
    [[self window] center];
  }
  
  return self;
}

- (void)windowDidLoad
{
  [[self window] makeKeyAndOrderFront:self];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
  [statusField becomeFirstResponder];
}

- (BOOL)control: (NSControl *)control textView:(NSTextView *)textView doCommandBySelector: (SEL)commandSelector {
  if ([NSStringFromSelector(commandSelector) isEqual:@"insertNewline:"]) {
    [target performSelector:selector withObject:self];
    [[self window] performClose:self];
    return YES;
  }
  return NO;
}

- (void)windowWillClose:(NSNotification *)notification
{
  isClosed = YES;
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
