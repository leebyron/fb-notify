//
//  StatusUpdateWindow.h
//  Facebook
//
//  Created by Lee Byron on 8/13/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SUTextView.h"


@interface StatusUpdateWindow : NSWindowController {
  IBOutlet SUTextView *statusField;
  IBOutlet NSPanel *panel;

  id target;
  SEL selector;
  BOOL isClosed;
  BOOL disappearing;
  BOOL doShare;
}

- (id)initWithTarget:(id)obj selector:(SEL)sel;

- (IBAction)cancel:(id)sender;
- (IBAction)share:(id)sender;

- (BOOL)isClosed;
- (NSString *)statusMessage;

@end
