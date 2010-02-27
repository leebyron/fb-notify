//
//  ApplicationController.m
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import "FacebookNotifierController.h"
#import <QuartzCore/QuartzCore.h>
#import "BubbleManager.h"
#import "FBNotification.h"
#import "FBMessage.h"
#import "GlobalSession.h"
#import "StatusUpdateWindow.h"
#import "NetConnection.h"
#import "LoginItemManager.h"
#import "PreferencesWindow.h"
#import "StatusKeyShortcut.h"
#import "BubbleDimensions.h"
#import "FBPreferenceManager.h"
#import "NSImage+.h"


@interface FacebookNotifierController (Private)

- (void)loginToFacebook;
- (void)updateMenu;

@end


@implementation FacebookNotifierController

@synthesize notifications, messages, names, profilePics, appIcons;

FBConnect* connectSession;

- (id)init
{
  self = [super init];
  if (self) {
    connectSession = [[FBConnect sessionWithAPIKey:@"4a280b1a1f1e4dae116484d677d7ed25"
                                          delegate:self] retain];

    notifications = [[NotificationManager alloc] init];
    messages      = [[MessageManager alloc] init];

    names = [[NSMutableDictionary alloc] init];

    // setup the profile pic and app icon image stores
    profilePics = [[ImageDictionary alloc] initWithBackupImage:[NSImage bundlePNG:@"silhouette"] allowUpdates:YES];
    appIcons = [[ImageDictionary alloc] initWithBackupImage:[NSImage bundlePNG:@"comment"] allowUpdates:NO];

    // some nicer over-ridden icons
    [appIcons setImageFile:[[NSBundle mainBundle] pathForResource:@"comment"    ofType:@"png"] forKey:@"19675640871"];
    [appIcons setImageFile:[[NSBundle mainBundle] pathForResource:@"comment"    ofType:@"png"] forKey:@"2719290516"];
    [appIcons setImageFile:[[NSBundle mainBundle] pathForResource:@"comment"    ofType:@"png"] forKey:@"219303305471"];
    [appIcons setImageFile:[[NSBundle mainBundle] pathForResource:@"like"       ofType:@"png"] forKey:@"2409997254"];
    [appIcons setImageFile:[[NSBundle mainBundle] pathForResource:@"photos"     ofType:@"png"] forKey:@"2305272732"];
    [appIcons setImageFile:[[NSBundle mainBundle] pathForResource:@"video"      ofType:@"png"] forKey:@"2392950137"];
    [appIcons setImageFile:[[NSBundle mainBundle] pathForResource:@"posteditem" ofType:@"png"] forKey:@"2309869772"];
    [appIcons setImageFile:[[NSBundle mainBundle] pathForResource:@"events"     ofType:@"png"] forKey:@"2344061033"];
    [appIcons setImageFile:[[NSBundle mainBundle] pathForResource:@"addfriend"  ofType:@"png"] forKey:@"2356318349"];
    [appIcons setImageFile:[[NSBundle mainBundle] pathForResource:@"discussion" ofType:@"png"] forKey:@"2373072738"];
    [appIcons setImageFile:[[NSBundle mainBundle] pathForResource:@"note"       ofType:@"png"] forKey:@"2347471856"];
    [appIcons setImageFile:[[NSBundle mainBundle] pathForResource:@"mobile"     ofType:@"png"] forKey:@"6628568379"];

    // touch the bubble manager
    [BubbleManager manager];

    // setup the menu manager
    [[MenuManager manager] setProfilePics:profilePics];
    [[MenuManager manager] setAppIcons:appIcons];

    // setup the query manager
    queryManager = [[QueryManager alloc] initWithParent:self];

    // setup the preferences window
    [PreferencesWindow setupWithParent:self];
  }
  return self;
}

- (void)dealloc
{
  [connectSession release];

  [notifications  release];
  [messages       release];
  [queryManager   release];

  [names          release];
  [profilePics    release];
  [appIcons       release];

  [super dealloc];
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
  //automatically check for updates
  [updater setDelegate:self];
  [updater checkForUpdatesInBackground];

  // check for future network connectivity changes
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(updateNetStatus:)
                                               name:kNetConnectionNotification
                                             object:[NetConnection netConnection]];
}

- (void)awakeFromNib
{
  // make sure there is a default for some preferences
  [[FBPreferenceManager manager] registerForKey:kDisplayTimeKey
                                   defaultValue:[NSNumber numberWithInt:8]];

  [[FBPreferenceManager manager] registerForKey:kBubbleLightMode
                                   defaultValue:[NSNumber numberWithBool:NO]];

  // key shortcut please!
  [StatusKeyShortcut setupWithTarget:self selector:@selector(beginUpdateStatus:)];

  // show a default menu
  [[MenuManager manager] constructWithNotifications:nil messages:nil];

  // if possible, login to facebook!
  if ([[NetConnection netConnection] isOnline]) {
    [self loginToFacebook];
  }
}

- (void)invalidate
{
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateMenu) object:nil];
  [self performSelector:@selector(updateMenu) withObject:nil afterDelay:0];
}

- (void)markEverythingSeen
{
  [notifications markAllSeen];
  [messages markAllSeen];
  [self invalidate];
}

- (void)updateMenu
{
  if (![[NetConnection netConnection] isOnline]) {
    [MenuManager manager].status = FBJewelStatusOffline;
  } else if (![connectSession isLoggedIn] || ![queryManager hasResponse]) {
    if (![connectSession isConnecting]) {
      [MenuManager manager].status = FBJewelStatusNotLoggedIn;
    } else {
      [MenuManager manager].status = FBJewelStatusConnecting;
    }
  } else if ([notifications unseenCount] + [messages unseenCount] > 0) {
    [MenuManager manager].status = FBJewelStatusUnseen;
  } else if ([notifications unreadCount] + [messages unreadCount] > 0) {
    [MenuManager manager].status = FBJewelStatusUnread;
  } else {
    [MenuManager manager].status = FBJewelStatusEmpty;
  }

  [[MenuManager manager] constructWithNotifications:notifications
                                           messages:messages];
}

#pragma mark IBActions
- (IBAction)menuShowNewsFeed:(id)sender
{
  [[NSWorkspace sharedWorkspace] openURL:
   [NSURL URLWithString:@"http://www.facebook.com/home.php"]];
}

- (IBAction)menuShowProfile:(id)sender
{
  [[NSWorkspace sharedWorkspace] openURL:
   [NSURL URLWithString:[[sender representedObject] profileURL]]];
}

- (IBAction)menuShowInbox:(id)sender
{
  [[NSWorkspace sharedWorkspace] openURL:
   [NSURL URLWithString:@"http://www.facebook.com/inbox"]];
}

- (IBAction)menuComposeMessage:(id)sender
{
  [[NSWorkspace sharedWorkspace] openURL:
   [NSURL URLWithString:@"http://www.facebook.com/inbox?compose"]];
}

- (IBAction)beginUpdateStatus:(id)sender
{
  // if a window already exists, get rid of it!
  if ([StatusUpdateWindow currentWindow]) {
    [[StatusUpdateWindow currentWindow] cancel:self];
    return;
  }

  // if we're online and connected, then show a new status update window
  if ([[NetConnection netConnection] isOnline] && [connectSession isLoggedIn]) {
    [StatusUpdateWindow open];
  }
}

- (IBAction)menuShowNotification:(id)sender
{
  FBNotification *notification = ([sender isKindOfClass:[FBNotification class]] ? sender : [sender representedObject]);

  // mark this notification as read
  [notification markAsReadWithSimilar:YES];

  // load action url
  NSURL *url = [notification href];
  [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)menuShowMessage:(id)sender
{
  FBMessage *message = ([sender isKindOfClass:[FBMessage class]] ? sender : [sender representedObject]);

  // mark this message as read
  [message markAsRead];

  // load inbox url
  NSURL *inboxURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.facebook.com/inbox/?tid=%@",
                                                                    [message objectForKey:@"thread_id"]]];
  [[NSWorkspace sharedWorkspace] openURL:inboxURL];
}

- (IBAction)menuShowAllNotifications:(id)sender
{
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.facebook.com/notifications.php"]];
}

- (IBAction)menuMarkAsReadAllNotifications:(id)sender
{
  [notifications markAllRead];
}

- (IBAction)showPreferences:(id)sender
{
  [PreferencesWindow show];
}

- (IBAction)promptLogin:(id)sender
{
  [self loginToFacebook];
}

- (IBAction)logout:(id)sender
{
  [notifications clear];
  [messages clear];

  [queryManager reset];
  [connectSession logout];

  [self updateMenu];
  [PreferencesWindow refresh];
}


#pragma mark Private methods
- (void)updateNetStatus:(NSNotification *)notif
{
  NSLog(@"Net status changed to %i", [[NetConnection netConnection] isOnline]);

  if ([[NetConnection netConnection] isOnline]) {
    if ([connectSession isLoggedIn]) {
      [queryManager start];
    } else {
      [self loginToFacebook];
    }
  } else {
    // if we just switched to offline, stop the query timer
    [queryManager stop];
  }

  [self invalidate];
}

- (void)loginToFacebook
{
  // highly recommended to request offline access, since we live on the desktop.
  [connectSession loginWithRequiredPermissions:[NSSet setWithObjects:@"manage_mailbox", nil]
                           optionalPermissions:[NSSet setWithObjects:@"publish_stream", @"offline_access", nil]];
}

// Sent when a valid update is found by the update driver.
- (void)updater:(SUUpdater *)suUpdater didFindValidUpdate:(SUAppcastItem *)update {
  NSLog(@"update found version: %@", [update versionString]);
}

// Sent when a valid update is not found.
- (void)updaterDidNotFindUpdate:(SUUpdater *)update
{
  NSLog(@"checked for update, and no update found");
}

// Sent when the appcast has loaded
- (void)updater:(SUUpdater *)update didFinishLoadingAppcast:(SUAppcast *)appcast {
  NSMutableArray* loadedVersions = [[NSMutableArray alloc] init];
  for (SUAppcastItem* item in [appcast items]) {
    [loadedVersions addObject:[item versionString]];
  }
  NSLog(@"appcast loaded. your version: %@, loaded versions: %@",
        [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"],
        [loadedVersions componentsJoinedByString:@", "]);
}

#pragma mark FB Session delegate methods
- (void)facebookConnectLoggedIn:(FBConnect*)connect withError:(NSError*)err
{
  // refresh ui
  [self updateMenu];
  [PreferencesWindow refresh];

  if (err) {
    NSLog(@"couldn't login to facebook");    
    return;
  }

  NSLog(@"fb connect success");

  // setup login manager
  [[LoginItemManager manager] loginItemAsDefault:YES];

  [queryManager start];
}

- (void)facebookConnectLoggedOut:(FBConnect*)connect withError:(NSError*)err
{
  // refresh ui
  [self updateMenu];

  if (err) {
    NSLog(@"couldn't log out of fb servers, at least locally logged out");
  }

  NSLog(@"logged out");
}

@end
