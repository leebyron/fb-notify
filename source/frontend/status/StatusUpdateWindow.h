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
#import "AttachmentBox.h"
#import "FBButton.h"


@interface StatusUpdateWindow : FBDialogWindowController {
  FBExpandingTextView* messageBox;
  AttachmentBox* attachmentBox;
  NSView* attachment;

  BOOL currentlySizing;
  
  FBButton* removeButton;
}

@property(retain) NSView* attachment;

+ (id)open;
+ (StatusUpdateWindow*)currentWindow;

- (void)appendString:(NSString*)string;

// delegate responses
- (IBAction)cancel:(id)sender;
- (IBAction)submit:(id)sender;

// results
- (NSDictionary*)streamPost;

@end
