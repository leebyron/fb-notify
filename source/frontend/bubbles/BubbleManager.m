//
//  BubbleManager.m
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import "BubbleManager.h"
#import "ApplicationController.h"
#import "BubbleWindow.h"
#import "BubbleView.h"
#import "BubbleDimensions.h"
#import "PreferencesWindow.h"
#import "NSString+.h"

#define kGrowlTypeNotif @"Facebook Notification"
#define kGrowlTypeMsg @"Facebook Message"
#define kGrowlTypeConfirm @"Status Update Confirmation"


@implementation BubbleManager

@synthesize windows;

- (id)init
{
  self = [super init];
  if (self) {
    windows = [[NSMutableArray alloc] init];
    [GrowlApplicationBridge setGrowlDelegate:self];

    // get ready to hold onto growls
    pendingGrowls = [[NSMutableDictionary alloc] init];

    // if we don't know what to set growl, set it to USE!
    if ([[NSUserDefaults standardUserDefaults] integerForKey:kUseGrowlOption] == GROWL_UNKNOWN) {
      [[NSUserDefaults standardUserDefaults] setInteger:GROWL_USE forKey:kUseGrowlOption];
      [[NSUserDefaults standardUserDefaults] synchronize];
    }
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
  return [GrowlApplicationBridge isGrowlRunning] && [[NSUserDefaults standardUserDefaults] integerForKey:kUseGrowlOption] == GROWL_USE;
}

- (void)addBubbleWithText:(NSString*)text
                  subText:(NSString*)subText
                    image:(NSImage*)image
             notification:(FBNotification*)notif
                  message:(FBMessage*)msg
{
  text = [text condenseString];
  subText = [subText condenseString];

  if ([self useGrowl]) {
    NSString* notifName = (notif ? kGrowlTypeNotif : (msg ? kGrowlTypeMsg : kGrowlTypeConfirm));
    NSString* notifContext = kGrowlTypeConfirm;
    if (notif || msg) {
      notifContext = [[NSNumber numberWithLong:time(NULL)] stringValue];
      [pendingGrowls setObject:(notif != nil ? (id)notif : (id)msg) forKey:notifContext];
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
    float menuBarHeight = [[[NSApplication sharedApplication] menu] menuBarHeight];
    NSSize screen = [[NSScreen mainScreen] frame].size;

    float windowX = screen.width - windowSize.width - kBubbleSpacing;
    float windowY = screen.height - menuBarHeight - windowSize.height - kBubbleSpacing;
    for (BubbleWindow* w in windows) {
      windowY = MIN([w frame].origin.y - windowSize.height - kBubbleSpacing + kBubbleShadowSpacing, windowY);
    }
    NSRect windowRect = NSMakeRect(windowX, windowY, windowSize.width, windowSize.height);

    BubbleWindow* window = [[BubbleWindow alloc] initWithManager:self
                                                           frame:windowRect
                                                           image:image
                                                            text:text
                                                         subText:subText
                                                    notification:notif
                                                         message:msg];
    [window appear];
    [windows addObject:window];
    [window release];
  }
}

- (void)growlIsReady
{
  [PreferencesWindow refresh];
}

- (void) growlNotificationWasClicked:(id)clickContext
{
  if (![clickContext isEqual:kGrowlTypeConfirm]) {
    id obj = [pendingGrowls objectForKey:clickContext];
    if ([obj isKindOfClass:[FBNotification class]]) {
      [[NSApp delegate] menuShowNotification:obj];
    } else {
      [[NSApp delegate] menuShowMessage:obj];
    }
    [pendingGrowls removeObjectForKey:clickContext];
  }
}

- (void) growlNotificationTimedOut:(id)clickContext
{
  if (![clickContext isEqual:kGrowlTypeConfirm]) {
    [pendingGrowls removeObjectForKey:clickContext];
  }
}

@end
