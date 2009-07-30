//
//  ApplicationController.m
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import "secret.h"
#import "ApplicationController.h"
#import "BubbleWindow.h"
#import "FBNotification.h"
#import <QuartzCore/QuartzCore.h>
#import <ApplicationServices/ApplicationServices.h>

#define kSilhouettePic @"http://static.ak.fbcdn.net/pics/q_silhouette.gif"
#define kInfoQueryName @"info"
#define kInfoQueryFmt @"SELECT name, profile_url FROM user WHERE uid = %@"
#define kNotifQueryName @"notif"
#define kNotifQueryFmt @"SELECT notification_id, sender_id, recipient_id," \
  @"created_time, updated_time, title_html, title_text, body_html, body_text," \
  @"href, app_id, is_unread, is_hidden FROM notification WHERE recipient_id = %@"
#define kChainedPicQueryName @"pic"
#define kChainedPicQueryFmt @"SELECT uid, pic_square FROM user WHERE uid IN (" \
  @"SELECT sender_id FROM #%@)"

@implementation ApplicationController

- (id)init
{
  self = [super init];
  if (self) {
    fbSession = [[FBSession alloc] initWithAPIKey:kAppKey
                                           secret:kAppSecret
                                         delegate:self];
    [fbSession setPersistentSessionUserDefaultsKey:@"PersistentSession"];
    notificationMenuItems = [[NSMutableArray alloc] init];
    bubbleManager = [[BubbleManager alloc] init];
    profilePics = [[NSMutableDictionary alloc] init];
    menu = [[MenuManager alloc] init];
  }
  return self;
}

- (void)dealloc
{
  [fbSession release];
  [notificationMenuItems release];
  [profilePics release];
  [menu release];
  [super dealloc];
}

- (void)awakeFromNib
{
  [fbSession startLogin];
}

#pragma mark IBActions
- (IBAction)menuShowNewsFeed:(id)sender
{
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.facebook.com/"]];
}

- (IBAction)menuShowProfile:(id)sender
{
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[[sender representedObject] profileURL]]];
}

- (IBAction)menuShowNotification:(id)sender
{
  FBNotification *notification = [sender representedObject];
  NSURL *url = [notification urlForKey:@"href"];
  [[NSWorkspace sharedWorkspace] openURL:url];
}

#pragma mark Private methods
- (void)processPics:(NSXMLNode *)fqlResultSet
{
  for (NSXMLNode *xml in [fqlResultSet children]) {
    NSString *uid = [[xml childWithName:@"uid"] stringValue];
    NSString *picUrl = [[xml childWithName:@"pic_square"] stringValue];
    if ([picUrl length] == 0) {
      if (silhouette == nil) {
        NSURL *url = [NSURL URLWithString:kSilhouettePic];
        silhouette = [[NSImage alloc] initWithContentsOfURL:url];
      }
      [profilePics setObject:silhouette forKey:uid];
    } else {
      NSURL *url = [NSURL URLWithString:picUrl];
      NSImage *pic = [[NSImage alloc] initWithContentsOfURL:url];
      [profilePics setObject:pic forKey:uid];
      [pic release];
    }
  }
  [silhouette release];
}

- (void)processNotifications:(NSXMLNode *)fqlResultSet
{
  BOOL areUnread = NO;
  for (NSXMLNode *xml in [fqlResultSet children]) {

    FBNotification *notification = [FBNotification notificationWithXMLNode:xml];
    if ([notification boolForKey:@"isHidden"]) {
      continue;
    }

    if ([notification boolForKey:@"isUnread"]) {
      areUnread = YES;
      NSImage *pic = [profilePics objectForKey:[notification uidForKey:@"senderId"]];
      [bubbleManager addBubbleWithText:[notification stringForKey:@"titleText"]
                                 image:pic
                              duration:20.0];
    }

    [notificationMenuItems addObject:notification];
  }

  [menu setIconByAreUnread:areUnread];
  [menu constructWithNotifications:notificationMenuItems];
}

#pragma mark Session delegate methods
- (void)sessionCompletedLogin:(FBSession *)s
{
  NSString *infoQuery = [NSString stringWithFormat:kInfoQueryFmt, [s uid]];
  NSString *notifQuery = [NSString stringWithFormat:kNotifQueryFmt, [s uid]];
  NSString *picQuery = [NSString stringWithFormat:kChainedPicQueryFmt, kNotifQueryName];

  [fbSession sendFQLMultiquery:[NSDictionary dictionaryWithObjectsAndKeys:infoQuery,
                                kInfoQueryName, notifQuery, kNotifQueryName,
                                picQuery, kChainedPicQueryName, nil]];
  [bubbleManager addBubbleWithText:@"Welcome to Facebook Notifications!"
                             image:nil
                          duration:10.0];
}

- (void)session:(FBSession *)session completedMultiquery:(NSXMLDocument *)response
{
  NSLog(@"%@", response);
  NSXMLNode *node = [response rootElement];
  while (![[node name] isEqualToString:@"fql_result"]) {
    node = [node nextNode];
  }

  NSXMLNode *notificationsNode = nil;
  NSXMLNode *picsNode = nil;
  while (node) {
    NSXMLNode *nameNode = [node childWithName:@"name"];
    NSXMLNode *resultSetNode = [node childWithName:@"fql_result_set"];

    if ([[nameNode stringValue] isEqualToString:kInfoQueryName]) {
      NSXMLNode *user = [resultSetNode childWithName:@"user"];
      [menu setName:[[user childWithName:@"name"] stringValue]
         profileURL:[[user childWithName:@"profile_url"] stringValue]];
    } else if ([[nameNode stringValue] isEqualToString:kNotifQueryName]) {
      notificationsNode = resultSetNode;
    } else if ([[nameNode stringValue] isEqualToString:kChainedPicQueryName]) {
      picsNode = resultSetNode;
    }
    node = [node nextSibling];
  }
  [self processPics:picsNode];
  [self processNotifications:notificationsNode];
}

- (void)session:(FBSession *)session failedMultiquery:(NSError *)error
{
  NSLog(@"%@", [[error userInfo] objectForKey:kFBErrorMessageKey]);
}

@end
