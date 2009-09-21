//
//  NSEvent+.h
//  FBDesktopNotifications
//
//  Created by Lee Byron on 9/20/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSEvent (Additions)

/*!
 * Returns YES if this event is a key event with this key and modifiers
 */
- (BOOL)isKey:(NSString*)k modifiers:(NSUInteger)m;
- (BOOL)isKeyCode:(unsigned short)code modifiers:(NSUInteger)m;

@end
