//
//  MenuManager.m
//  Facebook
//
//  Created by Lee Byron on 7/29/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "MenuManager.h"
#import "FBNotification.h"
#import "FBMessage.h"
#import "GlobalSession.h"
#import "NetConnection.h"
#import "LoginItemManager.h"
#import "StatusKeyShortcut.h"
#import "NSString+.h"
#import "MenuIcon.h"


#define kMaxNotifications 12
#define kMinNotifications 5
#define kMaxMessages 6
#define kMinMessages 3
#define kMaxStringLen 45
#define kUserIconSize 15.0


enum {
  NEWS_FEED_LINK_TAG,
  PROFILE_LINK_TAG,
  STATUS_UPDATE_TAG,
  MORE_LINK_TAG,
  MARK_AS_READ_TAG,
  SHOW_INBOX_TAG,
  COMPOSE_MESSAGE_TAG,
  START_AT_LOGIN_TAG,
  PREFERENCES_TAG,
  LOGOUT_TAG,
  QUIT_TAG
};


@interface MenuManager (Private)

- (NSImage*)makeTinyMan:(NSImage*)pic;
- (BOOL)wasLaunchedByProcess:(NSString*)creator;
- (BOOL)wasLaunchedAsLoginItem;

@end


@interface NSStatusBar (Priority)

- (NSStatusItem *)_statusItemWithLength:(CGFloat)length withPriority:(int)pri;

@end


@implementation MenuManager

@synthesize statusItem, userName, profileURL, profilePics, appIcons;

- (id)init
{
  self = [super init];
  if (self) {
    fbMenuIcon = [[MenuIcon alloc] initWithManager:self];

    newsFeedIcon = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"newsfeed" ofType:@"png"]];
    profileIcon = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"profile" ofType:@"png"]];
    notificationsIcon = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"notifications" ofType:@"png"]];
    messageIcon = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"message" ofType:@"png"]];
    inboxIcon = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"inbox" ofType:@"png"]];

    notificationsGhostIcon = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"notifications_ghost" ofType:@"png"]];
    inboxGhostIcon = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"inbox_ghost" ofType:@"png"]];

    NSStatusBar* bar = [NSStatusBar systemStatusBar];
    @try {
      statusItem = [[bar _statusItemWithLength:29 withPriority:65536] retain];
    } @catch (NSException* e) {
      statusItem = [[bar statusItemWithLength:29] retain];
    }
    [statusItem setLength:29];
    [statusItem setView:fbMenuIcon];

    statusItemMenu = [[NSMenu alloc] init];
  }
  return self;
}

- (void)dealloc
{
  [fbMenuIcon release];

  [newsFeedIcon release];
  [profileIcon release];
  [notificationsIcon release];
  [messageIcon release];
  [inboxIcon release];

  [notificationsGhostIcon release];
  [inboxGhostIcon release];

  [appIcons release];
  [profilePics release];

  if (userName != nil) {
    [userName release];
    [profileURL release];
  }
  [statusItem release];
  [statusItemMenu release];
  [super dealloc];
}

- (void)setIconIlluminated:(BOOL)illuminated
{
  [fbMenuIcon setIconIlluminated:illuminated];
}

- (void)constructWithNotifications:(HashArray*)notifications
                          messages:(HashArray*)messages
{
  // remove old
  while ([statusItemMenu numberOfItems] > 0) {
    [statusItemMenu removeItemAtIndex:0];
  }

  BOOL isLoggedIn = [connectSession isLoggedIn] && userName != nil;

  if ([[NetConnection netConnection] isOnline] && isLoggedIn) {
    // add new
    NSMenuItem* newsFeedItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"News Feed", @"Link to the News Feed")
                                                          action:@selector(menuShowNewsFeed:)
                                                   keyEquivalent:@""];
    [newsFeedItem setTag:NEWS_FEED_LINK_TAG];
    [newsFeedItem setImage:newsFeedIcon];
    [statusItemMenu addItem:newsFeedItem];
    [newsFeedItem release];

    NSMenuItem* profileItem = [[NSMenuItem alloc] initWithTitle:userName
                                                         action:@selector(menuShowProfile:)
                                                  keyEquivalent:@""];
    [profileItem setTag:PROFILE_LINK_TAG];
    [profileItem setImage:[self makeTinyMan:[profilePics imageForKey:[connectSession uid]]]];
    [profileItem setRepresentedObject:self];
    [statusItemMenu addItem:profileItem];
    [profileItem release];

    NSMenuItem* setStatusItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Update Status", @"Link for Status HUD")
                                                           action:@selector(beginUpdateStatus:)
                                                    keyEquivalent:@""];
    if ([[StatusKeyShortcut instance] keyCodeString]) {
      [setStatusItem setKeyEquivalent:[[StatusKeyShortcut instance] keyCodeString]];
      [setStatusItem setKeyEquivalentModifierMask:[[StatusKeyShortcut instance] keyFlags]];
    }
    [setStatusItem setTag:STATUS_UPDATE_TAG];
    [setStatusItem setImage:profileIcon];
    [setStatusItem setRepresentedObject:self];
    [statusItemMenu addItem:setStatusItem];
    [setStatusItem release];

    //compose message
    NSMenuItem* composeMessageItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Compose New Message", @"Link to Compose Message")
                                                                action:@selector(menuComposeMessage:)
                                                         keyEquivalent:@""];
    [composeMessageItem setTag:COMPOSE_MESSAGE_TAG];
    [composeMessageItem setImage:messageIcon];
    [statusItemMenu addItem:composeMessageItem];
    [composeMessageItem release];
  } else if ([[NetConnection netConnection] isOnline]) {
    // Connecting title
    NSMenuItem* offlineItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Connecting", nil), kEllipsis]
                                                         action:nil
                                                  keyEquivalent:@""];
    [statusItemMenu addItem:offlineItem];
    [offlineItem release];
  } else {
    // Offline title
    NSMenuItem* offlineItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Not Online", nil)
                                                         action:nil
                                                  keyEquivalent:@""];
    [statusItemMenu addItem:offlineItem];
    [offlineItem release];
  }

  [statusItemMenu addItem:[NSMenuItem separatorItem]];

  if ([[NetConnection netConnection] isOnline] && isLoggedIn) {

    if (notifications && [notifications count] > 0) {
      // Notifications title
      NSMenuItem* notifTitleItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Notifications", @"Header for Notifications")
                                                              action:nil
                                                       keyEquivalent:@""];
      [notifTitleItem setImage:notificationsGhostIcon];
      [statusItemMenu addItem:notifTitleItem];
      [notifTitleItem release];

      // display the latest few notifications in the menu
      int addedNotifications  = 0;
      int extraNotifications  = 0;
      int unreadNotifications = 0;
      for (int i = [notifications count] - 1; i >= 0; i--) {
        FBNotification* notification = [notifications objectAtIndex:i];

        if ([notification boolForKey:@"is_unread"]) {
          unreadNotifications++;
        }

        // maintain between kMinNotifications and kMaxNotifications
        if (addedNotifications >= kMinNotifications &&
            (![notification boolForKey:@"is_unread"] || addedNotifications >= kMaxNotifications)) {
          if ([notification boolForKey:@"is_unread"]) {
            extraNotifications++;
          }
          continue;
        }

        // add item to menu
        NSString* title = [notification stringForKey:@"title_text"];
        if (!title) {
          title = [NSString stringWithString:@""];
        }
        if ([title length] > kMaxStringLen) {
          title = [[title substringToIndex:kMaxStringLen - 3] stringByAppendingString:kEllipsis];
        }
        NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:title
                                                      action:@selector(menuShowNotification:)
                                               keyEquivalent:@""];
        if ([notification boolForKey:@"is_unread"]) {
          [item setOnStateImage:[NSImage imageNamed:@"bullet.png"]];
          [item setState:NSOnState];
        }
        [item setRepresentedObject:notification];
        [item setImage:[appIcons imageForKey:[notification uidForKey:@"app_id"]]];
        [statusItemMenu addItem:item];
        [item release];
        addedNotifications++;
      }

      // are there any more unreads that we can't see?
      if (extraNotifications > 0) {
        NSString* moreText;
        if (extraNotifications == 1) {
          moreText = NSLocalizedString(@"MORE_NOTIFICATIONS_1", @"1 More Notification");
        } else if (extraNotifications == 2) {
          moreText = NSLocalizedString(@"MORE_NOTIFICATIONS_2", @"2 More Notifications");
        } else {
          moreText = NSLocalizedString(@"MORE_NOTIFICATIONS_MANY", @"5 More Notifications");
        }
        NSMenuItem* moreItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%i %@", extraNotifications, moreText]
                                                          action:@selector(menuShowAllNotifications:)
                                                   keyEquivalent:@""];
        [moreItem setTag:MORE_LINK_TAG];
        [moreItem setImage:notificationsIcon];
        [statusItemMenu addItem:moreItem];
        [moreItem release];
      }

      [statusItemMenu addItem:[NSMenuItem separatorItem]];
    }

    if (messages && [messages count] > 0) {
      // Inbox title
      NSMenuItem* inboxTitleItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Inbox", @"Header for Inbox")
                                                              action:nil
                                                       keyEquivalent:@""];
      [inboxTitleItem setImage:inboxGhostIcon];
      [statusItemMenu addItem:inboxTitleItem];
      [inboxTitleItem release];

      // display the latest few notifications in the menu
      int addedMessages = 0;
      int extraMessages = 0;
      for (int i = [messages count] - 1; i >= 0; i--) {
        FBMessage* message = [messages objectAtIndex:i];
        // maintain between kMinMessages and kMaxMessages
        if (addedMessages >= kMinMessages &&
            (![message boolForKey:@"unread"] || addedMessages >= kMaxMessages)) {
          if ([message boolForKey:@"unread"]) {
            extraMessages++;
          }
          continue;
        }

        // add item to menu
        NSString* title = [message stringForKey:@"subject"];
        if (!title) {
          title = [message stringForKey:@"snippet"];
        }
        if (!title) {
          title = [NSString stringWithString:@""];
        }
        if ([title length] > kMaxStringLen) {
          title = [[title substringToIndex:kMaxStringLen - 3] stringByAppendingString:kEllipsis];
        }
        NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:title
                                                      action:@selector(menuShowMessage:)
                                               keyEquivalent:@""];
        if ([message boolForKey:@"unread"]) {
          [item setOnStateImage:[NSImage imageNamed:@"bullet.png"]];
          [item setState:NSOnState];
        }
        [item setRepresentedObject:message];

        // profile pic icon
        NSImage* senderIcon = [self makeTinyMan:[profilePics imageForKey:[message uidForKey:@"snippet_author"]]];
        [item setImage:senderIcon];
        [statusItemMenu addItem:item];
        [item release];
        addedMessages++;
      }

      if (extraMessages > 0) {
        NSString* moreText;
        if (extraMessages == 1) {
          moreText = NSLocalizedString(@"MORE_MESSAGES_1", @"1 More Message");
        } else if (extraMessages == 2) {
          moreText = NSLocalizedString(@"MORE_MESSAGES_2", @"2 More Messages");
        } else {
          moreText = NSLocalizedString(@"MORE_MESSAGES_MANY", @"5 More Messages");
        }
        NSMenuItem* moreMessagesItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%i %@", extraMessages, moreText]
                                                                  action:@selector(menuShowInbox:)
                                                           keyEquivalent:@""];
        [moreMessagesItem setTag:SHOW_INBOX_TAG];
        [moreMessagesItem setImage:inboxIcon];
        [statusItemMenu addItem:moreMessagesItem];
        [moreMessagesItem release];
      }

    } else {
      NSMenuItem* noMessagesItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"No Inbox Messages", nil)
                                                              action:@selector(menuShowInbox:)
                                                       keyEquivalent:@""];
      [noMessagesItem setTag:SHOW_INBOX_TAG];
      [noMessagesItem setImage:inboxIcon];
      [statusItemMenu addItem:noMessagesItem];
      [noMessagesItem release];
    }

    [statusItemMenu addItem:[NSMenuItem separatorItem]];
  }

  NSMenuItem* preferencesItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Preferences", nil), kEllipsis]
                                                           action:@selector(showPreferences:)
                                                    keyEquivalent:@""];
  [preferencesItem setTag:PREFERENCES_TAG];
  [statusItemMenu addItem:preferencesItem];
  [preferencesItem release];

  NSMenuItem* quitItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Quit Facebook Notifications", nil)
                                                    action:@selector(terminate:)
                                             keyEquivalent:@""];
  [quitItem setTag:QUIT_TAG];
  [statusItemMenu addItem:quitItem];
  [quitItem release];
}

- (void)openMenu
{
  [statusItem popUpStatusItemMenu:statusItemMenu];
}

#pragma mark Private methods
- (NSImage*)makeTinyMan:(NSImage*)pic
{
  NSImage* tinyMan = [[[NSImage alloc] initWithSize: NSMakeSize(16.0, 16.0)] autorelease];
  NSSize originalSize = [pic size];

  [tinyMan lockFocus];
  [[NSColor colorWithCalibratedWhite:0.0 alpha:0.1] set];
  [NSBezierPath fillRect: NSMakeRect(1.5, 0, 14.0, 16.0)];
  [pic drawInRect:NSMakeRect(16.0 - kUserIconSize, 16.0 - kUserIconSize, kUserIconSize, kUserIconSize)
         fromRect:NSMakeRect(0, 0, originalSize.width, originalSize.height)
        operation:NSCompositeSourceOver
         fraction:1.0];
  [tinyMan unlockFocus];

  return tinyMan;
}

@end
