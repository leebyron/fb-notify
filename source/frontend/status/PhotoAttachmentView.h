//
//  ImageAttachmentView.h
//  FBDesktopNotifications
//
//  Created by Lee Byron on 11/7/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FBImageView.h"


@interface PhotoAttachmentView : NSBox {
  NSImage* image;
  FBImageView* imageView;
}

@property(retain) NSImage* image;

@end
