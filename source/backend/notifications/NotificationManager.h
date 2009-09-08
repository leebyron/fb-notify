//
//  NotificationManager.h
//  Facebook
//
//  Created by Lee Byron on 7/29/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NotificationManager : NSObject {
  NSMutableDictionary*  allDict;
  NSMutableArray*       allNotifications;
  NSMutableArray*       unreadNotifications;
  int                   mostRecentUpdateTime;
}

@property(retain) NSMutableArray* allNotifications;
@property(retain) NSMutableArray* unreadNotifications;

-(NSArray*)addNotificationsWithArray:(NSArray*)array;
-(int)unreadCount;
-(int)mostRecentUpdateTime;
-(NSArray*)notificationsWithTarget:(NSURL*)url;

@end
