//
//  FBMessage.m
//  Facebook
//
//  Created by Lee Byron on 8/13/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "FBMessage.h"
#import "NSString-XML.h"
#import "GlobalSession.h"
#import <FBCocoa/FBCocoa.h>

@implementation FBMessage

+ (FBMessage *)messageWithXMLNode:(NSXMLNode *)node manager:(MessageManager *)mngr
{
  return [[[self alloc] initWithXMLNode:node manager:mngr] autorelease];
}

- (id)initWithXMLNode:(NSXMLNode *)node manager:(MessageManager *)mngr
{
  self = [super init];
  if (self) {
    manager = mngr;
    fields = [[NSMutableDictionary alloc] init];
    for (NSXMLElement *child in [node children]) {
      
      // skip nil values
      if ([[[child attributeForName:@"nil"] stringValue] isEqualToString:@"true"]) {
        continue;
      }
      
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
  [self setObject:@"0" forKey:@"unread"];
  [[manager unreadMessages] removeObject:self];

  [connectSession callMethod:@"message.setThreadReadStatus"
               withArguments:[NSDictionary dictionaryWithObjectsAndKeys:[self objForKey:@"threadId"], @"thread_id",
                                                                        @"0", @"status",
                                                                        [connectSession uid], @"uid", nil]
                      target:self
                    selector:nil
                       error:@selector(markReadError:)];
}

- (void)setObject:(id)obj forKey:(NSString *)key
{
  [fields setObject:obj forKey:key];
}

- (NSString *)objForKey:(NSString *)key
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
  return [[fields objectForKey:key] isEqualToString:@"1"];
}

- (NSURL *)urlForKey:(NSString *)key
{
  return [NSURL URLWithString:[fields objectForKey:key]];
}

#pragma mark Private methods
- (void)markReadError:(NSError *)error
{
  NSLog(@"mark message thread as read failed -> %@", [[error userInfo] objectForKey:kFBErrorMessageKey]);
}

- (NSString *)description {
  return [self objForKey:@"threadId"];
}

@end
