//
//  FBPreferenceManager.h
//  FBDesktopNotifications
//
//  Created by Lee Byron on 12/3/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FBPreferenceManager : NSObject {
  NSMutableDictionary* defaults;
  NSMutableDictionary* preferences;
}

+ (FBPreferenceManager*)manager;

- (void)registerForKey:(NSString*)aKey
          defaultValue:(id)val;

- (void)synchronize;

- (id)objectForKey:(NSString*)aKey;
- (int)intForKey:(NSString*)aKey;
- (float)floatForKey:(NSString*)aKey;
- (BOOL)boolForKey:(NSString*)aKey;

- (void)setObject:(id)value forKey:(NSString*)aKey;
- (void)setInt:(int)value forKey:(NSString*)aKey;
- (void)setFloat:(float)value forKey:(NSString*)aKey;
- (void)setBool:(BOOL)value forKey:(NSString*)aKey;

@end
