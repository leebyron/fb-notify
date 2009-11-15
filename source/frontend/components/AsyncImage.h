//
//  AsyncImage.h
//  FBDesktopNotifications
//
//  Created by Lee Byron on 11/11/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AsyncImage;

@interface NSObject (AsyncImageDelegate)

- (void)imageHasData:(AsyncImage*)image;
- (void)imageFailed:(AsyncImage*)image;

@end


@interface AsyncImage : NSObject {
  id delegate;
  NSURL* url;
  NSURLConnection* connection;
  NSMutableData* responseBuffer;
  NSError* error;
  NSImage* image;
  BOOL isLoading;
}

@property(assign) id delegate;
@property(retain) NSError* error;
@property(retain) NSImage* image;
@property(readonly) NSURL* url;

+ (AsyncImage*)imageByLoadingURL:(NSURL*)aUrl;

- (id)initByLoadingURL:(NSURL*)url;
- (BOOL)isLoaded;
- (BOOL)isLoading;
- (BOOL)isFail;
- (void)cancel;

@end
