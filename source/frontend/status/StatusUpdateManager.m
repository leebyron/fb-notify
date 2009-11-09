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
#import "GlobalSession.h"


@implementation StatusUpdateManager

static StatusUpdateManager* manager;

@synthesize lastStatusUpdate, lastUpdateRequest;

+ (StatusUpdateManager*)manager
{
  if (!manager) {
    manager = [[StatusUpdateManager alloc] init];
  }
  return manager;
}

- (void)dealloc
{
  [lastStatusUpdate release];
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

- (void)sendPost:(NSDictionary*)post
{
  // get status message.
  self.lastStatusUpdate = [[StatusUpdateWindow currentWindow] statusMessage]; // = post.message

  // get a new update request
  self.lastUpdateRequest =
  [connectSession callMethod:@"status.set"//@"stream.publish"
               withArguments:[NSDictionary dictionaryWithObjectsAndKeys:lastStatusUpdate, @"status", nil]
                      target:self
                    selector:@selector(statusUpdateWasPublished:)
                       error:nil];

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

- (void)statusUpdateWasPublished:(id)reply
{
  // TODO HALP!
  /*
   [bubbleManager addBubbleWithText:lastStatusUpdate
   subText:nil
   image:[profilePics imageForKey:[connectSession uid]]
   action:[NSURL URLWithString:[menu profileURL]]];
   */
}

@end
