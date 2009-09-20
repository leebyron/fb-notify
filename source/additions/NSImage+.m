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

@end
