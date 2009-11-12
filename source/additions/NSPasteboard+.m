//
//  NSPasteBoard.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 11/9/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "NSPasteboard+.h"
#import "RegexKitLite.h"
#import "NSString+.h"

// optional http
// optional www
// alpha.num-domain.tld
// relative url not ending in punctuation
#define kLinkRegex @"(https?:\\/\\/)?" \
                   @"(www\\.)?" \
                   @"[+\\-\\.0-9A-Za-z]+(\\.[A-Za-z]{2,4})" \
                   @"(\\/[^\\s\\]\\)]*[^\\s\\.\\,\\]\\)])?"


@implementation NSPasteboard (Additions)

- (BOOL)hasImage
{
  NSString* type = [self availableTypeFromArray:kImagePBoardTypes];

  if (type == nil) {
    return NO;
  }

  if (type == NSFilenamesPboardType) {
    NSString* filename = [[[self stringForType:type] propertyList] objectAtIndex:0];
    if (![kImageFilenames containsObject:[filename pathExtension]]) {
      return NO;
    }
  }

  return YES;
}

- (NSImage*)getImage
{
  NSString* type = [self availableTypeFromArray:kImagePBoardTypes];

  // Try to make a Image from pasteboard
  NSImage* image = nil;

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


- (BOOL)hasLink
{
  NSString* type = [self availableTypeFromArray:kLinkPBoardTypes];

  if (type == nil) {
    return NO;
  }

  if (type == NSURLPboardType) {

    // no local files!
    NSString* url = [[[self stringForType:type] propertyList] objectAtIndex:0];
    NSRange fileUrl = [url rangeOfString:@"file://"];
    if (fileUrl.location != NSNotFound) {
      return NO;
    }

    return YES;
  }

  return [[self stringForType:type] isMatchedByRegex:kLinkRegex];
}

- (BOOL)hasMoreThanLink
{
  if (![self hasLink]) {
    return NO;
  }

  NSString* type = [self availableTypeFromArray:kLinkPBoardTypes];

  if (type == NSURLPboardType) {
    return NO;
  }

  // is there more than just the url in this pasted text?
  NSString* trimmedText = [[self stringForType:type] trim];
  NSRange linkRange = [trimmedText rangeOfRegex:kLinkRegex];
  return (linkRange.length < [trimmedText length]);
}

- (NSURL*)getLink
{
  NSString* type = [self availableTypeFromArray:kLinkPBoardTypes];
  NSString* linkString = nil;

  if (type == NSURLPboardType) {
    linkString = [[[self stringForType:type] propertyList] objectAtIndex:0];

    // don't return local links
    NSRange fileRange = [linkString rangeOfString:@"file://"];
    if (fileRange.location != NSNotFound) {
      return nil;
    }

  } else if (type == NSStringPboardType) {
    linkString = [[self stringForType:type] stringByMatching:kLinkRegex];
  }

  // links have to be at least 4 chars
  if (!linkString || [linkString length] <= 3) {
    return nil;
  }

  // always require a http://
  NSRange httpRange = [linkString rangeOfString:@"http://"];
  if (httpRange.location == NSNotFound) {
    linkString = [NSString stringWithFormat:@"http://%@", linkString];
  }

  return [NSURL URLWithString:linkString];
}

- (BOOL)hasString
{
  NSString* type = [self availableTypeFromArray:kLinkPBoardTypes];
  if (type == nil) {
    return NO;
  }

  // don't want to paste in plists
  NSString* string = [self stringForType:type];
  NSRange xmlRange = [string rangeOfString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
  if (xmlRange.location != NSNotFound) {
    return NO;
  }

  return YES;
}

- (NSString*)getString
{
  NSString* type = [self availableTypeFromArray:kLinkPBoardTypes];
  if (type == nil) {
    return nil;
  }

  // no plists!
  NSString* string = [self stringForType:type];
  NSRange xmlRange = [string rangeOfString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
  if (xmlRange.location != NSNotFound) {
    return nil;
  }

  return string;
}

@end
