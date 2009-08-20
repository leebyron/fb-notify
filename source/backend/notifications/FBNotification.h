//
//  FBNotification.h
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NotificationManager.h"
#import "FBObject.h"


@interface FBNotification : FBObject {
  NotificationManager* manager;
  NSURL*               href;
}

@property(retain) NSURL* href;

+ (FBNotification*)notificationWithXMLNode:(NSXMLNode*)node
                                   manager:(NotificationManager*)mngr;

- (id)initWithXMLNode:(NSXMLNode*)node
              manager:(NotificationManager*)mngr;

- (void)markAsReadWithSimilar:(BOOL)markSimilar;

@end
