//
//  NotificationManager.h
//  Facebook
//
//  Created by Lee Byron on 7/29/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HashArray.h"


@class FBNotification;

@interface NotificationManager : NSObject {
  HashArray*    all;
  NSMutableSet* unread;
  NSMutableSet* unseen;
  int           mostRecentUpdateTime;
}

@property(retain) HashArray* all;

- (NSArray*)addNotificationsWithArray:(NSArray*)array;

- (NSArray*)unread;
- (int)count;
- (int)unreadCount;
- (int)unseenCount;
- (int)mostRecentUpdateTime;

- (void)markAsSeen:(FBNotification*)notif;
- (void)markAllSeen;

/*!
 * Marking as Read will also mark as Seen.
 */
- (void)markAsRead:(FBNotification*)notif withSimilar:(BOOL)similar;
- (void)markAllRead;

- (void)clear;

@end
