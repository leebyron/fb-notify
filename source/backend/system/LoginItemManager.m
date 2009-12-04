//
//  LoginItemManager.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 8/20/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "LoginItemManager.h"
#import "NSString+.h"


#define kStartAtLoginOption @"StartAtLogin"
#define kStartAtLoginOptionPath @"StartAtLoginPath"


enum {
  START_AT_LOGIN_UNKNOWN,
  START_AT_LOGIN_NO,
  START_AT_LOGIN_YES,
};


@interface LoginItemManager (Private)

-(BOOL) wasLaunchedByProcess:(NSString*)creator;
-(void) enableLoginItemWithLoginItemsReference:(LSSharedFileListRef)theLoginItemsRefs
                                       forPath:(CFURLRef)thePath;
-(void) disableLoginItemWithLoginItemsReference:(LSSharedFileListRef)theLoginItemsRefs
                                        forPath:(CFURLRef)thePath;

@end


@implementation LoginItemManager

static LoginItemManager* instance = nil;

+ (LoginItemManager*)manager
{
  if (instance == nil) {
    instance = [[LoginItemManager alloc] init];
  }
  return instance;
}

- (id)init
{
  self = [super init];
  if (self) {
    // check to make sure it's in the same position if it is a login item
    NSString *startupPath = [[NSUserDefaults standardUserDefaults] stringForKey:kStartAtLoginOptionPath];
    if ([self isLoginItem] && [NSString exists:startupPath] &&
         ![startupPath isEqual:[[NSBundle mainBundle] bundlePath]]) {
      [self setIsLoginItem:NO];
      [self setIsLoginItem:YES];
    }
  }
  return self;
}

- (void)loginItemAsDefault:(BOOL)isDefault
{
  int startupLaunch = [[NSUserDefaults standardUserDefaults] integerForKey:kStartAtLoginOption];
  if (startupLaunch == START_AT_LOGIN_UNKNOWN) {
    [self setIsLoginItem:isDefault];
  }
}

-(BOOL) wasLaunchedAsLoginItem
{
  // If the launching process was 'loginwindow', we were launched as a login item
  return [self wasLaunchedByProcess:@"lgnw"];
}

-(BOOL) isLoginItem
{
  return [[NSUserDefaults standardUserDefaults] integerForKey:kStartAtLoginOption] == START_AT_LOGIN_YES;
}

-(void) setIsLoginItem:(BOOL)status
{
	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);

	if (loginItems) {
		if (status) {
      CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
      if (url) {
        NSLog(@"adding to login items: %@", url);
        [self enableLoginItemWithLoginItemsReference:loginItems forPath:url];
        [[NSUserDefaults standardUserDefaults] setInteger:START_AT_LOGIN_YES forKey:kStartAtLoginOption];
        [[NSUserDefaults standardUserDefaults] setObject:[[NSBundle mainBundle] bundlePath] forKey:kStartAtLoginOptionPath];
      }
		} else {
      NSString *existingPath = [[NSUserDefaults standardUserDefaults] stringForKey:kStartAtLoginOptionPath];
      if ([NSString exists:existingPath]) {
        CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:existingPath];
        NSLog(@"removing from login items: %@", url);
        [self disableLoginItemWithLoginItemsReference:loginItems forPath:url];
        [[NSUserDefaults standardUserDefaults] setInteger:START_AT_LOGIN_NO forKey:kStartAtLoginOption];
      }
    }
	}
	CFRelease(loginItems);
  [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark Private Methods
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

- (void)enableLoginItemWithLoginItemsReference:(LSSharedFileListRef )theLoginItemsRefs
                                       forPath:(CFURLRef)thePath {
	// We call LSSharedFileListInsertItemURL to insert the item at the bottom of Login Items list.
	LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(theLoginItemsRefs, kLSSharedFileListItemLast, NULL, NULL, thePath, NULL, NULL);
	if (item)
		CFRelease(item);
}

- (void)disableLoginItemWithLoginItemsReference:(LSSharedFileListRef )theLoginItemsRefs
                                        forPath:(CFURLRef)thePath {
	UInt32 seedValue;

	// We're going to grab the contents of the shared file list (LSSharedFileListItemRef objects)
	// and pop it in an array so we can iterate through it to find our item.
	NSArray  *loginItemsArray = (NSArray *)LSSharedFileListCopySnapshot(theLoginItemsRefs, &seedValue);
	for (id item in loginItemsArray) {
		LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)item;
		if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &thePath, NULL) == noErr) {
			if ([[(NSURL *)thePath path] hasPrefix:[[NSBundle mainBundle] bundlePath]]) {
				LSSharedFileListItemRemove(theLoginItemsRefs, itemRef); // Deleting the item
      }
		}
	}

	[loginItemsArray release];
}


@end
