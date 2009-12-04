//
//  NSDictionary+.h
//  FBDesktopNotifications
//
//  Created by Lee Byron on 9/8/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSDictionary (Additions)

- (NSString*)uidForKey:(NSString*)key;
- (NSString*)stringForKey:(NSString*)key;
- (int)intForKey:(NSString*)key;
- (BOOL)boolForKey:(NSString*)key;
- (NSURL*)urlForKey:(NSString*)key;

@end
