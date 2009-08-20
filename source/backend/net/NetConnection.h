//
//  NetConnection.h
//  FBDesktopNotifications
//
//  Created by Lee Byron on 8/19/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IXSCNotificationManager.h"


#define kNetConnectionNotification @"NetConnectionNotification"


@interface NetConnection : NSObject {
  IXSCNotificationManager* systemConfigNotificationManager;
  BOOL                     isOnline;
}

+ (NetConnection*)netConnection;

- (BOOL)isOnline;

@end
