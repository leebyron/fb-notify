//
//  FBNotification.m
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import "FBNotification.h"
#import "GlobalSession.h"
#import <FBCocoa/FBCocoa.h>

@interface FBNotification (Private)

- (NSString*)lastURLInHTML:(NSString*)string;

@end

@implementation FBNotification

@synthesize href;

+ (FBNotification*)notificationWithXMLNode:(NSXMLNode*)node
                                   manager:(NotificationManager*)mngr
{
  return [[self alloc] initWithXMLNode:node manager:mngr];
}

- (id)initWithXMLNode:(NSXMLNode*)node
              manager:(NotificationManager*)mngr
{
  self = [super initWithXMLNode:node];
  if (self) {
    manager = mngr;

    // find and fill href var
    NSString* hrefString = [self objectForKey:@"href"];

    // this page is bogus.
    if ([hrefString rangeOfString:@"facebook.com/notifications.php"].location != NSNotFound) {
      hrefString = nil;
    }

    if (hrefString == nil || [hrefString length] == 0) {
      // try to find it in the title html
      hrefString = [self lastURLInHTML:[self stringForKey:@"title_html"]];
    }

    if (hrefString == nil || [hrefString length] == 0) {
      // body html?
      hrefString = [self lastURLInHTML:[self stringForKey:@"body_html"]];
    }

    if (hrefString == nil || [hrefString length] == 0) {
      // fine, use the default notification url
      hrefString = @"http://www.facebook.com/notifications.php";
    }

    href = [[NSURL URLWithString:hrefString] retain];
  }
  return self;
}

- (void)dealloc
{
  [href release];
  [super dealloc];
}

- (void)markAsReadWithSimilar:(BOOL)markSimilar
{
  NSArray* notifs;
  if (markSimilar) {
    notifs = [manager notificationsWithTarget:href];
  } else {
    notifs = [NSArray arrayWithObject:self];
  }
  if ([notifs count] > 0) {
    for (FBNotification* notif in notifs) {
      [notif setObject:@"0" forKey:@"is_unread"];
    }
    [[manager unreadNotifications] removeObjectsInArray:notifs];
    [[NSApp delegate] invalidate];

    [connectSession callMethod:@"notifications.markRead"
                 withArguments:[NSDictionary dictionaryWithObject:[notifs componentsJoinedByString:@","] forKey:@"notification_ids"]
                        target:self
                      selector:nil
                         error:@selector(markReadError:)];
  }
}

#pragma mark Private methods
- (NSString*)lastURLInHTML:(NSString*)html
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

- (void)markReadError:(NSError*)error
{
  NSLog(@"mark as read failed -> %@", [[error userInfo] objectForKey:kFBErrorMessageKey]);
}

- (NSString*)description {
  return [self objectForKey:@"notification_id"];
}

@end
