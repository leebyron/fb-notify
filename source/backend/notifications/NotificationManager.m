//
//  NotificationManager.m
//  Facebook
//
//  Created by Lee Byron on 7/29/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "NotificationManager.h"
#import "FBNotification.h"
#import "GlobalSession.h"
#import "NSDictionary+.h"


@interface NotificationManager (Private)
-(NSArray*)unreadNotificationsWithTarget:(NSURL*)url;
@end


@implementation NotificationManager

@synthesize all;

-(id)init
{
  self = [super init];
  if (self) {
    all     = [[HashArray alloc] init];
    unread  = [[NSMutableSet alloc] init];
    unseen  = [[NSMutableSet alloc] init];
    mostRecentUpdateTime = 0;
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

-(NSArray*)addNotificationsWithArray:(NSArray*)array
{
  // remember the new notifications
  NSMutableArray* newNotifications = [[[NSMutableArray alloc] init] autorelease];
  
  // by definition of the query, this array should contain all currently unread
  // notifications, if one is missing it has been deleted and should removed
  NSMutableSet* verifiedSet = [[[NSMutableSet alloc] init] autorelease];
  NSMutableSet* existingSet = [[[NSMutableSet alloc] initWithSet:unread] autorelease];
  for (NSDictionary* node in array) {
    [verifiedSet addObject:[node uidForKey:@"notification_id"]];
  }
  [existingSet minusSet:verifiedSet];
  for (NSString* notificationID in existingSet) {
    [all removeObjectForKey:notificationID];
    [unread removeObject:notificationID];
    [unseen removeObject:notificationID];
  }

  // for each returned object, decide what to do with it
  for (NSDictionary* node in array) {
    FBNotification* notification = [FBNotification notificationWithDictionary:node manager:self];
    NSString* notificationID = [notification uidForKey:@"notification_id"];
    FBNotification* existingNotification = [all objectForKey:notificationID];

    if ([notification boolForKey:@"is_hidden"]) {
      // if there is an existing notification, remove it from all sets
      if (existingNotification != nil) {
        [all removeObjectForKey:notificationID];
        [unseen removeObject:notificationID];
        [unread removeObject:notificationID];
      }
    } else if (existingNotification == nil) {
      // add to all sets
      [all setObject:notification forKey:notificationID];
      [newNotifications addObject:notification];

      // add to the unread set if applicable
      if ([notification boolForKey:@"is_unread"]) {
        [unseen addObject:notificationID];
        [unread addObject:notificationID];
      }
    } else if (![notification boolForKey:@"is_unread"] &&
               [existingNotification boolForKey:@"is_unread"]) {
      // its been read on fb (but not here yet)

      // remove from the unread and unseen sets
      [unread removeObject:notificationID];
      [unseen removeObject:notificationID];

      // replace existing with new notification
      [all setObject:notification forKey:notificationID];
    }

    // update most recent time
    mostRecentUpdateTime = MAX(mostRecentUpdateTime, [notification intForKey:@"updated_time"]);

    [notification release];
  }

  return newNotifications;
}

-(NSArray*)unread
{
  return [unread allObjects];
}

-(int)unreadCount {
  return [unread count];
}

-(int)unseenCount {
  return [unseen count];
}

-(int)mostRecentUpdateTime {
  return mostRecentUpdateTime;
}

-(NSArray*)unreadNotificationsWithTarget:(NSURL*)url
{
  NSMutableArray *hasTarget = [[[NSMutableArray alloc] init] autorelease];

  for (NSString* notificationID in unread) {
    FBNotification* notif = [all objectForKey:notificationID];
    if ([url isEqual:[notif href]]) {
      [hasTarget addObject:notif];
    }
  }

  return hasTarget;
}

-(void)markAsSeen:(FBNotification*)notif
{
  [unseen removeObject:[notif uidForKey:@"notification_id"]];
}

-(void)markAllSeen
{
  [unseen removeAllObjects];
}

-(void)markAsRead:(FBNotification*)notif withSimilar:(BOOL)similar
{
  NSArray* notifs;
  if (similar) {
    notifs = [self unreadNotificationsWithTarget:[notif href]];
  } else {
    notifs = [NSArray arrayWithObject:notif];
  }
  if ([notifs count] == 0) {
    return;
  }

  for (NSString* notificationID in notifs) {
    [[all objectForKey:notificationID] setObject:@"0" forKey:@"is_unread"];
    [unread removeObject:notificationID];
    [unseen removeObject:notificationID];
  }
  [connectSession callMethod:@"notifications.markRead"
               withArguments:[NSDictionary dictionaryWithObject:[notifs componentsJoinedByString:@","]
                                                         forKey:@"notification_ids"]
                      target:self
                    selector:nil
                       error:@selector(markReadError:)];
  [[NSApp delegate] invalidate];
}

-(void)markAllRead
{
  for (NSString* notificationID in unread) {
    [[all objectForKey:notificationID] setObject:@"0" forKey:@"is_unread"];
  }
  [connectSession callMethod:@"notifications.markRead"
               withArguments:[NSDictionary dictionaryWithObject:[[unread allObjects] componentsJoinedByString:@","]
                                                         forKey:@"notification_ids"]
                      target:self
                    selector:nil
                       error:@selector(markReadError:)];
  [unread removeAllObjects];
  [unseen removeAllObjects];
  [[NSApp delegate] invalidate];
}

- (void)markReadError:(NSError*)error
{
  NSLog(@"mark as read failed -> %@", [[error userInfo] objectForKey:kFBErrorMessageKey]);
}

@end
