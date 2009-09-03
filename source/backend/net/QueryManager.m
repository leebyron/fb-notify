//
//  QueryManager.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 8/19/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "QueryManager.h"
#import <FBCocoa/FBCocoa.h>
#import "ApplicationController.h"
#import "NetConnection.h"
#import "GlobalSession.h"
#import "PreferencesWindow.h"
#import "NSString+.h"


#define kQueryInterval 60
#define kRetryQueryInterval 60

#define kInfoQueryName @"info"
#define kInfoQueryFmt @"SELECT name, profile_url FROM user WHERE uid = %@"

#define kNotifQueryName @"notif"
#define kNotifQueryFmt @"SELECT notification_id, sender_id, recipient_id, " \
@"created_time, updated_time, title_html, title_text, body_html, body_text, " \
@"href, app_id, is_unread, is_hidden FROM notification "\
@"WHERE recipient_id = %@ AND ((is_unread = 0 AND notification_id IN (%@)) OR updated_time > %i) " \
@"ORDER BY created_time ASC"

#define kMessageQueryName @"messages"
#define kMessageQueryFmt @"SELECT thread_id, subject, snippet_author, snippet, unread, updated_time FROM thread " \
@"WHERE folder_id = 0 AND updated_time > %i"

#define kVerifyMessageQueryName @"verify_messages"
#define kVerifyMessageQueryFmt @"SELECT thread_id, unread FROM thread WHERE folder_id = 0"

#define kChainedPicQueryName @"pic"
#define kChainedPicQueryFmt @"SELECT uid, name, pic_square FROM user WHERE uid = %@ " \
@" OR uid IN (SELECT sender_id FROM #%@) OR uid IN (SELECT snippet_author FROM #%@)"

#define kChainedAppIconQueryName @"app_icon"
#define kChainedAppIconQueryFmt @"SELECT app_id, icon_url FROM application " \
@"WHERE app_id IN (SELECT app_id FROM #%@)"


@interface QueryManager (Private)

- (void)queryAfterDelay:(NSTimeInterval)delay;
- (void)query;
- (void)completedMultiquery:(NSXMLDocument*)response;
- (void)failedMultiquery:(NSError*)error;
- (void)processUserInfo:(NSXMLNode*)userInfo;
- (void)processAppIcons:(NSXMLNode*)fqlResultSet;
- (void)processPics:(NSXMLNode*)fqlResultSet;
- (void)processNotifications:(NSXMLNode*)fqlResultSet;
- (void)processMessages:(NSXMLNode*)fqlResultSet;
- (void)processVerifyMessages:(NSXMLNode*)fqlResultSet;

@end


@implementation QueryManager

-(id) initWithParent:(ApplicationController*)app
{
  self = [super init];
  if (self) {
    status    = QUERY_OFF;
    lastQuery = 0;
    parent    = app;
  }
  return self;
}

-(void) dealloc
{
  [queryTimer release];
  [super dealloc];
}

-(void) start
{
  [self query];
}

-(void) stop
{
  [queryTimer invalidate];
  queryTimer = nil;
  status = QUERY_OFF;
}


#pragma mark Private Methods
- (void)queryAfterDelay:(NSTimeInterval)delay
{
  if (queryTimer) {
    [queryTimer invalidate];
    [queryTimer release];
  }

  status = QUERY_DELAY_UNTIL_NEXT;
  queryTimer = [[NSTimer scheduledTimerWithTimeInterval:delay
                                                 target:self
                                               selector:@selector(query)
                                               userInfo:nil
                                                repeats:NO] retain];
  [[NSRunLoop currentRunLoop] addTimer:queryTimer forMode:NSDefaultRunLoopMode];
}

- (void)query
{
  // if we're not online, we shouldn't attempt a query.
  if (![[NetConnection netConnection] isOnline]) {
    return;
  }

  // release the wait timer
  if (queryTimer) {
    [queryTimer invalidate];
    [queryTimer release];
    queryTimer = nil;
  }

  // build queries
  NSString* unreadIDsList = [[[parent notifications] unreadNotifications] componentsJoinedByString:@","];
  NSString* notifQuery = [NSString stringWithFormat:kNotifQueryFmt,
                                                    [connectSession uid],
                                                    unreadIDsList,
                                                    [[parent notifications] mostRecentUpdateTime]];
  NSString* messageQuery = [NSString stringWithFormat:kMessageQueryFmt,
                                                      [[parent messages] mostRecentUpdateTime]];
  NSString* verifyMessageQuery = kVerifyMessageQueryFmt;
  NSString* picQuery = [NSString stringWithFormat:kChainedPicQueryFmt,
                                                  [connectSession uid],
                                                  kNotifQueryName,
                                                  kMessageQueryName];
  NSString* appIconQuery = [NSString stringWithFormat:kChainedAppIconQueryFmt,
                            kNotifQueryName];
  NSMutableDictionary* multiQuery =
  [NSMutableDictionary dictionaryWithObjectsAndKeys:notifQuery,   kNotifQueryName,
                                                    messageQuery, kMessageQueryName,
                                                    verifyMessageQuery, kVerifyMessageQueryName,
                                                    picQuery,     kChainedPicQueryName,
                                                    appIconQuery, kChainedAppIconQueryName, nil];
  if ([[parent menu] profileURL] == nil) {
    NSString* infoQuery = [NSString stringWithFormat:kInfoQueryFmt,
                                                     [connectSession uid]];
    [multiQuery setObject:infoQuery forKey:kInfoQueryName];
  }

  status = QUERY_WAITING_FOR_RESPONSE;
  [connectSession sendFQLMultiquery:multiQuery
                             target:self
                           selector:@selector(completedMultiquery:)
                              error:@selector(failedMultiquery:)];
}

- (void)completedMultiquery:(NSXMLDocument*)response
{
  // if we're not online, this must be bogus.
  if (![[NetConnection netConnection] isOnline]) {
    return;
  }

  // get ready to query again shortly...
  [self queryAfterDelay:kQueryInterval];

  NSDictionary* responses = [response parseMultiqueryResponse];

  [self processUserInfo:[responses objectForKey:kInfoQueryName]];
  [self processAppIcons:[responses objectForKey:kChainedAppIconQueryName]];
  [self processPics:[responses objectForKey:kChainedPicQueryName]];
  [self processNotifications:[responses objectForKey:kNotifQueryName]];
  [self processMessages:[responses objectForKey:kMessageQueryName]];
  [self processVerifyMessages:[responses objectForKey:kVerifyMessageQueryName]];

  [PreferencesWindow refresh];

  lastQuery = [[NSDate date] timeIntervalSince1970];
  [responses release];
  [[NSApp delegate] invalidate];
}

- (void)failedMultiquery:(NSError*)error
{
  // if we're not online, it's obvious that this would fail
  if (![[NetConnection netConnection] isOnline]) {
    return;
  }

  // get ready to query again in a reasonable amount of time, if we're logged in
  if ([connectSession isLoggedIn]) {
    [self queryAfterDelay:kRetryQueryInterval];
  }

  // let us know what happened
  if ([error code] > 0) {
    NSLog(@"multiquery failed (fb error:%i) -> %@",
          [error code],
          [[error userInfo] objectForKey:kFBErrorMessageKey]);
  } else {
    NSLog(@"multiquery failed (net error:%i) -> %@",
          [error code],
          [[[[error userInfo] objectForKey:NSUnderlyingErrorKey] userInfo] objectForKey:NSLocalizedDescriptionKey]);
  }

  NSLog(@"suspect: %@", [error userInfo]);
}

- (void)processUserInfo:(NSXMLNode*)userInfo
{
  if (userInfo == nil) {
    return;
  }
  userInfo = [userInfo childWithName:@"user"];
  [[parent menu] setUserName:[[userInfo childWithName:@"name"] stringValue]];
  [[parent menu] setProfileURL:[[userInfo childWithName:@"profile_url"] stringValue]];
}

- (void)processAppIcons:(NSXMLNode*)fqlResultSet
{
  for (NSXMLNode* xml in [fqlResultSet children]) {
    NSString* appID   = [[xml childWithName:@"app_id"] stringValue];
    NSString* iconUrl = [[xml childWithName:@"icon_url"] stringValue];
    if (iconUrl != nil && [iconUrl length] != 0) {
      [[parent appIcons] setImageURL:iconUrl forKey:appID];
    }
  }
}

- (void)processPics:(NSXMLNode*)fqlResultSet
{
  for (NSXMLNode* xml in [fqlResultSet children]) {
    NSString* uid    = [[xml childWithName:@"uid"] stringValue];
    NSString* name   = [[[xml childWithName:@"name"] stringValue] stringByDecodingXMLEntities];
    if (name != nil && [name length] != 0) {
      [[parent names] setObject:name forKey:uid];
    }
    NSString* picUrl = [[xml childWithName:@"pic_square"] stringValue];
    if (picUrl != nil && [picUrl length] != 0) {
      [[parent profilePics] setImageURL:picUrl forKey:uid];
    }
  }
}

- (void)processNotifications:(NSXMLNode*)fqlResultSet
{
  NSArray* newNotifications = [[parent notifications] addNotificationsFromXML:fqlResultSet];
  if(lastQuery + (kQueryInterval * 5) > [[NSDate date] timeIntervalSince1970]) {
    for (FBNotification* notification in newNotifications) {
      if ([notification boolForKey:@"is_unread"]) {
        NSImage* pic = [[parent profilePics] imageForKey:[notification objectForKey:@"sender_id"]];
        [[parent bubbleManager] addBubbleWithText:[notification stringForKey:@"title_text"]
                                          subText:[notification stringForKey:@"body_text"]
                                            image:pic
                                     notification:notification
                                          message:nil];
      }
    }
  }
}

- (void)processMessages:(NSXMLNode*)fqlResultSet
{
  NSArray* newMessages = [[parent messages] addMessagesFromXML:fqlResultSet];

  if(lastQuery + (kQueryInterval * 5) > [[NSDate date] timeIntervalSince1970]) {
    for (FBMessage* message in newMessages) {
      if ([message boolForKey:@"unread"]) {
        NSString* uid = [message objectForKey:@"snippet_author"];
        NSImage* pic = [[parent profilePics] imageForKey:uid];
        
        NSString* name = [[parent names] objectForKey:uid];
        NSString* subject = [message stringForKey:@"subject"];

        NSString* bubText;
        if (name != nil && [name length] != 0) {
          if (subject != nil && [subject length] != 0) {
            bubText = [NSString stringWithFormat:@"%@: %@", name, subject];
          } else {
            bubText = name;
          }
        } else {
          bubText = subject;
        }
        NSString* bubSubText = [message stringForKey:@"snippet"];
        if (bubText == nil || [bubText length] == 0) {
          bubText = bubSubText;
          bubSubText = nil;
        }
        [[parent bubbleManager] addBubbleWithText:bubText
                                          subText:bubSubText
                                            image:pic
                                     notification:nil
                                          message:message];
      }
    }
  }
}

- (void)processVerifyMessages:(NSXMLNode*)fqlResultSet
{
  [[parent messages] verifyMessagesFromXML:fqlResultSet];
}

@end
