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

-(NSArray*)addMessagesFromXML:(NSXMLNode*)xml
{
  // remember the new messages
  NSMutableArray* newMessages = [[[NSMutableArray alloc] init] autorelease];

  for (NSXMLNode* node in [xml children]) {
    FBMessage* message = [FBMessage messageWithXMLNode:node manager:self];

    NSString* threadID = [message objectForKey:@"thread_id"];
    FBMessage* existingMessage = [allDict objectForKey:threadID];

    if (existingMessage) {
      if (![[existingMessage objectForKey:@"updated_time"] isEqual:[message objectForKey:@"updated_time"]]) {
        [newMessages addObject:message];
      }
      [allMessages removeObject:existingMessage];
      if ([existingMessage boolForKey:@"unread"]) {
        [unreadMessages removeObject:existingMessage];
      }
      [allDict removeObjectForKey:threadID];
    } else {
      [newMessages addObject:message];
    }

    [allDict setObject:message forKey:threadID];
    [allMessages addObject:message];
    if ([message boolForKey:@"unread"]) {
      [unreadMessages addObject:message];
    }

    // at this point we need to sort allMessages based on latest time
    [allMessages sortUsingFunction:sortMessages context:@"updated_time"];

    // update most recent time
    mostRecentUpdateTime = MAX(mostRecentUpdateTime,
                               [[message objectForKey:@"updated_time"] intValue]);
  }
  return newMessages;
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
