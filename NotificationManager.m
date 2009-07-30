//
//  NotificationManager.m
//  Facebook
//
//  Created by Lee Byron on 7/29/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "NotificationManager.h"
#import "FBNotification.h"

@implementation NotificationManager

@synthesize allNotifications, unreadNotifications;

-(id)init
{
  self = [super init];
  if (self) {
    allDict = [[NSMutableDictionary alloc] init];
    allNotifications = [[NSMutableArray alloc] init];
    unreadNotifications = [[NSMutableArray alloc] init];
    mostRecentUpdateTime = 0;
  }
  return self;
}

- (void)dealloc
{
  [allDict release];
  [allNotifications release];
  [unreadNotifications release];
  [super dealloc];
}

-(NSMutableArray *)addNotificationsFromXML:(NSXMLNode *)xml
{
  // remember the new notifications
  NSMutableArray *newNotifications = [[[NSMutableArray alloc] init] autorelease];

  for (NSXMLNode *node in [xml children]) {
    
    FBNotification *notification = [FBNotification notificationWithXMLNode:node manager:self];
    if ([notification boolForKey:@"isHidden"]) {
      continue;
    }
    
    NSString *notificationID = [notification uidForKey:@"notificationId"];
    FBNotification *existingNotification = [allDict objectForKey:notificationID];

    if (existingNotification == nil) {

      [allDict setObject:notification forKey:notificationID];
      [allNotifications addObject:notification];
      [newNotifications addObject:notification];

      if ([notification boolForKey:@"isUnread"]) {
        [unreadNotifications addObject:notification];
      }

    } else {

      // remove it from the unread list if its been read on fb
      if (![notification boolForKey:@"isUnread"] &&
          [existingNotification boolForKey:@"isUnread"]) {
        [allNotifications removeObject:existingNotification];
        [unreadNotifications removeObject:existingNotification];
        [allNotifications addObject:notification];
      }
    }
    
    // update most recent time
    mostRecentUpdateTime = MAX(mostRecentUpdateTime,
                               [[notification uidForKey:@"updatedTime"] intValue]);
  }

  return newNotifications;
}

-(int)unreadCount {
  return [unreadNotifications count];
}

-(int)mostRecentUpdateTime {
  return mostRecentUpdateTime;
}

@end
