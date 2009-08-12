//
//  FBNotification.h
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NotificationManager.h"

@interface FBNotification : NSObject {
  NotificationManager *manager;
  NSMutableDictionary *fields;

  NSURL *href;
}

@property(retain) NSURL *href;

+ (FBNotification *)notificationWithXMLNode:(NSXMLNode *)node manager:(NotificationManager *)mngr;
- (id)initWithXMLNode:(NSXMLNode *)node manager:(NotificationManager *)mngr;

- (void)markAsRead;
- (void)setObject:(id)obj forKey:(NSString *)key;
- (NSString *)objForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;
- (NSURL *)urlForKey:(NSString *)key;

@end
