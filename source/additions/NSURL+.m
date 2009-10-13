//
//  NSURL+.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 10/12/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "NSURL+.h"


@implementation NSURL (Additions)

- (NSString*)withoutFragment
{
  NSString* urlBase = [self absoluteString];
  NSRange fragment = [urlBase rangeOfString:@"#"];
  if (fragment.location != NSNotFound) {
    urlBase = [urlBase substringToIndex:fragment.location];
  }
  return urlBase;
}

@end
