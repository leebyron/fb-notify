/*
 *  NotificationResponder.h
 *  Facebook
 *
 *  Created by Lee Byron on 7/30/09.
 *  Copyright 2009 Facebook. All rights reserved.
 *
 */

#import "FBNotification.h"

@interface NSObject (Notifications)

- (void)readNotification:(FBNotification *)notification;
- (void)markNotificationAsRead:(FBNotification *)notification;

@end