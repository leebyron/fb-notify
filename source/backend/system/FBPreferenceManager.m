//
//  FBPreferenceManager.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 12/3/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "FBPreferenceManager.h"

#define kPreferenceDictionary @"Preferences"
#define kPreferenceVersion @"PreferencesVersion"


@implementation FBPreferenceManager

static FBPreferenceManager* instance = nil;

+ (FBPreferenceManager*)manager
{
  if (instance == nil) {
    instance = [[FBPreferenceManager alloc] init];
  }
  return instance;
}

- (id)init
{
  if (self = [super init]) {
    defaults = [[NSMutableDictionary alloc] init];
    preferences = [[NSMutableDictionary alloc] init];

    // after a second of boot time, assume everything has been registered and
    // wipe the rest clean
    [self performSelector:@selector(synchronize) withObject:nil afterDelay:1.0];
  }
  return self;
}

- (void)dealloc
{
  [defaults release];
  [preferences release];
  [super dealloc];
}

- (void)registerForKey:(NSString*)aKey
          defaultValue:(id)val
{
  [defaults setValue:val forKey:aKey];

  NSDictionary* dict = [[NSUserDefaults standardUserDefaults] objectForKey:kPreferenceDictionary];
  id pref = [dict valueForKey:aKey];
  if (pref != nil) {
    [preferences setValue:pref forKey:aKey];
  } else {
    // try the raw entry
    pref = [[NSUserDefaults standardUserDefaults] objectForKey:aKey];
    if (pref != nil) {
      [preferences setValue:pref forKey:aKey];
    }
  }
}

- (void)synchronize
{
  // check the version and if it's outdated, wipe the whole prefs dictionary clean
  NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
  NSString* v = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
  if (![[ud objectForKey:kPreferenceVersion] isEqualToString:v]) {
    for (NSString* key in [ud dictionaryRepresentation]) {
      [ud removeObjectForKey:key];
    }
    [ud setObject:v forKey:kPreferenceVersion];
  }

  [ud setObject:preferences forKey:kPreferenceDictionary];
  [ud synchronize];
}

- (id)objectForKey:(NSString*)aKey
{
  id val = [preferences valueForKey:aKey];
  if (val != nil) {
    return val;
  }
  
  return [defaults valueForKey:aKey];
}

- (void)setObject:(id)value forKey:(NSString*)aKey
{
  [preferences setValue:value forKey:aKey];
  [self synchronize];
}

- (int)intForKey:(NSString*)aKey
{
  return [[self objectForKey:aKey] intValue];
}

- (float)floatForKey:(NSString*)aKey
{
  return [[self objectForKey:aKey] floatValue];
}

- (BOOL)boolForKey:(NSString*)aKey
{
  return [self intForKey:aKey] == 1;
}

- (void)setInt:(int)value forKey:(NSString*)aKey
{
  [self setObject:[NSNumber numberWithInt:value] forKey:aKey];
}

- (void)setFloat:(float)value forKey:(NSString*)aKey
{
  [self setObject:[NSNumber numberWithFloat:value] forKey:aKey];
}

- (void)setBool:(BOOL)value forKey:(NSString*)aKey
{
  [self setInt:(value ? 1 : 0) forKey:aKey];
}

@end
