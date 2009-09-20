//
//  ApplicationController.m
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import "secret.h" // defines kAppKey and kAppSecret. Fill in for your own app!

#import "ApplicationController.h"
#import <QuartzCore/QuartzCore.h>
#import <FBCocoa/FBCocoa.h>
#import "BubbleWindow.h"
#import "FBNotification.h"
#import "FBMessage.h"
#import "GlobalSession.h"
#import "StatusUpdateWindow.h"
#import "NetConnection.h"
#import "LoginItemManager.h"
#import "PreferencesWindow.h"
#import "StatusKeyShortcut.h"
#import "BubbleDimensions.h"
#import "NSImage+.h"


@interface ApplicationController (Private)

- (void)loginToFacebook;
- (void)updateMenu;

@end


@implementation ApplicationController

@synthesize menu, notifications, messages, bubbleManager, names, profilePics, appIcons;

FBConnect* connectSession;

- (id)init
{
  self = [super init];
  if (self) {
    connectSession = [FBConnect sessionWithAPIKey:kAppKey // you need to define kAppKey
                                         delegate:self];
    notifications = [[NotificationManager alloc] init];
    messages      = [[MessageManager alloc] init];
    bubbleManager = [[BubbleManager alloc] init];

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

    // setup the menu manager
    menu = [[MenuManager alloc] init];
    [menu setProfilePics:profilePics];
    [menu setAppIcons:appIcons];

    // setup the query manager
    queryManager = [[QueryManager alloc] initWithParent:self];

    // setup the preferences window
    [PreferencesWindow setupWithParent:self];
  }
  return self;
}

- (void)dealloc
{
  [connectSession     release];
  [notifications      release];
  [messages           release];
  [bubbleManager      release];
  [menu               release];
  [names              release];
  [profilePics        release];
  [appIcons           release];
  [statusUpdateWindow release];
  [queryManager       release];
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
  // need a sync?
  BOOL doSync = NO;

  // make sure there is a default for notification display time
  if ([[NSUserDefaults standardUserDefaults] integerForKey:kDisplayTimeKey] == 0) {
    [[NSUserDefaults standardUserDefaults] setInteger:8 forKey:kDisplayTimeKey];
    doSync = YES;
  }

  // make sure there is a default for notification display time
  if ([[NSUserDefaults standardUserDefaults] boolForKey:kBubbleLightMode] == 0) {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kBubbleLightMode];
    doSync = YES;
  }

  if (doSync) {
    [[NSUserDefaults standardUserDefaults] synchronize];
  }

  // key shortcut please!
  [StatusKeyShortcut setupWithTarget:self selector:@selector(beginUpdateStatus:)];

  // show a default menu
  [menu constructWithNotifications:nil messages:nil];

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
  int unseen = [notifications unseenCount] + [messages unseenCount];
  [menu setIconIlluminated:([[NetConnection netConnection] isOnline] && unseen > 0)];
  [menu constructWithNotifications:[notifications all]
                          messages:[messages all]];
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

- (IBAction)menuShowInbox:(id)sender
{
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.facebook.com/inbox"]];
}

- (IBAction)menuComposeMessage:(id)sender
{
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.facebook.com/inbox?compose"]];
}

- (IBAction)beginUpdateStatus:(id)sender
{
  if ([[NetConnection netConnection] isOnline] && [connectSession isLoggedIn]) {
    if (statusUpdateWindow) {
      if ([statusUpdateWindow isClosed]) {
        [statusUpdateWindow release];
        statusUpdateWindow = nil;
      } else {
        return;
      }
    }
    statusUpdateWindow = [[StatusUpdateWindow alloc] initWithTarget:self
                                                           selector:@selector(didStatusUpdate:)];
  }
}

- (IBAction)didStatusUpdate:(id)sender
{
  lastStatusUpdate = [sender statusMessage];
  [connectSession callMethod:@"stream.publish"
               withArguments:[NSDictionary dictionaryWithObjectsAndKeys:lastStatusUpdate, @"message", nil]
                      target:self
                    selector:@selector(statusUpdateWasPublished:)
                       error:nil];
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

-(IBAction) showPreferences:(id)sender
{
  [PreferencesWindow show];
}

- (IBAction)logout:(id)sender
{
  [connectSession logout];
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
  // for desktop applications, it's highly recommended you request the
  // "offline_access" permission. This returns a session which never expires.
  [connectSession loginWithPermissions:
   [NSArray arrayWithObjects:@"offline_access", @"publish_stream", @"manage_mailbox", nil]];
}

- (void)statusUpdateWasPublished:(id)reply
{
  [bubbleManager addBubbleWithText:lastStatusUpdate
                           subText:nil
                             image:[profilePics imageForKey:[connectSession uid]]
                      notification:nil
                           message:nil];
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
- (void)FBConnectLoggedIn:(FBConnect *)fbc
{
  NSLog(@"fb connect success");

  // setup login manager
  [[LoginItemManager manager] loginItemAsDefault:YES];

  [queryManager start];
}

- (void)FBConnectLoggedOut:(FBConnect *)fbc
{
  NSLog(@"loggin' out, gunna quit");
  [NSApp terminate:self];
}

- (void)FBConnectErrorLoggingIn:(FBConnect *)fbc
{
  NSLog(@"couldn't fb connect, not much else to do, quitting.");
  [NSApp terminate:self];
}

- (void)FBConnectErrorLoggingOut:(FBConnect *)fbc
{
  NSLog(@"couldn't log out, quitting anyway");
  [NSApp terminate:self];
}

@end