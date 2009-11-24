//
//  MessageManager.h
//  Facebook
//
//  Created by Lee Byron on 8/13/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HashArray.h"


@class FBMessage;

@interface MessageManager : NSObject {
  HashArray*    all;
  NSMutableSet* unread;
  NSMutableSet* unseen;
  int           mostRecentUpdateTime;
}

@property(retain) HashArray* all;

- (NSArray*)addMessagesWithArray:(NSArray*)array;
- (void)verifyMessagesWithArray:(NSArray*)array;

- (NSArray*)unread;
- (int)count;
- (int)unreadCount;
- (int)unseenCount;
- (int)mostRecentUpdateTime;

- (void)markAsSeen:(FBMessage*)msg;
- (void)markAllSeen;

/*!
 * Marking as Read will also mark as Seen.
 */
- (void)markAsRead:(FBMessage*)msg;

- (void)clear;

@end
