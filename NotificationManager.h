//
//  NotificationManager.h
//  Facebook
//
//  Created by Lee Byron on 7/29/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FBNotification.h"

@interface NotificationManager : NSObject {
  NSMutableDictionary *allDict;
  NSMutableArray *allNotifications;
  NSMutableArray *unreadNotifications;
  int mostRecentUpdateTime;
}

@property(retain) NSMutableArray *allNotifications;
@property(retain) NSMutableArray *unreadNotifications;

-(NSMutableArray *)addNotificationsFromXML:(NSXMLNode *)xml;
-(void)markAsRead:(FBNotification *)notification;
-(int)unreadCount;
-(int)mostRecentUpdateTime;

@end
