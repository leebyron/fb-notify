//
//  ApplicationController.m
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import "secret.h"
#import "NSString-XML.h"
#import "ApplicationController.h"
#import "BubbleWindow.h"
#import "FBNotification.h"
#import <QuartzCore/QuartzCore.h>
#import <ApplicationServices/ApplicationServices.h>

#define kMaxNotificationsInMenu 20
#define kMaxNotificationStringLen 60
#define kEllipsis @"\u2026"
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

enum {
  NEWS_FEED_LINK_TAG,
  PROFILE_LINK_TAG,
  LOGOUT_TAG,
  QUIT_TAG
};


@interface ApplicationController (Private)

- (void)constructMenu;
- (void)makeStatusItem;
- (void)addQuitItem;

@end


@implementation ApplicationController

@synthesize userName, profileURL;

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
  }
  return self;
}

- (void)dealloc
{
  [fbSession release];
  [statusItemMenu release];
  [notificationMenuItems release];
  [profilePics release];
  self.userName = nil;
  self.profileURL = nil;
  [super dealloc];
}

- (void)awakeFromNib
{
  [fbSession startLogin];
  [self makeStatusItem];
}


#pragma mark Private methods
- (void)constructMenu
{
  // remove old
  while ([statusItemMenu numberOfItems] > 0) {
    [statusItemMenu removeItemAtIndex:0];
  }

  // add new
  NSMenuItem *newsFeedItem = [[NSMenuItem alloc] initWithTitle:@"News Feed"
                                                        action:@selector(menuShowNewsFeed:)
                                                 keyEquivalent:@""];
  [newsFeedItem setTag:NEWS_FEED_LINK_TAG];
  [statusItemMenu addItem:newsFeedItem];
  [newsFeedItem release];

  NSMenuItem *profileItem = [[NSMenuItem alloc] initWithTitle:userName
                                                        action:@selector(menuShowProfile:)
                                                 keyEquivalent:@""];
  [profileItem setTag:PROFILE_LINK_TAG];
  [statusItemMenu addItem:profileItem];
  [profileItem release];

  [statusItemMenu addItem:[NSMenuItem separatorItem]];

  if ([notificationMenuItems count] > 0) {
    for (NSMenuItem *item in notificationMenuItems) {
      [statusItemMenu addItem:item];
    }

    [statusItemMenu addItem:[NSMenuItem separatorItem]];
  }
  
  NSMenuItem *logoutItem = [[NSMenuItem alloc] initWithTitle:@"Logout of Facebook"
                                                      action:@selector(logoutAndTerminate:)
                                               keyEquivalent:@""];
  [logoutItem setTag:LOGOUT_TAG];
  [statusItemMenu addItem:logoutItem];
  [logoutItem release];
  
  [self addQuitItem];
}

- (void)makeStatusItem
{
  NSStatusBar *bar = [NSStatusBar systemStatusBar];
  statusItem = [[bar statusItemWithLength:NSVariableStatusItemLength] retain];
  
  statusItemMenu = [[NSMenu alloc] init];

  [statusItem setMenu:statusItemMenu];
  [statusItem setHighlightMode:YES];
  [statusItem setTitle:@"F"];
  
  [self addQuitItem];
}

- (void)addQuitItem
{
  NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:@"Quit Facebook Notifications"
                                                    action:@selector(terminate:)
                                             keyEquivalent:@""];
  [quitItem setTag:QUIT_TAG];
  [statusItemMenu addItem:quitItem];
  [quitItem release];
}

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
  // display the latest few notifications in the menu
  int notifCount = 0;
  for (NSXMLNode *xml in [fqlResultSet children]) {
    if (notifCount++ >= kMaxNotificationsInMenu) {
      break;
    }

    FBNotification *notification = [FBNotification notificationWithXMLNode:xml];
    if ([[notification isHidden] isEqualToString:@"1"]) {
      continue;
    }

    NSString *title = [[notification titleText] stringByDecodingXMLEntities];
    if ([title length] > kMaxNotificationStringLen) {
      title = [[title substringToIndex:kMaxNotificationStringLen - 3] stringByAppendingString:kEllipsis];
    }
    if ([[notification isUnread] isEqualToString:@"1"]) {
      NSString *uid = [notification senderId];
      NSImage *pic = [profilePics objectForKey:uid];
      [bubbleManager addBubbleWithText:title image:pic duration:20.0];
    }

    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title
                                                  action:@selector(menuShowNotification:)
                                           keyEquivalent:@""];
    [item setRepresentedObject:notification];
    [notificationMenuItems addObject:item];
    [item release];
  }
}

#pragma mark IBActions
- (IBAction)menuShowNewsFeed:(id)sender
{
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.facebook.com/home.php"]];
}

- (IBAction)menuShowProfile:(id)sender
{
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:profileURL]];
}

- (IBAction)menuShowNotification:(id)sender
{
  FBNotification *notif = [sender representedObject];
  NSString *url = [notif href];
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

- (IBAction)logoutAndTerminate:(id)sender
{
  [fbSession logout];
  [NSApp terminate:self];
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
      self.userName = [[user childWithName:@"name"] stringValue];
      self.profileURL = [[user childWithName:@"profile_url"] stringValue];
    } else if ([[nameNode stringValue] isEqualToString:kNotifQueryName]) {
      notificationsNode = resultSetNode;
    } else if ([[nameNode stringValue] isEqualToString:kChainedPicQueryName]) {
      picsNode = resultSetNode;
    }
    node = [node nextSibling];
  }
  [self processPics:picsNode];
  [self processNotifications:notificationsNode];
  [self constructMenu];
}

- (void)session:(FBSession *)session failedMultiquery:(NSError *)error
{
  NSLog(@"%@", [[error userInfo] objectForKey:kFBErrorMessageKey]);
}

@end
