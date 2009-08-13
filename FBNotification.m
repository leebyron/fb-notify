//
//  FBNotification.m
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import "FBNotification.h"
#import "NSString-XML.h"
#import "GlobalSession.h"
#import <FBCocoa/FBCocoa.h>

@interface FBNotification (Private)

- (NSString *)lastURLInHTML:(NSString *)string;

@end

@implementation FBNotification

@synthesize href;

+ (FBNotification *)notificationWithXMLNode:(NSXMLNode *)node manager:(NotificationManager *)mngr
{
  return [[[self alloc] initWithXMLNode:node manager:mngr] autorelease];
}

- (id)initWithXMLNode:(NSXMLNode *)node manager:(NotificationManager *)mngr
{
  self = [super init];
  if (self) {
    manager = mngr;
    fields = [[NSMutableDictionary alloc] init];
    for (NSXMLElement *child in [node children]) {

      // skip nil values
      if ([[[child attributeForName:@"nil"] stringValue] isEqualToString:@"true"]) {
        continue;
      }

      // Convert from underscore_words to camelCase
      NSArray *words = [[child name] componentsSeparatedByString:@"_"];
      NSMutableString *key = [NSMutableString stringWithString:[words objectAtIndex:0]];
      int i;
      for (i = 1; i < [words count]; i++) {
        [key appendString:[[words objectAtIndex:i] capitalizedString]];
      }

      [fields setObject:[child stringValue] forKey:key];
    }

    // find and fill href var
    NSString *hrefString = [self objForKey:@"href"];
    if (hrefString == nil || [hrefString length] == 0) {
      // try to find it in the title html
      hrefString = [self lastURLInHTML:[self stringForKey:@"titleHtml"]];

      if (hrefString == nil || [hrefString length] == 0) {
        // body html?
        hrefString = [self lastURLInHTML:[self stringForKey:@"bodyHtml"]];
      }
    }
    href = [[NSURL URLWithString:hrefString] retain];
  }
  return self;
}

- (void)dealloc
{
  [href release];
  [fields release];
  [super dealloc];
}

- (void)markAsReadWithSimilar:(BOOL)markSimilar
{
  NSArray *notifs;
  if (markSimilar) {
    notifs = [manager notificationsWithTarget:href];
  } else {
    notifs = [NSArray arrayWithObject:self];
  }
  if ([notifs count] > 0) {
    for (FBNotification *notif in notifs) {
      [notif setObject:@"0" forKey:@"isUnread"];
    }
    [[manager unreadNotifications] removeObjectsInArray:notifs];
    [connectSession callMethod:@"notifications.markRead"
                 withArguments:[NSDictionary dictionaryWithObject:[notifs componentsJoinedByString:@","] forKey:@"notification_ids"]
                        target:self
                      selector:nil
                         error:@selector(markReadError:)];
  }
}

- (void)setObject:(id)obj forKey:(NSString *)key
{
  [fields setObject:obj forKey:key];
}

- (NSString *)objForKey:(NSString *)key
{
  return [fields objectForKey:key];
}

- (NSString *)stringForKey:(NSString *)key
{
  return [[fields objectForKey:key] stringByDecodingXMLEntities];
}

- (BOOL)boolForKey:(NSString *)key
{
  return [[fields objectForKey:key] isEqualToString:@"1"];
}

- (NSURL *)urlForKey:(NSString *)key
{
  return [NSURL URLWithString:[fields objectForKey:key]];
}

#pragma mark Private methods
- (NSString *)lastURLInHTML:(NSString *)html
{
  NSRange startHref = [html rangeOfString:@"href=\""
                                  options:NSBackwardsSearch];
  if (startHref.location == NSNotFound) {
    return nil;
  }
  int startUrl = startHref.location + startHref.length;
  NSRange endHref = [html rangeOfString:@"\""
                                options:0
                                  range:NSMakeRange(startUrl,
                                                    [html length] - startUrl)];
  return [html substringWithRange:NSMakeRange(startUrl,
                                              endHref.location - startUrl)];
}

- (void)markReadError:(NSError *)error
{
  NSLog(@"mark as read failed -> %@", [[error userInfo] objectForKey:kFBErrorMessageKey]);
}

- (NSString *)description {
  return [self objForKey:@"notificationId"];
}

@end
