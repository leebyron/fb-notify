//
//  NSShadow+.h
//  FBDesktopNotifications
//
//  Created by Lee Byron on 12/3/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSShadow (Additions)

- (id)initWithColor:(NSColor *)color
             offset:(NSSize)offset
         blurRadius:(CGFloat)blur;

@end
