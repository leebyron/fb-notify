//
//  MenuManager.m
//  Facebook
//
//  Created by Lee Byron on 7/29/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "MenuManager.h"
#import "FBNotification.h"

#define kMaxNotificationsInMenu 20
#define kMaxNotificationStringLen 60
#define kEllipsis @"\u2026"

enum {
  NEWS_FEED_LINK_TAG,
  PROFILE_LINK_TAG,
  LOGOUT_TAG,
  QUIT_TAG
};

@interface MenuManager (Private)

- (void)addQuitItem;

@end

@implementation MenuManager

@synthesize userName, profileURL;

- (id)init
{
  self = [super init];
  if (self) {
    fbActiveIcon = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"fb_active" ofType:@"png"]];
    fbEmptyIcon = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"fb_empty" ofType:@"png"]];
    fbFullIcon = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"fb_full" ofType:@"png"]];

    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:30] retain];
    statusItemMenu = [[NSMenu alloc] init];

    [statusItem setMenu:statusItemMenu];
    [statusItem setHighlightMode:YES];
    [statusItem setImage:fbEmptyIcon];
    [statusItem setAlternateImage:fbActiveIcon];

    [self addQuitItem];
  }
  return self;
}

- (void)dealloc
{
  self.userName = nil;
  self.profileURL = nil;
  [statusItem release];
  [statusItemMenu release];
  [super dealloc];
}

- (void)setName:(NSString *)name profileURL:(NSString *)url
{
  userName   = name;
  profileURL = url;
}

- (void)setIconByAreUnread:(BOOL)areUnread
{
  [statusItem setImage:areUnread ? fbFullIcon : fbEmptyIcon];
}

- (void)constructWithNotifications:(NSMutableArray *)notifications
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
  [profileItem setRepresentedObject:self];
  [statusItemMenu addItem:profileItem];
  [profileItem release];
  
  [statusItemMenu addItem:[NSMenuItem separatorItem]];
  
  if ([notifications count] > 0) {
    // display the latest few notifications in the menu
    int notifCount = 0;
    for (FBNotification *notification in notifications) {
      if (notifCount++ >= kMaxNotificationsInMenu) {
        break;
      }

      NSString *title = [notification stringForKey:@"titleText"];
      if ([title length] > kMaxNotificationStringLen) {
        title = [[title substringToIndex:kMaxNotificationStringLen - 3] stringByAppendingString:kEllipsis];
      }

      NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title
                                                    action:@selector(menuShowNotification:)
                                             keyEquivalent:@""];
      [item setRepresentedObject:notification];
      [statusItemMenu addItem:item];
      [item release];
    }

    [statusItemMenu addItem:[NSMenuItem separatorItem]];
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

@end
