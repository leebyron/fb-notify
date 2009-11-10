//
//  StatusUpdateManager.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 11/9/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "StatusUpdateManager.h"
#import "StatusUpdateWindow.h"
#import "PhotoAttachmentView.h"
#import "BubbleManager.h"
#import "ApplicationController.h"
#import "ImageDictionary.h"
#import "GlobalSession.h"
#import "NSImage+.h"


@implementation StatusUpdateManager

static StatusUpdateManager* manager = nil;

@synthesize lastUpdateRequest;

+ (StatusUpdateManager*)manager
{
  if (!manager) {
    manager = [[StatusUpdateManager alloc] init];
  }
  return manager;
}

- (void)dealloc
{
  [lastUpdateRequest release];
  [super dealloc];
}

- (BOOL)attachPhoto:(NSImage*)image
{
  if (![StatusUpdateWindow currentWindow]) {
    [StatusUpdateWindow open];
  }

  NSView* attachment = [StatusUpdateWindow currentWindow].attachment;

  // if something else is attached, bail.
  if (attachment && ![attachment isKindOfClass:[PhotoAttachmentView class]]) {
    NSLog(@"somethign else is attached");
    return NO;
  }

  // if nothing is attached, attach an image attachment
  if (attachment == nil) {
    [StatusUpdateWindow currentWindow].attachment = [[[PhotoAttachmentView alloc] initWithFrame:NSZeroRect] autorelease];
  }

  // set the image here
  ((PhotoAttachmentView*)[StatusUpdateWindow currentWindow].attachment).image = image;
  return YES;
}

- (void)removeAttachment
{
  if ([StatusUpdateWindow currentWindow]) {
    [StatusUpdateWindow currentWindow].attachment = nil;
  }
}

- (BOOL)sendPost:(NSDictionary*)post
{
  // determine type of api call
  if ([post objectForKey:@"image"]) {

    NSLog(@"image data: %@", post);

    self.lastUpdateRequest =
      [connectSession callMethod:@"photos.upload"
                   withArguments:[NSDictionary dictionaryWithObjectsAndKeys:[post objectForKey:@"message"], @"caption", nil]
                       withFiles:[NSArray arrayWithObject:[post objectForKey:@"image"]]
                          target:self
                        selector:@selector(statusUpdateWasPublished:)];

  } else if ([[post objectForKey:@"message"] length] > 0) {
    // get a new update request
    self.lastUpdateRequest =
      [connectSession callMethod:@"status.set"//@"stream.publish"
                   withArguments:[NSDictionary dictionaryWithObjectsAndKeys:[post objectForKey:@"message"], @"status", nil]
                          target:self
                        selector:@selector(statusUpdateWasPublished:)];
  } else {
    return NO;
  }

  [self.lastUpdateRequest setUserData:post];

  // if we don't have permission to do this, get the permission!
  if (![connectSession hasPermission:@"publish_stream"]) {
    [connectSession requestPermissions:[NSSet setWithObject:@"publish_stream"]
                                target:self
                              selector:@selector(statusPermissionResponse:)];
    [lastUpdateRequest cancel];
    [lastUpdateRequest retain];
  } else {
    lastUpdateRequest = nil;
  }

  return YES;
}

- (void)statusPermissionResponse:(NSSet*)acceptedPermissions
{
  // if the permission went through, try that publish again.
  if ([connectSession hasPermission:@"publish_stream"]) {
    [lastUpdateRequest retry];
    [lastUpdateRequest release];
    lastUpdateRequest = nil;
  }
}

- (void)statusUpdateWasPublished:(id<FBRequest>)req
{
  if ([req error]) {
    NSLog(@"error: %@", [req error]);
    return;
  }

  ImageDictionary* profilePics = [((ApplicationController*)[NSApp delegate]) profilePics];
  [[BubbleManager manager] addBubbleWithText:[[req userData] objectForKey:@"message"]
                                     subText:nil
                                       image:[profilePics imageForKey:[connectSession uid]]
                                      action:[NSURL URLWithString:[[MenuManager manager] profileURL]]];
}

@end
