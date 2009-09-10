//
//  FBObject.h
//  FBDesktopNotifications
//
//  Created by Lee Byron on 8/19/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FBObject : NSObject {
  NSMutableDictionary* fields;
}

- (id)initWithDictionary:(NSDictionary*)dict;

- (void)setObject:(id)obj forKey:(NSString*)key;
- (id)objectForKey:(NSString*)key;

- (NSString*)uidForKey:(NSString*)key;
- (NSString*)stringForKey:(NSString*)key;
- (int)intForKey:(NSString*)key;
- (BOOL)boolForKey:(NSString*)key;
- (NSURL *)urlForKey:(NSString*)key;

@end
