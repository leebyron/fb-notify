//
//  BubbleManager.m
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import "BubbleManager.h"
#import "FacebookNotifierController.h"
#import "BubbleWindow.h"
#import "BubbleView.h"
#import "BubbleDimensions.h"
#import "PreferencesWindow.h"
#import "NSString+.h"
#import "FBPreferenceManager.h"

#define kGrowlTypeEmpty @"0"
#define kGrowlTypeNotif @"Facebook Notification"
#define kGrowlTypeMsg @"Facebook Message"
#define kGrowlTypeConfirm @"Status Update Confirmation"


@implementation BubbleManager

static BubbleManager* manager = nil;

@synthesize windows;

+ (BubbleManager*)manager
{
  if (manager == nil) {
    manager = [[BubbleManager alloc] init];
  }
  return manager;
}

- (id)init
{
  self = [super init];
  if (self) {
    windows = [[NSMutableArray alloc] init];
    [GrowlApplicationBridge setGrowlDelegate:self];

    // get ready to hold onto growls
    pendingGrowls = [[NSMutableDictionary alloc] init];

    [[FBPreferenceManager manager] registerForKey:kUseGrowlOption defaultValue:[NSNumber numberWithBool:YES]];
  }
  return self;
}

- (void)dealloc
{
  [windows release];
  [pendingGrowls release];
  [super dealloc];
}

- (BOOL)useGrowl
{
  return [GrowlApplicationBridge isGrowlRunning] &&
    [[FBPreferenceManager manager] boolForKey:kUseGrowlOption];
}

- (void)addBubbleWithText:(NSString*)text
                  subText:(NSString*)subText
                    image:(NSImage*)image
                   action:(id)action
{
  text = [text condenseString];
  subText = [subText condenseString];

  if ([self useGrowl]) {
    NSString* notifName = ([action isKindOfClass:[FBNotification class]] ? kGrowlTypeNotif :
                           ([action isKindOfClass:[FBMessage class]] ? kGrowlTypeMsg : kGrowlTypeConfirm));
    NSString* notifContext = kGrowlTypeEmpty;
    if (action) {
      notifContext = [[NSNumber numberWithLong:time(NULL)] stringValue];
      [pendingGrowls setObject:action forKey:notifContext];
    }
    [GrowlApplicationBridge notifyWithTitle:text
                                description:subText
                           notificationName:notifName
                                   iconData:[image TIFFRepresentation]
                                   priority:0
                                   isSticky:NO
                               clickContext:notifContext];
  } else {
    NSSize windowSize = [BubbleView totalSizeWithText:text subText:subText withImage:(image != nil) maxWidth:kBubbleMaxWidth];
    float menuBarHeight = [[NSApp menu] menuBarHeight];
    NSSize screen = [[NSScreen mainScreen] frame].size;

    float windowX = screen.width - windowSize.width - kBubbleSpacing;
    float windowY = screen.height - menuBarHeight - windowSize.height - kBubbleSpacing;
    for (BubbleWindow* w in windows) {
      windowY = MIN([w frame].origin.y - windowSize.height - kBubbleSpacing + kBubbleShadowSpacing, windowY);
    }
    NSRect windowRect = NSMakeRect(windowX, windowY, windowSize.width, windowSize.height);

    BubbleWindow* window = [[BubbleWindow alloc] initWithFrame:windowRect
                                                         image:image
                                                          text:text
                                                       subText:subText
                                                        action:action];
    [window appear];
    [windows addObject:window];
    [window release];
  }
}

- (void)executeAction:(id)aAction
{
  if ([aAction isKindOfClass:[FBNotification class]]) {
    [[NSApp delegate] menuShowNotification:aAction];
  } else if ([aAction isKindOfClass:[FBMessage class]]) {
    [[NSApp delegate] menuShowMessage:aAction];
  } else if ([aAction isKindOfClass:[NSURL class]]) {
    [[NSWorkspace sharedWorkspace] openURL:aAction];
  }
}

- (void)growlIsReady
{
  [PreferencesWindow refresh];
}

- (void) growlNotificationWasClicked:(id)clickContext
{
  if (![clickContext isEqual:kGrowlTypeEmpty]) {
    [self executeAction:[pendingGrowls objectForKey:clickContext]];
    [pendingGrowls removeObjectForKey:clickContext];
  }
}

- (void) growlNotificationTimedOut:(id)clickContext
{
  if (![clickContext isEqual:kGrowlTypeEmpty]) {
    [pendingGrowls removeObjectForKey:clickContext];
  }
}

@end
