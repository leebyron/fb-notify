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


@interface FBMessage (Private)

- (id)initWithDictionary:(NSDictionary*)dict manager:(MessageManager*)mngr;

@end


@implementation FBMessage

+ (FBMessage*)messageWithDictionary:(NSDictionary*)dict manager:(MessageManager*)mngr
{
  return [[self alloc] initWithDictionary:dict manager:mngr];
}

- (id)initWithDictionary:(NSDictionary*)dict manager:(MessageManager *)mngr
{
  self = [super initWithDictionary:dict];
  if (self) {
    manager = mngr;
  }
  return self;
}

- (void)markAsSeen
{
  [manager markAsSeen:self];
}

- (void)markAsRead
{
  [manager markAsRead:self];
}

- (NSString *)description {
  return [self uidForKey:@"thread_id"];
}

@end
