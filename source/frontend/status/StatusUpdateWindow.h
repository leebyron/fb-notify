//
//  StatusUpdateWindow.h
//  FBDesktopNotifications
//
//  Created by Lee Byron on 11/4/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FBDialogWindowController.h"
#import "FBExpandingTextView.h"


@interface StatusUpdateWindow : FBDialogWindowController {
  id target;
  SEL selector;

  FBExpandingTextView* messageBox;
}

- (id)initWithTarget:(id)obj selector:(SEL)sel;

- (IBAction)cancel:(id)sender;
- (IBAction)share:(id)sender;

- (NSDictionary*)streamPost;
- (NSString *)statusMessage; // oldskool

@end
