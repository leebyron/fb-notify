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

+ (FBNotification*)notificationWithDictionary:(NSDictionary*)dict
                                      manager:(NotificationManager*)mngr;

- (void)markAsSeen;
- (void)markAsReadWithSimilar:(BOOL)markSimilar;

@end
