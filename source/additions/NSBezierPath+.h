//
//  NSBezierPath+.h
//  FBDesktopNotifications
//
//  Created by Lee Byron on 11/7/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSBezierPath (Additions)

- (void)fillWithInnerShadow:(NSShadow *)shadow;

- (void)strokeInside;
- (void)strokeInsideWithinRect:(NSRect)clipRect;

@end
