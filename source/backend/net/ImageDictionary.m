//
//  ImageDictionary.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 8/19/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "ImageDictionary.h"
#import "NSString+.h"


@implementation ImageDictionary

-(id) initWithBackupImage:(NSImage*)img allowUpdates:(BOOL)updates
{
  self = [super init];
  if (self) {
    images        = [[NSMutableDictionary alloc] init];
    urls          = [[NSMutableDictionary alloc] init];
    backup        = [img retain];
    allowUpdates  = updates;
  }
  return self;
}

-(void) dealloc
{
  [images release];
  [urls   release];
  [backup release];
  [super dealloc];
}

-(void) setImageURL:(NSString*)url forKey:(NSString*)key
{
  if (![NSString exists:url]) {
    return;
  }
  if ([urls objectForKey:key] != nil &&
      ([[urls objectForKey:key] isEqual:url] || !allowUpdates)) {
    return;
  }

  [urls setObject:url forKey:key];
  NSImage* image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
  [images setObject:image forKey:key];
  [image release];
}

-(void) setImageFile:(NSString*)file forKey:(NSString*)key {
  if (![NSString exists:file]) {
    return;
  }
  if ([urls objectForKey:key] != nil &&
      ([[urls objectForKey:key] isEqual:file] || !allowUpdates)) {
    return;
  }

  [urls setObject:file forKey:key];
  NSImage* image = [[NSImage alloc] initByReferencingFile:file];
  [images setObject:image forKey:key];
  [image release];
}

-(NSString*) urlForKey:(NSString*)key
{
  return [urls objectForKey:key];
}

-(NSImage*) imageForKey:(NSString*)key
{
  NSImage* image = [images objectForKey:key];
  if (image == nil) {
    image = backup;
  }
  return image;
}

-(void) setBackupImage:(NSImage *)image
{
  backup = image;
}

-(NSImage*) backupImage
{
  return backup;
}

@end
