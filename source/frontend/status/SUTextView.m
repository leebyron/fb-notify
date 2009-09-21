//
//  SUTextView.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 9/20/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "SUTextView.h"
#import "StatusUpdateWindow.h"
#import "NSEvent+.h"

#define DELEGATE(sel) {if (delegate && [delegate respondsToSelector:(sel)]) {\
[delegate performSelector:(sel) withObject:self];}}


@implementation SUTextView

- (void)awakeFromNib
{
  [self setFieldEditor:YES];
  [self setAllowsUndo:YES];
  [self setRichText:NO];
  [self setTextContainerInset:NSMakeSize(6.0, 6.0)];
  [self setFont:[NSFont userFontOfSize:14.0]];
}

- (void)interpretKeyEvents:(id)events
{
  for (NSEvent* e in events) {

    // capture key events to do standard text manipulation
    if ([e isKey:@"a" modifiers:NSCommandKeyMask]) {
      [self selectAll:self];
    } else if ([e isKey:@"c" modifiers:NSCommandKeyMask]) {
      [self copy:self];
    } else if ([e isKey:@"v" modifiers:NSCommandKeyMask]) {
      [self paste:self];
    } else if ([e isKey:@"x" modifiers:NSCommandKeyMask]) {
      [self cut:self];
    } else if ([e isKey:@"z" modifiers:NSCommandKeyMask]) {
      [[self undoManager] undo];
    } else if ([e isKey:@"z" modifiers:NSCommandKeyMask|NSShiftKeyMask]) {
      [[self undoManager] redo];

    // capture line breaks and shortcut for share button
    } else if ([e isKeyCode:36 modifiers:0]) {
      [self insertText:@"\n"];
    } else if ([e isKeyCode:36 modifiers:NSShiftKeyMask] ||
               [e isKeyCode:36 modifiers:NSCommandKeyMask]) {
      [[self delegate] share:self];
    } else if ([e isKey:@"w" modifiers:NSCommandKeyMask]) {
      [[self delegate] cancel:self];

    // everything else pass on as per usual
    } else {
      [super interpretKeyEvents:[NSArray arrayWithObject:e]];
    }
  }
}

- (void)paste:(id)sender {
  // TODO: check paste type
  [self pasteAsPlainText:sender];
}


@end
