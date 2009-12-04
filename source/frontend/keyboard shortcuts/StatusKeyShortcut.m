//
//  StatusKeyShortcut.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 8/21/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "StatusKeyShortcut.h"
#import "SRCommon.h"
#import "FBPreferenceManager.h"


@interface StatusKeyShortcut (Private)

- (id)initWithTarget:(id)t selector:(SEL)s;
- (OSStatus)keyShortcutCallback;
- (void)registerKeyShortcut;

@end


// Global hot key reciever
OSStatus globalHotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void* userData)
{
  return [(id)userData keyShortcutCallback];
}


@implementation StatusKeyShortcut

static StatusKeyShortcut* instance = nil;

+ (StatusKeyShortcut*)instance
{
  return instance;
}

+ (void)setupWithTarget:(id)t selector:(SEL)s {
  instance = [[StatusKeyShortcut alloc] initWithTarget:t selector:s];
}

- (id)initWithTarget:(id)t selector:(SEL)s
{
  self = [super init];
  if (self) {
    // remember the callback
    target   = t;
    selector = s;

    // create a carbon event handler for a global hot key
    EventTypeSpec eventSpec[1] = {{kEventClassKeyboard, kEventHotKeyPressed}};//,
                                  //{kEventClassKeyboard, kEventHotKeyReleased}};
    InstallApplicationEventHandler(&globalHotKeyHandler, 2, eventSpec, (void*)self, NULL);
    
    [[FBPreferenceManager manager] registerForKey:kStatusKeyShortcutCode
                                     defaultValue:[NSNumber numberWithInt:49]];
    [[FBPreferenceManager manager] registerForKey:kStatusKeyShortcutFlags
                                     defaultValue:[NSNumber numberWithInt:NSControlKeyMask|NSAlternateKeyMask|NSCommandKeyMask]];
    
    [self registerKeyShortcut];
  }
  return self;
}

- (void)dealloc
{
  [super dealloc];
}

- (OSStatus)keyShortcutCallback
{
  [target performSelector:selector];
  return noErr;
}

- (void)registerKeyShortcut
{
  // remove existing shortcut
  if (statusKeyRef) {
    UnregisterEventHotKey(statusKeyRef);
  }

  // assign this new shortcut
  if ([self keyCode]) {
    EventHotKeyID statusKeyID;
    statusKeyID.signature = 'fbs1';
    statusKeyID.id = (uint) self;
    RegisterEventHotKey([self keyCode], [self keyCarbonFlags], statusKeyID,
                        GetApplicationEventTarget(), 0, &statusKeyRef);
  }
}

- (void)registerKeyShortcutWithCode:(int)code flags:(int)flags
{
  // remember this!
  [[FBPreferenceManager manager] setInt:code forKey:kStatusKeyShortcutCode];
  [[FBPreferenceManager manager] setInt:flags forKey:kStatusKeyShortcutFlags];

  // invalidate the menu
  [[NSApp delegate] invalidate];

  // register!
  [self registerKeyShortcut];
}

- (int)keyCode
{
  return [[FBPreferenceManager manager] intForKey:kStatusKeyShortcutCode];
}

- (NSString*)keyCodeString
{
  NSString* keyString = SRStringForKeyCode([self keyCode]);
  keyString = [keyString lowercaseString];
  if ([keyString isEqual:@"space"]) {
    keyString = @" ";
  }
  return keyString;
}

- (int)keyFlags
{
  return [[FBPreferenceManager manager] intForKey:kStatusKeyShortcutFlags];
}

- (int)keyCarbonFlags
{
  return SRCocoaToCarbonFlags([self keyFlags]);
}

@end
