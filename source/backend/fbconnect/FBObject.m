//
//  FBObject.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 8/19/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "FBObject.h"
#import "NSDictionary+.h"


@implementation FBObject

- (id)initWithDictionary:(NSDictionary*)dict
{
  self = [super init];
  if (self) {
    fields = [[dict mutableCopy] retain];
  }
  return self;
}

- (void)dealloc
{
  [fields release];
  [super dealloc];
}

- (void)setObject:(id)obj forKey:(NSString*)key
{
  [fields setObject:obj forKey:key];
}

- (id)objectForKey:(NSString*)key
{
  return [fields objectForKey:key];
}

- (NSString*)uidForKey:(NSString*)key
{
  return [fields uidForKey:key];
}

- (NSString*)stringForKey:(NSString*)key
{
  return [fields stringForKey:key];
}

- (int)intForKey:(NSString*)key
{
  return [fields intForKey:key];
}

- (BOOL)boolForKey:(NSString*)key
{
  return [fields boolForKey:key];
}

- (NSURL*)urlForKey:(NSString*)key
{
  return [fields urlForKey:key];
}

@end
