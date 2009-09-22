//
//  NSEvent+.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 9/20/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "NSEvent+.h"


@implementation NSEvent (Additions)

- (BOOL)isKey:(NSString*)k modifiers:(NSUInteger)m
{
  return [[[self charactersIgnoringModifiers] lowercaseString] isEqualToString:k] &&
         ([self modifierFlags] & NSDeviceIndependentModifierFlagsMask) == m;
}

- (BOOL)isKeyCode:(unsigned short)code modifiers:(NSUInteger)m
{
  return [self keyCode] == code &&
         ([self modifierFlags] & NSDeviceIndependentModifierFlagsMask) == m;
}

@end
