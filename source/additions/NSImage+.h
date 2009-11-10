//
//  NSImage.h
//  FBDesktopNotifications
//
//  Created by Lee Byron on 9/20/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSImage (Additions)

+ (NSImage*)bundlePNG:(NSString*)imageName;

- (void)resizeToFit:(NSSize)size
          usingMode:(NSImageScaling)scale;

@end
