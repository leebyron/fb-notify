//
//  NSPasteBoard.h
//  FBDesktopNotifications
//
//  Created by Lee Byron on 11/9/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kImagePBoardTypes ([NSArray arrayWithObjects:NSFilenamesPboardType, NSTIFFPboardType, nil])
#define kImageFilenames ([NSSet setWithObjects:@"jpg", @"jpeg", @"gif", @"png", @"psd", @"tga", @"tiff", @"tif", @"pdf", nil])

#define kLinkPBoardTypes ([NSArray arrayWithObjects:NSURLPboardType, NSStringPboardType, nil])

#define kStringPBoardTypes ([NSArray arrayWithObjects:NSStringPboardType, nil])


@interface NSPasteboard (Additions)

- (BOOL)hasImage;
- (NSImage*)getImage;

- (BOOL)hasLink;
- (BOOL)hasMoreThanLink; // true if the paste included more text
- (NSURL*)getLink;

- (BOOL)hasString;
- (NSString*)getString;

@end
