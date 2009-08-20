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

- (id)initWithXMLNode:(NSXMLNode *)node
{
  self = [super init];
  if (self) {
    fields = [[NSMutableDictionary alloc] init];
    for (NSXMLElement *child in [node children]) {
      // skip nil values
      if ([[[child attributeForName:@"nil"] stringValue] isEqualToString:@"true"]) {
        continue;
      }
      [fields setObject:[child stringValue] forKey:[child name]];
    }
  }
  return self;
}

- (void)dealloc
{
  [fields release];
  [super dealloc];
}

- (void)setObject:(id)obj forKey:(NSString *)key
{
  [fields setObject:obj forKey:key];
}

- (NSString *)objectForKey:(NSString *)key
{
  return [fields objectForKey:key];
}

- (NSString *)stringForKey:(NSString *)key
{
  NSString *obj = [fields objectForKey:key];
  if (obj == nil) {
    return nil;
  }
  return [obj stringByDecodingXMLEntities];
}

- (BOOL)boolForKey:(NSString *)key
{
  return ![[fields objectForKey:key] isEqualToString:@"0"];
}

- (NSURL *)urlForKey:(NSString *)key
{
  return [NSURL URLWithString:[fields objectForKey:key]];
}

@end
