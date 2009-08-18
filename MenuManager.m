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

#define kMaxNotifications 12
#define kMinNotifications 5
#define kMaxMessages 6
#define kMinMessages 3
#define kMaxStringLen 50
#define kEllipsis @"\u2026"
#define kUserIconSize 15.0

enum {
  NEWS_FEED_LINK_TAG,
  PROFILE_LINK_TAG,
  STATUS_UPDATE_TAG,
  MORE_LINK_TAG,
  SHOW_INBOX_TAG,
  COMPOSE_MESSAGE_TAG,
  START_AT_LOGIN_TAG,
  LOGOUT_TAG,
  QUIT_TAG
};

@interface MenuManager (Private)

- (void)addQuitItem;
- (BOOL)wasLaunchedByProcess:(NSString*)creator;
- (BOOL)wasLaunchedAsLoginItem;

@end

@implementation MenuManager

@synthesize userName, profileURL, appIcons;

- (id)init
{
  self = [super init];
  if (self) {
    fbActiveIcon = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"fb_active" ofType:@"png"]];
    fbEmptyIcon = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"fb_empty" ofType:@"png"]];
    fbFullIcon = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"fb_full" ofType:@"png"]];

    userIcon = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"profile" ofType:@"png"]];

    newsFeedIcon = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"newsfeed" ofType:@"png"]];
    profileIcon = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"profile" ofType:@"png"]];
    notificationsIcon = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"notifications" ofType:@"png"]];
    messageIcon = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"message" ofType:@"png"]];
    inboxIcon = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"inbox" ofType:@"png"]];
    
    notificationsGhostIcon = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"notifications_ghost" ofType:@"png"]];
    inboxGhostIcon = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"inbox_ghost" ofType:@"png"]];

    appIcons      = [[NSMutableDictionary alloc] init];

    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:28] retain];
    statusItemMenu = [[NSMenu alloc] init];

    [statusItem setMenu:statusItemMenu];
    [statusItem setHighlightMode:YES];
    [statusItem setImage:fbEmptyIcon];
    [statusItem setAlternateImage:fbActiveIcon];
  }
  return self;
}

- (void)dealloc
{
  [userIcon release];

  [fbActiveIcon release];
  [fbEmptyIcon release];
  [fbFullIcon release];

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

- (void)setProfilePics:(NSDictionary *)pics
{
  profilePics = [pics retain];
}

- (void)setName:(NSString *)name profileURL:(NSString *)url userPic:(NSImage *)pic
{
  userName   = [name retain];
  profileURL = [url retain];
  userIcon   = [pic retain];

  [userIcon release];
  userIcon = [[NSImage alloc] initWithSize: NSMakeSize(16.0, 16.0)];
  NSSize originalSize = [pic size];
  
  [userIcon lockFocus];
  [pic drawInRect:NSMakeRect(16.0 - kUserIconSize, 16.0 - kUserIconSize, kUserIconSize, kUserIconSize)
         fromRect:NSMakeRect(0, 0, originalSize.width, originalSize.height)
        operation:NSCompositeSourceOver
         fraction:1.0];
  [userIcon unlockFocus];
}

- (void)setIconByAreUnread:(BOOL)areUnread
{
  [statusItem setImage:areUnread ? fbFullIcon : fbEmptyIcon];
}

- (void)constructWithNotifications:(NSArray *)notifications messages:(NSArray *)messages isOnline:(BOOL)isOnline
{
  // remove old
  while ([statusItemMenu numberOfItems] > 0) {
    [statusItemMenu removeItemAtIndex:0];
  }
  
  BOOL isLoggedIn = [connectSession isLoggedIn];

  if (isOnline && isLoggedIn) {
    // add new
    NSMenuItem *newsFeedItem = [[NSMenuItem alloc] initWithTitle:@"News Feed"
                                                          action:@selector(menuShowNewsFeed:)
                                                   keyEquivalent:@""];
    [newsFeedItem setTag:NEWS_FEED_LINK_TAG];
    [newsFeedItem setImage:newsFeedIcon];
    [statusItemMenu addItem:newsFeedItem];
    [newsFeedItem release];

    NSMenuItem *profileItem = [[NSMenuItem alloc] initWithTitle:userName
                                                         action:@selector(menuShowProfile:)
                                                  keyEquivalent:@""];
    [profileItem setTag:PROFILE_LINK_TAG];
    [profileItem setImage:userIcon];
    [profileItem setRepresentedObject:self];
    [statusItemMenu addItem:profileItem];
    [profileItem release];
    
    NSMenuItem *setStatusItem = [[NSMenuItem alloc] initWithTitle:@"Update Status"
                                                           action:@selector(beginUpdateStatus:)
                                                    keyEquivalent:@""];
    [setStatusItem setKeyEquivalent:@" "];
    [setStatusItem setKeyEquivalentModifierMask:NSAlternateKeyMask|NSCommandKeyMask|NSControlKeyMask];
    [setStatusItem setTag:STATUS_UPDATE_TAG];
    [setStatusItem setImage:profileIcon];
    [setStatusItem setRepresentedObject:self];
    [statusItemMenu addItem:setStatusItem];
    [setStatusItem release];
    
    //compose message
    NSMenuItem *composeMessageItem = [[NSMenuItem alloc] initWithTitle:@"Compose New Message"
                                                                action:@selector(menuComposeMessage:)
                                                         keyEquivalent:@""];
    [composeMessageItem setTag:COMPOSE_MESSAGE_TAG];
    [composeMessageItem setImage:messageIcon];
    [statusItemMenu addItem:composeMessageItem];
    [composeMessageItem release];
  } else if (isOnline) {
    // Connecting title
    NSMenuItem *offlineItem = [[NSMenuItem alloc] initWithTitle:@"Connecting..."
                                                         action:nil
                                                  keyEquivalent:@""];
    [statusItemMenu addItem:offlineItem];
    [offlineItem release];
  } else {
    // Offline title
    NSMenuItem *offlineItem = [[NSMenuItem alloc] initWithTitle:@"Offline"
                                                         action:nil
                                                  keyEquivalent:@""];
    [statusItemMenu addItem:offlineItem];
    [offlineItem release];
  }

  [statusItemMenu addItem:[NSMenuItem separatorItem]];
  
  if (isOnline && isLoggedIn) {

    if (notifications && [notifications count] > 0) {
      // Notifications title
      NSMenuItem *notifTitleItem = [[NSMenuItem alloc] initWithTitle:@"Notifications"
                                                              action:nil
                                                       keyEquivalent:@""];
      [notifTitleItem setImage:notificationsGhostIcon];
      [statusItemMenu addItem:notifTitleItem];
      [notifTitleItem release];

      // display the latest few notifications in the menu
      int addedNotifications = 0;
      int extraNotifications = 0;
      for (int i = [notifications count] - 1; i >= 0; i--) {
        FBNotification *notification = [notifications objectAtIndex:i];
        // maintain between kMinNotifications and kMaxNotifications
        if (addedNotifications >= kMinNotifications &&
            (![notification boolForKey:@"isUnread"] || addedNotifications >= kMaxNotifications)) {
          if ([notification boolForKey:@"isUnread"]) {
            extraNotifications++;
          }
          continue;
        }

        // add item to menu
        NSString *title = [notification stringForKey:@"titleText"];
        if ([title length] > kMaxStringLen) {
          title = [[title substringToIndex:kMaxStringLen - 3] stringByAppendingString:kEllipsis];
        }
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title
                                                      action:@selector(menuShowNotification:)
                                               keyEquivalent:@""];
        if ([notification boolForKey:@"isUnread"]) {
          [item setOnStateImage:[NSImage imageNamed:@"bullet.png"]];
          [item setState:NSOnState];
        }
        [item setRepresentedObject:notification];
        [item setImage:[appIcons objectForKey:[notification objForKey:@"appId"]]];
        [statusItemMenu addItem:item];
        [item release];
        addedNotifications++;
      }

      if (extraNotifications > 0) {
        NSString *more = [NSString stringWithFormat:@"%i More Notification", extraNotifications];
        if (extraNotifications > 1) {
          more = [more stringByAppendingString:@"s"];
        }
        NSMenuItem *moreItem = [[NSMenuItem alloc] initWithTitle:more
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
      NSMenuItem *inboxTitleItem = [[NSMenuItem alloc] initWithTitle:@"Inbox"
                                                              action:nil
                                                       keyEquivalent:@""];
      [inboxTitleItem setImage:inboxGhostIcon];
      [statusItemMenu addItem:inboxTitleItem];
      [inboxTitleItem release];  

      // display the latest few notifications in the menu
      int addedMessages = 0;
      int extraMessages = 0;
      for (int i = [messages count] - 1; i >= 0; i--) {
        FBMessage *message = [messages objectAtIndex:i];
        // maintain between kMinMessages and kMaxMessages
        if (addedMessages >= kMinMessages &&
            (![message boolForKey:@"unread"] || addedMessages >= kMaxMessages)) {
          if ([message boolForKey:@"unread"]) {
            extraMessages++;
          }
          continue;
        }
        
        // add item to menu
        NSString *title = [message stringForKey:@"subject"];
        if ([title length] == 0) {
          title = [message stringForKey:@"snippet"];
        }
        if ([title length] > kMaxStringLen) {
          title = [[title substringToIndex:kMaxStringLen - 3] stringByAppendingString:kEllipsis];
        }
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title
                                                      action:@selector(menuShowMessage:)
                                               keyEquivalent:@""];
        if ([message boolForKey:@"unread"]) {
          [item setOnStateImage:[NSImage imageNamed:@"bullet.png"]];
          [item setState:NSOnState];
        }
        [item setRepresentedObject:message];

        // profile pic icon
        NSImage *senderIcon;
        NSImage *pic = [profilePics objectForKey:[message objForKey:@"snippetAuthor"]];

        senderIcon = [[[NSImage alloc] initWithSize: NSMakeSize(16.0, 16.0)] autorelease];
        NSSize originalSize = [pic size];

        [senderIcon lockFocus];
        [pic drawInRect:NSMakeRect(16.0 - kUserIconSize, 16.0 - kUserIconSize, kUserIconSize, kUserIconSize)
               fromRect:NSMakeRect(0, 0, originalSize.width, originalSize.height)
              operation:NSCompositeSourceOver
               fraction:1.0];
        [senderIcon unlockFocus];
        [item setImage:senderIcon];
        [statusItemMenu addItem:item];
        [item release];
        addedMessages++;
      }
      
      if (extraMessages > 0) {
        NSString *more = [NSString stringWithFormat:@"%i More Message", extraMessages];
        if (extraMessages > 1) {
          more = [more stringByAppendingString:@"s"];
        }
        NSMenuItem *moreMessagesItem = [[NSMenuItem alloc] initWithTitle:more
                                                          action:@selector(menuShowInbox:)
                                                   keyEquivalent:@""];
        [moreMessagesItem setTag:SHOW_INBOX_TAG];
        [moreMessagesItem setImage:inboxIcon];
        [statusItemMenu addItem:moreMessagesItem];
        [moreMessagesItem release];
      }    
      
    } else {
      NSMenuItem *noMessagesItem = [[NSMenuItem alloc] initWithTitle:@"No Inbox Messages"
                                                              action:@selector(menuShowInbox:)
                                                       keyEquivalent:@""];
      [noMessagesItem setTag:SHOW_INBOX_TAG];
      [noMessagesItem setImage:inboxIcon];
      [statusItemMenu addItem:noMessagesItem];
      [noMessagesItem release];
    }

    [statusItemMenu addItem:[NSMenuItem separatorItem]];
  }

  //start at login
  NSMenuItem *startAtLoginItem = [[NSMenuItem alloc] initWithTitle:@"Start at Login"
                                                              action:@selector(changedStartAtLoginStatus:)
                                                       keyEquivalent:@""];
  [startAtLoginItem setTag:START_AT_LOGIN_TAG];
  [startAtLoginItem setState:([[NSUserDefaults standardUserDefaults] integerForKey:kStartAtLoginOption] == START_AT_LOGIN_YES ? NSOnState : NSOffState)];
  [statusItemMenu addItem:startAtLoginItem];
  [startAtLoginItem release];

  // logout first
  if (isOnline && isLoggedIn) {
    NSMenuItem *logoutItem = [[NSMenuItem alloc] initWithTitle:@"Logout and Quit"
                                                        action:@selector(logout:)
                                                 keyEquivalent:@""];
    [logoutItem setTag:LOGOUT_TAG];
    [statusItemMenu addItem:logoutItem];
    [logoutItem release];
  }

  [self addQuitItem];
}

#pragma mark Private methods
- (void)addQuitItem
{
  NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:@"Quit Facebook Notifications"
                                                    action:@selector(terminate:)
                                             keyEquivalent:@""];
  [quitItem setTag:QUIT_TAG];
  [statusItemMenu addItem:quitItem];
  [quitItem release];
}

- (BOOL)wasLaunchedByProcess:(NSString*)creator
{
  BOOL wasLaunchedByProcess = NO;
  
  // Get our PSN
  OSStatus  err;
  ProcessSerialNumber currPSN;
  err = GetCurrentProcess (&currPSN);
  if (!err) {
    // We don't use ProcessInformationCopyDictionary() because the 'ParentPSN' item in the dictionary
    // has endianness problems in 10.4, fixed in 10.5 however.
    ProcessInfoRec  procInfo;
    bzero (&procInfo, sizeof (procInfo));
    procInfo.processInfoLength = (UInt32)sizeof (ProcessInfoRec);
    err = GetProcessInformation (&currPSN, &procInfo);
    if (!err) {
      ProcessSerialNumber parentPSN = procInfo.processLauncher;
      
      // Get info on the launching process
      NSDictionary* parentDict = (NSDictionary*)ProcessInformationCopyDictionary (&parentPSN, kProcessDictionaryIncludeAllInformationMask);
      
      // Test the creator code of the launching app
      if (parentDict) {
        wasLaunchedByProcess = [[parentDict objectForKey:@"FileCreator"] isEqualToString:creator];
        [parentDict release];
      }
    }
  }
  
  return wasLaunchedByProcess;
}

- (BOOL)wasLaunchedAsLoginItem
{
  // If the launching process was 'loginwindow', we were launched as a login item
  return [self wasLaunchedByProcess:@"lgnw"];
}

@end
