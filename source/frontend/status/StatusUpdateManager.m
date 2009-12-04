//
//  StatusUpdateManager.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 11/9/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "StatusUpdateManager.h"
#import "StatusUpdateWindow.h"
#import "FacebookNotifierController.h"
#import "PhotoAttachmentView.h"
#import "LinkAttachmentView.h"
#import "BubbleManager.h"
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

- (BOOL)appendString:(NSString*)string
{
  if (![StatusUpdateWindow currentWindow]) {
    [StatusUpdateWindow open];
  }

  [[StatusUpdateWindow currentWindow] appendString:string];
  return YES;
}

- (BOOL)attachPhoto:(NSImage*)image
{
  if (![StatusUpdateWindow currentWindow]) {
    [StatusUpdateWindow open];
  }

  NSView* attachment = [StatusUpdateWindow currentWindow].attachment;

  // if something else is attached, bail.
  if (attachment && ![attachment isKindOfClass:[PhotoAttachmentView class]]) {
    return NO;
  }

  // if nothing is attached, attach an image attachment
  PhotoAttachmentView* photoAttachment = (PhotoAttachmentView*)attachment;
  if (photoAttachment == nil) {
    photoAttachment = [[[PhotoAttachmentView alloc] init] autorelease];
    [StatusUpdateWindow currentWindow].attachment = photoAttachment;
  }

  // set the image here
  photoAttachment.image = image;
  return YES;
}

- (BOOL)attachLink:(NSURL*)link
{
  if (![StatusUpdateWindow currentWindow]) {
    [StatusUpdateWindow open];
  }

  NSView* attachment = [StatusUpdateWindow currentWindow].attachment;

  // if something else is attached, bail.
  if (attachment &&
      (![[attachment class] isKindOfClass:[LinkAttachmentView class]] ||
       ((LinkAttachmentView*)attachment).link != nil)) {
    return NO;
  }

  // attach an link attachment
  LinkAttachmentView* linkAttachment = [[[LinkAttachmentView alloc] init] autorelease];
  [StatusUpdateWindow currentWindow].attachment = linkAttachment;
  linkAttachment.link = link;
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
  if ([post objectForKey:@"image_data"]) {

    self.lastUpdateRequest =
      [connectSession callMethod:@"photos.upload"
                   withArguments:[NSDictionary dictionaryWithObjectsAndKeys:[post objectForKey:@"message"], @"caption", nil]
                       withFiles:[NSArray arrayWithObject:[post objectForKey:@"image_data"]]
                          target:self
                        selector:@selector(statusUpdateWasPublished:)];

  } else if ([post objectForKey:@"link"]) {
    // get a new update request
    self.lastUpdateRequest =
    [connectSession callMethod:@"links.post"
                 withArguments:[NSDictionary dictionaryWithObjectsAndKeys:
                                [post objectForKey:@"message"], @"comment",
                                [post objectForKey:@"link"], @"url",
                                [post objectForKey:@"image_url"], @"image", nil]
                        target:self
                      selector:@selector(statusUpdateWasPublished:)];

  } else if ([[post objectForKey:@"message"] length] > 0) {
    // get a new update request
    self.lastUpdateRequest =
    [connectSession callMethod:@"status.set"
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
    NSLog(@"error: %@ %@", [req error], [[[req error] userInfo] objectForKey:kFBErrorMessageKey]);
    return;
  }

  ImageDictionary* profilePics = [((FacebookNotifierController*)[NSApp delegate]) profilePics];
  [[BubbleManager manager] addBubbleWithText:[[req userData] objectForKey:@"message"]
                                     subText:nil
                                       image:[profilePics imageForKey:[connectSession uid]]
                                      action:[NSURL URLWithString:[[MenuManager manager] profileURL]]];
}

@end
