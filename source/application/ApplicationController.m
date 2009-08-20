//
//  ApplicationController.m
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import "secret.h" // defines kAppKey and kAppSecret. Fill in for your own app!

#import "ApplicationController.h"
#import <Carbon/Carbon.h>
#import <QuartzCore/QuartzCore.h>
#import <FBCocoa/FBCocoa.h>
#import "BubbleWindow.h"
#import "FBNotification.h"
#import "FBMessage.h"
#import "GlobalSession.h"
#import "StatusUpdateWindow.h"
#import "NetConnection.h"
#import "LoginItemManager.h"


@interface ApplicationController (Private)

- (void)loginToFacebook;

@end


@implementation ApplicationController

@synthesize menu, notifications, messages, bubbleManager, profilePics, appIcons;

FBConnect* connectSession;

- (id)init
{
  self = [super init];
  if (self) {
    connectSession = [FBConnect sessionWithAPIKey:kAppKey
                                           secret:kAppSecret
                                         delegate:self];
    notifications = [[NotificationManager alloc] init];
    messages      = [[MessageManager alloc] init];
    bubbleManager = [[BubbleManager alloc] init];

    // setup the profile pic and app icon image stores
    NSImage *profilePicBackup = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"silhouette" ofType:@"png"]];
    profilePics = [[ImageDictionary alloc] initWithBackupImage:profilePicBackup allowUpdates:YES];

    NSImage *appIconBackup = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"comment" ofType:@"png"]];
    appIcons = [[ImageDictionary alloc] initWithBackupImage:appIconBackup allowUpdates:NO];

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
  [profilePics        release];
  [appIcons           release];
  [statusUpdateWindow release];
  [queryManager       release];
  [super dealloc];
}

// Global hot key reciever
OSStatus globalHotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData)
{
  [[NSApp delegate] beginUpdateStatus:nil];
  return noErr;
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
  //automatically check for updates
  [updater checkForUpdatesInBackground];

  // setup login manager
  [[LoginItemManager manager] loginItemAsDefault:YES];

  // check for future network connectivity changes
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(updateNetStatus:)
                                               name:kNetConnectionNotification
                                             object:[NetConnection netConnection]];
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

  // show a default menu
  [menu constructWithNotifications:nil messages:nil];

  // if possible, login to facebook!
  if ([[NetConnection netConnection] isOnline]) {
    [self loginToFacebook];
  }
}

- (void)markNotificationAsRead:(FBNotification *)notification withSimilar:(BOOL)markSimilar
{
  [notification markAsReadWithSimilar:markSimilar];
  [self updateMenu];
}

- (void)markMessageAsRead:(FBMessage *)message
{
  [message markAsRead];
  [self updateMenu];
}

- (void)updateMenu
{
  [menu setIconByAreUnread:([[NetConnection netConnection] isOnline] &&
                            ([notifications unreadCount] + [messages unreadCount] > 0))];
  [menu constructWithNotifications:[notifications allNotifications]
                          messages:[messages allMessages]];
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
  if ([connectSession isLoggedIn]) {
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
  [connectSession callMethod:@"Stream.publish"
               withArguments:[NSDictionary dictionaryWithObjectsAndKeys:lastStatusUpdate, @"message", nil]
                      target:self
                    selector:@selector(statusUpdateWasPublished:)
                       error:nil];
}

- (IBAction)menuShowNotification:(id)sender
{
  FBNotification *notification = ([sender isMemberOfClass:[FBNotification class]] ? sender : [sender representedObject]);

  // mark this notification as read
  [self markNotificationAsRead:notification withSimilar:YES];

  // load action url
  NSURL *url = [notification href];
  [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)menuShowMessage:(id)sender
{
  FBMessage *message = ([sender isMemberOfClass:[FBMessage class]] ? sender : [sender representedObject]);

  // mark this message as read
  [self markMessageAsRead:message];

  // load inbox url
  NSURL *inboxURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.facebook.com/inbox/?tid=%@",
                                                                    [message objectForKey:@"thread_id"]]];
  [[NSWorkspace sharedWorkspace] openURL:inboxURL];
}

- (IBAction)menuShowAllNotifications:(id)sender
{
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.facebook.com/notifications.php"]];
}

- (IBAction)changedStartAtLoginStatus:(id)sender
{
  [[LoginItemManager manager] setIsLoginItem:([sender state] == NSOffState)];
  [sender setState:([sender state] == NSOffState ? NSOnState : NSOffState)];
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

  [self updateMenu];
}

- (void)loginToFacebook
{
  [connectSession loginWithPermissions:[NSArray arrayWithObjects:@"manage_mailbox",  @"publish_stream", nil]];
}

- (void)statusUpdateWasPublished:(NSXMLDocument *)reply
{
  [bubbleManager addBubbleWithText:lastStatusUpdate
                           subText:nil
                             image:[profilePics imageForKey:[connectSession uid]]
                      notification:nil
                           message:nil];
}


#pragma mark FB Session delegate methods
- (void)FBConnectLoggedIn:(FBConnect *)fbc
{
  NSLog(@"must have logged in okay!");
  [queryManager start];
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

- (void)FBConnectErrorLoggingOut:(FBConnect *)fbc
{
  NSLog(@"couldn't log out, quitting anyway");
  [NSApp terminate:self];
}

- (void)session:(FBConnect *)session failedCallMethod:(NSError *)error
{
  NSLog(@"callMethod: failed -> %@", [[error userInfo] objectForKey:kFBErrorMessageKey]);
}

@end