//
//  SUScrollView.h
//  FBDesktopNotifications
//
//  Created by Lee Byron on 11/5/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FBExpandingTextView : NSScrollView {
  id delegate;

  BOOL isResizing;
  NSSize maxSize;
  NSView* edge;
}

@property(assign) id delegate;
@property NSSize maxSize;

- (id)initWithFrame:(NSRect)frame;

@end


@protocol FBExpandingTextViewDelegate

- (void)cancel:(FBExpandingTextView*)view;
- (void)submit:(FBExpandingTextView*)view;

@end
