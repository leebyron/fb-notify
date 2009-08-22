//
//  StatusKeyShortcut.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 8/21/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "StatusKeyShortcut.h"
#import "SRCommon.h"

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

static StatusKeyShortcut* instance;

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
    EventTypeSpec eventSpec[2] = {{kEventClassKeyboard, kEventHotKeyPressed},
                                  {kEventClassKeyboard, kEventHotKeyReleased}};
    InstallApplicationEventHandler(&globalHotKeyHandler, 2, eventSpec, (void*)self, NULL);

    // do the defaults exist? register something...
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kStatusKeyShortcutCode] == nil) {
      [self registerKeyShortcutWithCode:49 flags:NSControlKeyMask|NSAlternateKeyMask|NSCommandKeyMask];
    } else {
      [self registerKeyShortcut];
    }
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
  [[NSUserDefaults standardUserDefaults] setInteger:code  forKey:kStatusKeyShortcutCode];
  [[NSUserDefaults standardUserDefaults] setInteger:flags forKey:kStatusKeyShortcutFlags];
  [[NSUserDefaults standardUserDefaults] synchronize];

  // invalidate the menu
  [[NSApp delegate] invalidate];

  // register!
  [self registerKeyShortcut];
}

- (int)keyCode
{
  return [[NSUserDefaults standardUserDefaults] integerForKey:kStatusKeyShortcutCode];
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
  return [[NSUserDefaults standardUserDefaults] integerForKey:kStatusKeyShortcutFlags];
}

- (int)keyCarbonFlags
{
  return SRCocoaToCarbonFlags([self keyFlags]);
}

@end
