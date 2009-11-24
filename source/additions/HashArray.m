//
//  HashArray.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 9/18/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "HashArray.h"


@interface HashArrayNode : NSObject {
  id         obj;
  id         key;
  NSUInteger index;
}
@property(retain) id obj;
@property(retain) id key;
- (id)initWithObject:(id)object key:(id)aKey index:(NSUInteger)i;
- (NSUInteger)index;
- (void)setIndex:(NSUInteger)i;
@end

@implementation HashArrayNode
@synthesize obj, key;
- (id)initWithObject:(id)object key:(id)aKey index:(NSUInteger)i
{
  self = [super init];
  if (self) {
    obj   = [object retain];
    key   = [aKey retain];
    index = i;
  }
  return self;
}

- (void)dealloc
{
  [obj release];
  [key release];
  [super dealloc];
}

- (NSUInteger)index {
  return index;
}

- (void)setIndex:(NSUInteger)i {
  index = i;
}
@end


typedef struct
{
  NSInteger (*func)(id, id, void*);
  void* context;
} HashArraySortContext;

NSComparisonResult sortHashArrayList(id firstItem, id secondItem, void* context) {
  return ((HashArraySortContext*)context)->func([firstItem obj],
                                                [secondItem obj],
                                                ((HashArraySortContext*)context)->context);
}

@interface HashArray (Private)
- (void)repairReferencesStartingAt:(NSUInteger)index;
@end


@implementation HashArray

- (id)init
{
  self = [super init];
  if (self) {
    list = [[NSMutableArray alloc] init];
    hash = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)dealloc
{
  [self removeAllObjects];
  [list release];
  [hash release];
  [super dealloc];
}


- (NSUInteger)count
{
  return [list count];
}

- (id)objectAtIndex:(NSUInteger)index
{
  return [[list objectAtIndex:index] obj];
}

- (id)objectForKey:(id)aKey
{
  return [[hash objectForKey:aKey] obj];
}

- (id)keyAtIndex:(NSUInteger)index
{
  return [[list objectAtIndex:index] key];
}

- (NSUInteger)indexForKey:(id)aKey
{
  return [[hash objectForKey:aKey] index];
}

- (BOOL)containsKey:(id)aKey
{
  return [hash objectForKey:aKey] != nil;
}

- (void)setObject:(id)obj forKey:(id)aKey
{
  [aKey retain];
  if ([self containsKey:aKey]) {
    [self removeObjectForKey:aKey];
  }

  HashArrayNode* node = [[HashArrayNode alloc] initWithObject:obj key:aKey index:[self count]];

  [list addObject:(id)node];
  [hash setObject:(id)node forKey:aKey];
  [node release];
  [aKey release];
}

- (void)setObject:(id)obj forKey:(id)aKey atIndex:(NSUInteger)index
{
  [aKey retain];
  if ([self containsKey:aKey]) {
    if ([self indexForKey:aKey] < index) {
      index--;
    }
    [self removeObjectForKey:aKey];
  }

  HashArrayNode* node = [[HashArrayNode alloc] initWithObject:obj key:aKey index:index];

  [list insertObject:(id)node atIndex:index];
  [hash setObject:(id)node forKey:aKey];
  [self repairReferencesStartingAt:(index + 1)];
  [node release];
  [aKey release];
}

- (void)removeAllObjects
{
  [list removeAllObjects];
  [hash removeAllObjects];
}

- (void)removeObjectForKey:(id)aKey
{
  [self removeObjectAtIndex:[self indexForKey:aKey]];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
  HashArrayNode* node = [list objectAtIndex:index];
  [list removeObjectAtIndex:index];
  [hash removeObjectForKey:[node key]];
  [self repairReferencesStartingAt:index];
}

- (void)sortUsingFunction:(NSInteger (*)(id, id, void *))compare context:(void *)context
{
  HashArraySortContext* ctx = malloc(sizeof(HashArraySortContext));
  ctx->func = compare;
  ctx->context = context;
  [list sortUsingFunction:sortHashArrayList context:ctx];
  [self repairReferencesStartingAt:0];
  free(ctx);
}



#pragma mark Private
- (void)repairReferencesStartingAt:(NSUInteger)index
{
  NSUInteger length = [self count];
  for (NSUInteger i = index; i < length; i++) {
    [[list objectAtIndex:i] setIndex:i];
  }
}

// Enumeration just enumerates the list.
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id *)stackbuf
                                    count:(NSUInteger)len
{
  NSUInteger batchCount = 0;
  NSUInteger currentNode = state->state;
  NSUInteger listLength = [self count];
  while (batchCount < len && currentNode < listLength) {
    stackbuf[batchCount] = [self keyAtIndex:currentNode];
    batchCount++;
    currentNode++;
  }

  state->itemsPtr = stackbuf;
  state->state = currentNode;
  state->mutationsPtr = (unsigned long *)self;

  return batchCount;
}

@end
