//
//  ApplicationController.m
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import "secret.h" // defines kAppKey and kAppSecret. Fill in for your own app!

#import "ApplicationController.h"
#import "BubbleWindow.h"
#import "FBNotification.h"
#import "GlobalSession.h"
#import "StatusUpdateWindow.h"
#import "NotificationResponder.h"
#import <Carbon/Carbon.h>
#import <QuartzCore/QuartzCore.h>
#import <ApplicationServices/ApplicationServices.h>

#define kQueryInterval 30
#define kRetryQueryInterval 60

#define kSilhouettePic @"http://static.ak.fbcdn.net/pics/q_silhouette.gif"
#define kInfoQueryName @"info"
#define kInfoQueryFmt @"SELECT name, profile_url, pic_square FROM user WHERE uid = %@"
#define kNotifQueryName @"notif"
#define kNotifQueryFmt @"SELECT notification_id, sender_id, recipient_id, " \
  @"created_time, updated_time, title_html, title_text, body_html, body_text, " \
  @"href, app_id, is_unread, is_hidden FROM notification "\
  @"WHERE recipient_id = %@ AND ((is_unread = 0 AND notification_id IN (%@)) OR updated_time > %i) " \
  @"ORDER BY created_time ASC"
#define kChainedPicQueryName @"pic"
#define kChainedPicQueryFmt @"SELECT uid, pic_square FROM user WHERE uid IN (" \
  @"SELECT sender_id FROM #%@)"
#define kChainedAppIconQueryName @"app_icon"
#define kChainedAppIconQueryFmt @"SELECT app_id, icon_url FROM application WHERE app_id IN (" \
  @"SELECT app_id FROM #%@)"

FBConnect *connectSession;

@interface ApplicationController (Private)

- (IBAction)beginUpdateStatus:(id)sender;

@end


@implementation ApplicationController

- (id)init
{
  self = [super init];
  if (self) {
    connectSession = [FBConnect sessionWithAPIKey:kAppKey
                                           secret:kAppSecret
                                         delegate:self];
    notifications = [[NotificationManager alloc] init];
    bubbleManager = [[BubbleManager alloc] init];
    profilePics   = [[NSMutableDictionary alloc] init];
    menu          = [[MenuManager alloc] init];

    hasInitialLoad = NO;
  }
  return self;
}

- (void)dealloc
{
  if (silhouette != nil) {
    [silhouette release];
  }
  [connectSession release];
  [notifications release];
  [bubbleManager release];
  [menu release];
  [profilePics release];
  [statusUpdateWindow release];
  [super dealloc];
}

// Global hot key reciever
OSStatus globalHotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData)
{
  [[NSApp delegate] beginUpdateStatus:nil];
  return noErr;
}

- (void)awakeFromNib
{
  //create a carbon event handler for a global hot key
  EventHotKeyRef globalStatusUpdateHotKeyRef;
  EventHotKeyID  globalStatusUpdateHotKeyID;
  globalStatusUpdateHotKeyID.signature = 'fbs1';
  globalStatusUpdateHotKeyID.id        = 1;
  EventTypeSpec  eventType;
  eventType.eventClass = kEventClassKeyboard;
  eventType.eventKind  = kEventHotKeyPressed;
  InstallApplicationEventHandler(&globalHotKeyHandler, 1, &eventType, NULL, NULL);

  // register our hot key: control + option + command + space
  RegisterEventHotKey(49, cmdKey + optionKey + controlKey, globalStatusUpdateHotKeyID,
                      GetApplicationEventTarget(), 0, &globalStatusUpdateHotKeyRef);

  // login to facebook!
  [connectSession loginWithPermissions:[NSArray arrayWithObjects:@"manage_mailbox", @"publish_stream", nil]];
}

#pragma mark IBActions
- (IBAction)menuShowNewsFeed:(id)sender
{
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.facebook.com/home.php"]];
}

- (IBAction)menuShowProfile:(id)sender
{
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[[sender representedObject] profileURL]]];
}

- (IBAction)beginUpdateStatus:(id)sender
{
  if ([connectSession isLoggedIn]) {
    if (statusUpdateWindow) {
      if ([statusUpdateWindow isClosed]) {
        [statusUpdateWindow release];
        statusUpdateWindow = nil;
      } else {
        return;
      }
    }
    statusUpdateWindow = [[StatusUpdateWindow alloc] initWithTarget:self selector:@selector(didStatusUpdate:)];
  }
}

- (IBAction)menuShowNotification:(id)sender
{
  FBNotification *notification = [sender representedObject];
  [self readNotification:notification];
}

- (IBAction)menuShowAllNotifications:(id)sender
{
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.facebook.com/notifications.php"]];
}

- (IBAction)logout:(id)sender
{
  [connectSession logout];
}

#pragma mark Private methods
- (void)readNotification:(FBNotification *)notification
{
  // mark this notification as read
  [self markNotificationAsRead:notification withSimilar:YES];

  // load action url
  NSURL *url = [notification href];
  [[NSWorkspace sharedWorkspace] openURL:url];
}

- (void)markNotificationAsRead:(FBNotification *)notification withSimilar:(BOOL)markSimilar
{
  [notification markAsReadWithSimilar:markSimilar];
  [menu setIconByAreUnread:[notifications unreadCount] > 0];
  [menu constructWithNotifications:[notifications allNotifications]];
}

- (void)query
{
  NSMutableArray *unreadIDs = [[NSMutableArray alloc] init];
  for (FBNotification *notification in [notifications unreadNotifications]) {
    [unreadIDs addObject:[notification objForKey:@"notificationId"]];
  }
  NSString *unreadIDsList = [unreadIDs componentsJoinedByString:@","];
  [unreadIDs release];

  NSString *notifQuery = [NSString stringWithFormat:kNotifQueryFmt,
                          [connectSession uid],
                          unreadIDsList,
                          [notifications mostRecentUpdateTime]];
  NSString *picQuery = [NSString stringWithFormat:kChainedPicQueryFmt, kNotifQueryName];
  
  NSString *appIconQuery = [NSString stringWithFormat:kChainedAppIconQueryFmt, kNotifQueryName];

  NSDictionary *multiQuery;
  if ([menu profileURL] == nil) {
    NSString *infoQuery = [NSString stringWithFormat:kInfoQueryFmt, [connectSession uid]];
    multiQuery = [NSDictionary dictionaryWithObjectsAndKeys:infoQuery,
                  kInfoQueryName, notifQuery, kNotifQueryName,
                  picQuery, kChainedPicQueryName, appIconQuery, kChainedAppIconQueryName, nil];
  } else {
    multiQuery = [NSDictionary dictionaryWithObjectsAndKeys:notifQuery,
                  kNotifQueryName, picQuery, kChainedPicQueryName, appIconQuery, kChainedAppIconQueryName, nil];
  }

  [connectSession sendFQLMultiquery:multiQuery
                        target:self
                      selector:@selector(completedMultiquery:)
                         error:@selector(failedMultiquery:)];
}

- (void)processAppIcons:(NSXMLNode *)fqlResultSet
{
  for (NSXMLNode *xml in [fqlResultSet children]) {
    NSString *appID = [[xml childWithName:@"app_id"] stringValue];
    NSString *iconUrl = [[xml childWithName:@"icon_url"] stringValue];
    if ([iconUrl length] > 0) {
      if ([[menu appIcons] objectForKey:appID] == nil) {
        NSURL *url = [NSURL URLWithString:iconUrl];
        NSImage *icon = [[NSImage alloc] initWithContentsOfURL:url];
        [[menu appIcons] setObject:icon forKey:appID];
        [icon release];
      }
    }
  }
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
      if ([profilePics objectForKey:uid] == nil) {
        NSURL *url = [NSURL URLWithString:picUrl];
        NSImage *pic = [[NSImage alloc] initWithContentsOfURL:url];
        [profilePics setObject:pic forKey:uid];
        [pic release];
      }
    }
  }
}

- (void)processNotifications:(NSXMLNode *)fqlResultSet
{
  NSArray *newNotifications = [notifications addNotificationsFromXML:fqlResultSet];

  if (hasInitialLoad) {
    for (FBNotification *notification in newNotifications) {
      if ([notification boolForKey:@"isUnread"]) {
        NSImage *pic = [profilePics objectForKey:[notification objForKey:@"senderId"]];
        [bubbleManager addBubbleWithText:[notification stringForKey:@"titleText"]
                                   image:pic
                            notification:notification];
      }
    }
  }

  [menu setIconByAreUnread:[notifications unreadCount] > 0];
  [menu constructWithNotifications:[notifications allNotifications]];
}

#pragma mark Session delegate methods
- (void)completedMultiquery:(NSXMLDocument *)response
{
  //NSLog(@"%@", response);
  NSXMLNode *node = [response rootElement];
  while (node != nil && ![[node name] isEqualToString:@"fql_result"]) {
    node = [node nextNode];
  }

  NSXMLNode *notificationsNode = nil;
  NSXMLNode *picsNode = nil;
  NSXMLNode *appIconsNode = nil;
  while (node) {
    NSXMLNode *nameNode = [node childWithName:@"name"];
    NSXMLNode *resultSetNode = [node childWithName:@"fql_result_set"];

    if ([[nameNode stringValue] isEqualToString:kInfoQueryName]) {
      NSXMLNode *user = [resultSetNode childWithName:@"user"];
      userPic = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[[user childWithName:@"pic_square"] stringValue]]];
      [menu setName:[[user childWithName:@"name"] stringValue]
         profileURL:[[user childWithName:@"profile_url"] stringValue]
            userPic:userPic];
    } else if ([[nameNode stringValue] isEqualToString:kNotifQueryName]) {
      notificationsNode = resultSetNode;
    } else if ([[nameNode stringValue] isEqualToString:kChainedPicQueryName]) {
      picsNode = resultSetNode;
    } else if ([[nameNode stringValue] isEqualToString:kChainedAppIconQueryName]) {
      appIconsNode = resultSetNode;
    }
    node = [node nextSibling];
  }
  [self processAppIcons:appIconsNode];
  [self processPics:picsNode];
  [self processNotifications:notificationsNode];

  // get ready to query again shortly...
  [self performSelector:@selector(query) withObject:nil afterDelay:kQueryInterval];
  hasInitialLoad = YES;
}

- (void)failedMultiquery:(NSError *)error
{
  NSLog(@"multiquery failed -> %@", [[error userInfo] objectForKey:kFBErrorMessageKey]);
  
  // get ready to query again in a reasonable amount of time
  [self performSelector:@selector(query) withObject:nil afterDelay:kRetryQueryInterval];
}

- (void)FBConnectLoggedIn:(FBConnect *)fbc
{
  NSLog(@"must have logged in okay!");
  [bubbleManager addBubbleWithText:@"Welcome to Facebook Notifications!"
                             image:nil
                      notification:nil];
  [self query];
}

- (void)didStatusUpdate:(id)sender
{
  lastStatusUpdate = [sender statusMessage];
  [connectSession callMethod:@"Stream.publish"
               withArguments:[NSDictionary dictionaryWithObjectsAndKeys:lastStatusUpdate, @"message", nil]
                      target:self
                    selector:@selector(statusUpdateWasPublished:)
                       error:nil];
}

- (void)statusUpdateWasPublished:(NSXMLDocument *)reply
{
  [bubbleManager addBubbleWithText:lastStatusUpdate
                             image:userPic
                      notification:nil];
}

- (void)FBConnectLoggedOut:(FBConnect *)fbc
{
  NSLog(@"loggin out, gunna quit");
  [NSApp terminate:self];
}

- (void)FBConnectErrorLoggingIn:(FBConnect *)fbc
{
  NSLog(@"shit, couldn't connect");
  [NSApp terminate:self];
}


- (void)session:(FBConnect *)session failedCallMethod:(NSError *)error
{
  NSLog(@"callMethod: failed -> %@", [[error userInfo] objectForKey:kFBErrorMessageKey]);
}

@end
