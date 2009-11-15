//
//  AsyncImage.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 11/11/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "AsyncImage.h"

#define kAsyncImageTimeout 10

@implementation AsyncImage

@synthesize delegate, image, error, url;

+ (AsyncImage*)imageByLoadingURL:(NSURL*)url
{
  return [[[AsyncImage alloc] initByLoadingURL:url] autorelease];
}

- (id)initByLoadingURL:(NSURL*)aUrl
{
  if (self = [super init]) {
    url = [aUrl retain];
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url
                                                       cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                   timeoutInterval:kAsyncImageTimeout];
    responseBuffer  = [[NSMutableData alloc] init];
    connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    self.image = [[[NSImage alloc] initWithSize:NSZeroSize] autorelease];
    isLoading = YES;

    // keep us around while we're loading
    [self retain];
  }
  return self;
}

- (void)dealloc
{
  [connection release];
  [responseBuffer release];
  [error release];
  [image release];
  [url release];
  [super dealloc];
}

- (BOOL)isLoaded
{
  return image != nil;
}

- (BOOL)isLoading
{
  return isLoading;
}

- (BOOL)isFail
{
  return !isLoading && image == nil;
}

- (void)cancel
{
  [connection cancel];
  isLoading = NO;
  [self release];
}

// NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)aData
{
  [responseBuffer appendData:aData];
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)err
{
  self.error = err;
  isLoading = NO;
  DELEGATE(self.delegate, @selector(imageFailed:));
  [self release];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
  isLoading = NO;
  self.image = [[[NSImage alloc] initWithData:responseBuffer] autorelease];
  if (!image) {
    DELEGATE(self.delegate, @selector(imageFailed:));
  } else {
    // TODO make an error here
    DELEGATE(self.delegate, @selector(imageHasData:));
  }
  [self release];
}

@end
