//
//  HashArray.h
//  FBDesktopNotifications
//
//  Created by Lee Byron on 9/18/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface HashArray : NSObject <NSFastEnumeration> {
  NSMutableArray*      list;
  NSMutableDictionary* hash;
}

- (NSUInteger)count;

- (id)objectAtIndex:(NSUInteger)index;
- (id)objectForKey:(id)aKey;

- (id)keyAtIndex:(NSUInteger)index;
- (NSUInteger)indexForKey:(id)aKey;
- (BOOL)containsKey:(id)aKey;

- (void)setObject:(id)obj forKey:(id)aKey;
- (void)setObject:(id)obj forKey:(id)aKey atIndex:(NSUInteger)index;

- (void)removeAllObjects;
- (void)removeObjectForKey:(id)aKey;
- (void)removeObjectAtIndex:(NSUInteger)index;

- (void)sortUsingFunction:(NSInteger (*)(id, id, void *))compare context:(void *)context;

@end
