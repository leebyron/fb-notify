//
//  FBMessage.m
//  Facebook
//
//  Created by Lee Byron on 8/13/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "FBMessage.h"
#import "GlobalSession.h"
#import <FBCocoa/FBCocoa.h>

@implementation FBMessage

+ (FBMessage*)messageWithXMLNode:(NSXMLNode*)node manager:(MessageManager*)mngr
{
  return [[self alloc] initWithXMLNode:node manager:mngr];
}

- (id)initWithXMLNode:(NSXMLNode *)node manager:(MessageManager *)mngr
{
  self = [super initWithXMLNode:node];
  if (self) {
    manager = mngr;
  }
  return self;
}

- (void)markAsRead
{
  [self setObject:@"0" forKey:@"unread"];
  [[manager unreadMessages] removeObject:self];
  [[NSApp delegate] invalidate];

  [connectSession callMethod:@"message.setThreadReadStatus"
               withArguments:[NSDictionary dictionaryWithObjectsAndKeys:[self objectForKey:@"thread_id"], @"thread_id",
                                                                        @"-1", @"status",
                                                                        [connectSession uid], @"uid", nil]
                      target:self
                    selector:nil
                       error:@selector(markReadError:)];
}

#pragma mark Private methods
- (void)markReadError:(NSError *)error
{
  NSLog(@"mark message thread as read failed -> %@", [[error userInfo] objectForKey:kFBErrorMessageKey]);
}

- (NSString *)description {
  return [self objectForKey:@"thread_id"];
}

@end
