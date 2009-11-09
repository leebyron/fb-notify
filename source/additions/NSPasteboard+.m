//
//  NSPasteBoard.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 11/9/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "NSPasteboard+.h"


@implementation NSPasteboard (Additions)

- (BOOL)hasImage
{
  NSString *type = [self availableTypeFromArray:kImagePBoardTypes];

  if (type == nil) {
    return NO;
  }

  NSString* filename = [[[self stringForType:type] propertyList] objectAtIndex:0];
  if (type == NSFilenamesPboardType &&
      ![kImageFilenames containsObject:[filename pathExtension]]) {
    return NO;
  }

  return YES;
}

- (NSImage*)getImage
{
  NSString *type = [self availableTypeFromArray:kImagePBoardTypes];

  // Try to make a Image from pasteboard
  NSImage *image = nil;
  
  if (type == NSFilenamesPboardType) {
    NSString* filename = [[[self stringForType:type] propertyList] objectAtIndex:0];

    // test filename
    if ([kImageFilenames containsObject:[filename pathExtension]]) {
      image = [[NSImage alloc] initWithContentsOfFile:filename];
    }
  } else if (type == NSTIFFPboardType) {
    NSData* data = [self dataForType:type];
    image = [[NSImage alloc] initWithData:data];
  }

  // stage for release
  [image autorelease];

  return image;
}

@end
