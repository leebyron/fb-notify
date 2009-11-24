//
//  MessageManager.m
//  Facebook
//
//  Created by Lee Byron on 8/13/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "MessageManager.h"
#import "FBMessage.h"
#import "GlobalSession.h"
#import "NSDictionary+.h"


NSComparisonResult sortMessages(id firstItem, id secondItem, void *context);

@implementation MessageManager

@synthesize all;

- (id)init
{
  self = [super init];
  if (self) {
    all     = [[HashArray alloc] init];
    unread  = [[NSMutableSet alloc] init];
    unseen  = [[NSMutableSet alloc] init];
    mostRecentUpdateTime  = 0;
  }
  return self;
}

- (void)dealloc
{
  [all    release];
  [unread release];
  [unseen release];
  [super  dealloc];
}

- (NSArray*)addMessagesWithArray:(NSArray*)array
{
  // remember the new messages
  NSMutableArray* newMessages = [[[NSMutableArray alloc] init] autorelease];

  for (NSDictionary* msg in array) {
    FBMessage* message = [FBMessage messageWithDictionary:msg manager:self];
    NSString* threadID = [message uidForKey:@"thread_id"];
    FBMessage* existingMessage = [all objectForKey:threadID];

    if (existingMessage == nil) {
      // add to all sets
      [newMessages addObject:message];

      // add to the unread set if applicable
      if ([message boolForKey:@"unread"]) {
        [unseen addObject:threadID];
        [unread addObject:threadID];
      }
    } else {
      // if recently updated, mark as unseen
      if ([existingMessage intForKey:@"updated_time"] != [message intForKey:@"updated_time"]) {
        [newMessages addObject:message];
        [unseen addObject:threadID];
      }

      // if unread status changed...
      if ([existingMessage boolForKey:@"unread"] != [message boolForKey:@"unread"]) {
        if ([message boolForKey:@"unread"]) {
          [unread addObject:threadID];
        } else {
          [unread removeObject:threadID];
          [unseen removeObject:threadID];
        }
      }
    }

    // replace existing message
    [all setObject:message forKey:threadID];

    // update most recent time
    mostRecentUpdateTime = MAX(mostRecentUpdateTime, [message intForKey:@"updated_time"]);

    [message release];
  }

  // at this point we need to sort allMessages based on latest time
  [all sortUsingFunction:sortMessages context:@"updated_time"];

  return newMessages;
}

- (void)verifyMessagesWithArray:(NSArray*)array
{
  // make a set with incoming array
  NSMutableSet* verifiedSet = [[[NSMutableSet alloc] init] autorelease];
  for (NSDictionary* msg in array) {
    [verifiedSet addObject:[msg uidForKey:@"thread_id"]];
  }

  // make a set with existing list
  NSMutableSet* existingSet = [[[NSMutableSet alloc] init] autorelease];
  for (NSString* threadID in all) {
    [existingSet addObject:threadID];
  }

  // find members of the existing set which do not exist in the verified set
  [existingSet minusSet:verifiedSet];

  // remove these members
  for (NSString* threadID in existingSet) {
    [all removeObjectForKey:threadID];
    [unread removeObject:threadID];
    [unseen removeObject:threadID];
  }

  // iterate through array, updating unread status
  for (NSDictionary* msg in array) {
    NSString* threadID = [msg uidForKey:@"thread_id"];
    FBMessage* existingMessage = [all objectForKey:threadID];

    // if unread status changed...
    if ([existingMessage boolForKey:@"unread"] != [msg boolForKey:@"unread"]) {
      if ([msg boolForKey:@"unread"]) {
        [unread addObject:threadID];
        [existingMessage setObject:@"1" forKey:@"unread"];
      } else {
        [unread removeObject:threadID];
        [unseen removeObject:threadID];
        [existingMessage setObject:@"0" forKey:@"unread"];
      }
    }
  }
}

NSComparisonResult sortMessages(id firstItem, id secondItem, void *context) {
  int a = [firstItem intForKey:context];
  int b = [secondItem intForKey:context];

  if (a < b) {
    return NSOrderedAscending;
  } else if (a > b) {
    return NSOrderedDescending;
  }
  return NSOrderedSame;
}

- (NSArray*)unread
{
  return [unread allObjects];
}

- (int)count {
  return [all count];
}

- (int)unreadCount {
  return [unread count];
}

- (int)unseenCount {
  return [unseen count];
}

- (int)mostRecentUpdateTime {
  return mostRecentUpdateTime;
}

- (void)markAsSeen:(FBMessage*)msg
{
  [unseen removeObject:[msg uidForKey:@"thread_id"]];
}

- (void)markAllSeen
{
  [unseen removeAllObjects];
}

- (void)markAsRead:(FBMessage*)msg
{
  [msg setObject:@"0" forKey:@"unread"];
  [unread removeObject:[msg uidForKey:@"thread_id"]];
  [unseen removeObject:[msg uidForKey:@"thread_id"]];

  [connectSession callMethod:@"message.setThreadReadStatus"
               withArguments:[NSDictionary dictionaryWithObjectsAndKeys:[msg objectForKey:@"thread_id"], @"thread_id",
                                                                        @"-1", @"status",
                                                                        [connectSession uid], @"uid", nil] //TODO - do i need uid?!
                      target:self
                    selector:@selector(markReadError:)];
  [[NSApp delegate] invalidate];
}

- (void)markReadError:(id<FBRequest>)req
{
  if ([req error]) {
    NSLog(@"mark as read failed -> %@", [[[req error] userInfo] objectForKey:kFBErrorMessageKey]);
  }
}

- (void)clear
{
  [all removeAllObjects];
  [unread removeAllObjects];
  [unseen removeAllObjects];
  mostRecentUpdateTime = 0;
}

@end
