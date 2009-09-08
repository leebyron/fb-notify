//
//  MessageManager.m
//  Facebook
//
//  Created by Lee Byron on 8/13/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "MessageManager.h"
#import "FBMessage.h"

@implementation MessageManager

@synthesize allMessages, unreadMessages;

-(id)init
{
  self = [super init];
  if (self) {
    allDict               = [[NSMutableDictionary alloc] init];
    allMessages           = [[NSMutableArray alloc] init];
    unreadMessages        = [[NSMutableArray alloc] init];
    mostRecentUpdateTime  = 0;
  }
  return self;
}

- (void)dealloc
{
  [allDict        release];
  [allMessages    release];
  [unreadMessages release];
  [super dealloc];
}

-(NSArray*)addMessagesWithArray:(NSArray*)array
{
  // remember the new messages
  NSMutableArray* newMessages = [[[NSMutableArray alloc] init] autorelease];

  for (NSDictionary* msg in array) {
    FBMessage* message = [FBMessage messageWithDictionary:msg manager:self];

    NSString* threadID = [message objectForKey:@"thread_id"];
    FBMessage* existingMessage = [allDict objectForKey:threadID];

    if (existingMessage) {
      if (![[existingMessage objectForKey:@"updated_time"] isEqual:[message objectForKey:@"updated_time"]]) {
        [newMessages addObject:message];
      }
      [allMessages removeObject:existingMessage];
      [allDict removeObjectForKey:threadID];
    } else {
      [newMessages addObject:message];
    }

    [allDict setObject:message forKey:threadID];
    [allMessages addObject:message];

    // update most recent time
    mostRecentUpdateTime = MAX(mostRecentUpdateTime,
                               [[message objectForKey:@"updated_time"] intValue]);

    [message release];
  }

  // at this point we need to sort allMessages based on latest time
  [allMessages sortUsingFunction:sortMessages context:@"updated_time"];

  return newMessages;
}

-(void)verifyMessagesWithArray:(NSArray*)array
{
  // make a temporary dictionary of all messages:
  NSMutableDictionary* verifiedMessages = [[NSMutableDictionary alloc] init];
  for (NSDictionary* msg in array) {
    FBMessage* verifiedMessage = [FBMessage messageWithDictionary:msg manager:self];
    [verifiedMessages setObject:verifiedMessage forKey:[verifiedMessage objectForKey:@"thread_id"]];
    [verifiedMessage release];
  }

  // run through existing messages, updating status
  NSDictionary* allDictClone = [[NSDictionary alloc] initWithDictionary:allDict copyItems:NO];
  for (NSString* threadID in allDictClone) {

    FBMessage* existingMessage = [allDict objectForKey:threadID];
    FBMessage* verifiedMessage = [verifiedMessages objectForKey:threadID];

    // remove from unread, we'll add it back in if it needs to be
    [unreadMessages removeObject:existingMessage];

    // would be nil if it's been deleted
    if (verifiedMessage == nil) {
      [allDict removeObjectForKey:threadID];
      [allMessages removeObject:existingMessage];
    } else {
      // update unread status
      [existingMessage setObject:[verifiedMessage objectForKey:@"unread"] forKey:@"unread"];
      if ([verifiedMessage boolForKey:@"unread"]) {
        [unreadMessages addObject:existingMessage];
      }
    }
  }

  // release what we no longer need
  [allDictClone release];
  [verifiedMessages release];
}

NSComparisonResult sortMessages(id firstItem, id secondItem, void *context) {
  int a = [firstItem integerForKey:context];
  int b = [secondItem integerForKey:context];

  if (a < b) {
    return NSOrderedAscending;
  } else if (a > b) {
    return NSOrderedDescending;
  }
  return NSOrderedSame;
}

-(int)unreadCount {
  return [unreadMessages count];
}

-(int)mostRecentUpdateTime {
  return mostRecentUpdateTime;
}

@end
