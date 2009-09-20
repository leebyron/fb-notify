//
//  HashArray.h
//  FBDesktopNotifications
//
//  Created by Lee Byron on 9/18/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
 * HashArray
 * A combination of a dictionary and array. You can use this as a sorted
 * dictionary or an array with keys. Allows for insert O(1), access O(1),
 * query O(1), remove O(n), sort O(nlogn)
 * Uses NSFastEnumeration, for(* in *) queries the keys of the dictionary in the
 * order of the array.
 *
 * @author leebyron
 */
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
