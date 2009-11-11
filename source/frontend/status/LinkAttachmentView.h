//
//  LinkAttachmentView.h
//  FBDesktopNotifications
//
//  Created by Lee Byron on 11/10/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LinkAttachmentView : NSBox {
  NSURL* link;
}

@property(retain) NSURL* link;

@end
