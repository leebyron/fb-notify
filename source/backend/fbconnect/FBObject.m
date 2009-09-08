//
//  FBObject.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 8/19/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "FBObject.h"
#import "NSString+.h"

@implementation FBObject

- (id)initWithDictionary:(NSDictionary*)dict
{
  self = [super init];
  if (self) {
    fields = [dict retain];
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

- (NSString*)stringForKey:(NSString*)key
{
  NSString* obj = [fields objectForKey:key];
  if (![NSString exists:obj]) {
    return nil;
  }
  return [obj stringByDecodingXMLEntities];
}

- (int)integerForKey:(NSString*)key
{
  return [[self objectForKey:key] intValue];
}

- (BOOL)boolForKey:(NSString*)key
{
  return [[fields objectForKey:key] intValue] != 0;
}

- (NSURL*)urlForKey:(NSString*)key
{
  NSString* obj = [fields objectForKey:key];
  if (![NSString exists:obj]) {
    return nil;
  }
  return [NSURL URLWithString:obj];
}

@end
