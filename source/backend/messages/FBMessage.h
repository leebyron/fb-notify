//
//  FBMessage.h
//  Facebook
//
//  Created by Lee Byron on 8/13/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MessageManager.h"


@interface FBMessage : NSObject {
  MessageManager *manager;
  NSMutableDictionary *fields;
}

+ (FBMessage *)messageWithXMLNode:(NSXMLNode *)node manager:(MessageManager *)mngr;
- (id)initWithXMLNode:(NSXMLNode *)node manager:(MessageManager *)mngr;

- (void)markAsRead;
- (void)setObject:(id)obj forKey:(NSString *)key;
- (NSString *)objForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;
- (NSURL *)urlForKey:(NSString *)key;

@end
