//
//  ImageDictionary.h
//  FBDesktopNotifications
//
//  Created by Lee Byron on 8/19/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ImageDictionary : NSObject {
  NSMutableDictionary*  images;
  NSMutableDictionary*  urls;
  NSImage*              backup;
  BOOL                  allowUpdates;
}

-(id) initWithBackupImage:(NSImage*)img allowUpdates:(BOOL)updates;

-(void) setImageURL:(NSString*)url forKey:(NSString*)key;
-(void) setImageFile:(NSString*)file forKey:(NSString*)key;
-(NSString*) urlForKey:(NSString*)key;
-(NSImage*) imageForKey:(NSString*)key;
-(void) setBackupImage:(NSImage *)image;
-(NSImage*) backupImage;

@end
