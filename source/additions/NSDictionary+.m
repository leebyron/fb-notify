//
//  NSDictionary+.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 9/8/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "NSDictionary+.h"
#import "NSString+.h"


@implementation NSDictionary (Additions)

- (NSString*)uidForKey:(NSString*)key
{
  NSString* obj = [self objectForKey:key];
  if ([obj isKindOfClass:[NSNull class]] || obj == nil) {
    return nil;
  }
  if (![obj isKindOfClass:[NSString class]] && [obj respondsToSelector:@selector(stringValue)]) {
    obj = [(id)obj stringValue];
  }
  if (![NSString exists:obj]) {
    return nil;
  }
  return obj;
}

- (NSString*)stringForKey:(NSString*)key
{
  return [[self uidForKey:key] stringByDecodingXMLEntities];
}

- (int)intForKey:(NSString*)key
{
  return [[self objectForKey:key] intValue];
}

- (BOOL)boolForKey:(NSString*)key
{
  return [self intForKey:key] != 0;
}

- (NSURL*)urlForKey:(NSString*)key
{
  return [NSURL URLWithString:[self stringForKey:key]];
}

@end
