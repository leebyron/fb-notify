//
//  NetConnection.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 8/19/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "NetConnection.h"
#import <ApplicationServices/ApplicationServices.h>

@interface NetConnection (Private)

- (BOOL)isNetworkConnected;
- (void)updateOnlineStatus:(NSNotification*)notif;

@end


@implementation NetConnection

static NetConnection* instance = nil;

+ (NetConnection*)netConnection
{
  if (instance == nil) {
    instance = [[NetConnection alloc] init];
  }
  return instance;
}

- (id)init
{
  self = [super init];
  if (self) {
    // are we presently online?
    isOnline  = [self isNetworkConnected];

    // check for future network connectivity changes
    systemConfigNotificationManager = [[IXSCNotificationManager alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateOnlineStatus:)
                                                 name:@"State:/Network/Global/IPv4"
                                               object:systemConfigNotificationManager];
  }
  return self;
}

- (void)dealloc
{
  [systemConfigNotificationManager release];
  [super dealloc];
}

- (BOOL)isOnline
{
  return isOnline;
}


#pragma mark Private Methods
- (BOOL)isNetworkConnected
{
  SCNetworkConnectionFlags status;
  Boolean success = SCNetworkCheckReachabilityByName("www.facebook.com", &status);
  success = success &&
            (status & kSCNetworkFlagsReachable) &&
            !(status & kSCNetworkFlagsConnectionRequired);

  if (!success) {
    SCNetworkConnectionFlags status;
    Boolean success = SCNetworkCheckReachabilityByName("www.apple.com", &status);
    success = success &&
              (status & kSCNetworkFlagsReachable) &&
              !(status & kSCNetworkFlagsConnectionRequired);
  }

  return success;
}

- (void)updateOnlineStatus:(NSNotification *)notif
{
  BOOL wasOnline = isOnline;
  isOnline = [notif userInfo] != nil;
  if (wasOnline != isOnline) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNetConnectionNotification
                                                        object:self];
  }
}

@end
