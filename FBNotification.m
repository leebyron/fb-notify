//
//  FBNotification.m
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import "FBNotification.h"
#import "NSString-XML.h"

@implementation FBNotification

+ (FBNotification *)notificationWithXMLNode:(NSXMLNode *)node
{
  return [[[self alloc] initWithXMLNode:node] autorelease];
}

- (id)initWithXMLNode:(NSXMLNode *)node
{
  self = [super init];
  if (self) {
    fields = [[NSMutableDictionary alloc] init];
    for (NSXMLNode *child in [node children]) {
      // Convert from underscore_words to camelCase
      NSArray *words = [[child name] componentsSeparatedByString:@"_"];
      NSMutableString *key = [NSMutableString stringWithString:[words objectAtIndex:0]];
      int i;
      for (i = 1; i < [words count]; i++) {
        [key appendString:[[words objectAtIndex:i] capitalizedString]];
      }

      [fields setObject:[child stringValue] forKey:key];
    }
  }
  return self;
}

- (void)dealloc
{
  [fields release];
  [super dealloc];
}

- (void)markAsRead
{
  [fields setObject:@"0" forKey:@"isUnread"];
}

- (NSString *)uidForKey:(NSString *)key
{
  return [fields objectForKey:key];
}

- (NSString *)stringForKey:(NSString *)key
{
  return [[fields objectForKey:key] stringByDecodingXMLEntities];
}

- (BOOL)boolForKey:(NSString *)key
{
  return [[fields objectForKey:key] isEqualToString:@"1"];
}

- (NSURL *)urlForKey:(NSString *)key
{
  return [NSURL URLWithString:[fields objectForKey:key]];
}

@end
