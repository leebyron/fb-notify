//
//  MenuManager.m
//  Facebook
//
//  Created by Lee Byron on 7/29/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "MenuManager.h"

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
  [statusItemMenu addItem:profileItem];
  [profileItem release];
  
  [statusItemMenu addItem:[NSMenuItem separatorItem]];
  
  if ([notifications count] > 0) {
    for (NSMenuItem *item in notifications) {
      [statusItemMenu addItem:item];
    }
    
    [statusItemMenu addItem:[NSMenuItem separatorItem]];
  }
  
  [self addQuitItem];
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
