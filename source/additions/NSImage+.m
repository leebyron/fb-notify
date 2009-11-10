//
//  NSImage.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 9/20/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "NSImage+.h"


@implementation NSImage (Additions)

+ (NSImage*)bundlePNG:(NSString*)imageName
{
  return [[[NSImage alloc] initByReferencingFile:
           [[NSBundle mainBundle] pathForResource:imageName
                                           ofType:@"png"]] autorelease];
}

- (void)resizeToFit:(NSSize)size
          usingMode:(NSImageScaling)scale
{
  CGFloat rx, ry, r;
  NSSize imageSize = [self size];
  
  switch (scale) {
    default:
    case NSScaleProportionally:
      rx = size.width / imageSize.width;
      ry = size.height / imageSize.height;
      r = MIN(1, (rx < ry ? rx : ry));
      imageSize.width *= r;
      imageSize.height *= r;
      [self setSize:imageSize];
      break;
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5
    case NSImageScaleProportionallyUpOrDown:
      rx = size.width / imageSize.width;
      ry = size.height / imageSize.height;
      r = rx < ry ? rx : ry;
      imageSize.width *= r;
      imageSize.height *= r;
      [self setSize:imageSize];
      break;
#endif
    case NSScaleToFit:
      imageSize = size;
      [self setSize:imageSize];
      break;
    case NSScaleNone:
      break;
  }
}

@end
