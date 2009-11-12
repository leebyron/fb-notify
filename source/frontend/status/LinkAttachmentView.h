//
//  LinkAttachmentView.h
//  FBDesktopNotifications
//
//  Created by Lee Byron on 11/10/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LinkAttachmentView : NSControl {
  NSURL* link;
  NSDictionary* attachment;
  NSMutableArray* images;
  BOOL isVideo;

  NSProgressIndicator* loader;
  NSButton* leftArrow;
  NSButton* rightArrow;

  NSInteger currentImageIndex;

  NSDictionary* nameStyle;
  NSDictionary* captionStyle;
  NSDictionary* descriptionStyle;

  NSSize imageSize;
  NSSize nameSize;
  NSSize captionSize;
  NSSize descriptionSize;
  BOOL isLoading;
}

@property(retain) NSURL* link;
@property(readonly) NSString* image;
@property(retain) NSDictionary* attachment;

@property(readonly) NSDictionary* nameStyle;
@property(readonly) NSDictionary* captionStyle;
@property(readonly) NSDictionary* descriptionStyle;

@end
