//
//  StatusUpdateWindow.h
//  Facebook
//
//  Created by Lee Byron on 8/13/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface StatusUpdateWindow : NSWindowController {
  IBOutlet NSTextField *statusField;
  IBOutlet NSPanel *panel;

  id target;
  SEL selector;
  BOOL isClosed;
  BOOL disappearing;
  NSString *lastApp;
}

- (id)initWithTarget:(id)obj selector:(SEL)sel;

- (BOOL)isClosed;
- (NSString *)statusMessage;

@end
