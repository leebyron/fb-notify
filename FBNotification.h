//
//  FBNotification.h
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FBNotification : NSObject {
  NSMutableDictionary *fields;
}

+ (FBNotification *)notificationWithXMLNode:(NSXMLNode *)node;
- (id)initWithXMLNode:(NSXMLNode *)node;

- (void)markAsRead;
- (NSString *)uidForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;
- (NSURL *)urlForKey:(NSString *)key;

@end
