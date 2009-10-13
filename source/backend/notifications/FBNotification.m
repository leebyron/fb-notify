//
//  FBNotification.m
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import "FBNotification.h"
#import "NSString+.h"


@interface FBNotification (Private)

- (id)initWithDictionary:(NSDictionary*)dict
                 manager:(NotificationManager*)mngr;
- (NSURL*)findActionURL;
- (NSString*)lastURLInHTML:(NSString*)string;

@end


@implementation FBNotification

@synthesize href;

+ (FBNotification*)notificationWithDictionary:(NSDictionary*)dict
                                      manager:(NotificationManager*)mngr
{
  return [[self alloc] initWithDictionary:dict manager:mngr];
}

- (id)initWithDictionary:(NSDictionary*)dict
              manager:(NotificationManager*)mngr
{
  self = [super initWithDictionary:dict];
  if (self) {
    manager = mngr;
    href = [[self findActionURL] retain];
  }
  return self;
}

- (void)dealloc
{
  [href release];
  [super dealloc];
}

- (void)markAsSeen
{
  [manager markAsSeen:self];
}

- (void)markAsReadWithSimilar:(BOOL)markSimilar
{
  [manager markAsRead:self withSimilar:markSimilar];
}


#pragma mark Private methods
- (NSURL*)findActionURL
{
  // find and fill href var
  NSString* hrefString = [self stringForKey:@"href"];

  // this page is bogus.
  if ([NSString exists:hrefString] && [hrefString rangeOfString:@"facebook.com/notifications.php"].location != NSNotFound) {
    hrefString = nil;
  }

  if (![NSString exists:hrefString]) {
    // try to find it in the title html
    hrefString = [self lastURLInHTML:[self stringForKey:@"title_html"]];
  }

  if (![NSString exists:hrefString]) {
    // body html?
    hrefString = [self lastURLInHTML:[self stringForKey:@"body_html"]];
  }

  if (![NSString exists:hrefString]) {
    // fine, use the default notification url
    hrefString = @"http://www.facebook.com/notifications.php";
  }

  if (hrefString) {
    // make sure href string is healthy, and get rid of that pesky &comments barf.
    hrefString = [[hrefString stringByDecodingXMLEntities] stringByRemovingStrings:
                  [NSArray arrayWithObjects:@"&comments=1", @"&comments", @"&alert", nil]];
  }

  return [NSURL URLWithString:hrefString];
}

- (NSString*)lastURLInHTML:(NSString*)html
{
  if (![NSString exists:html]) {
    return nil;
  }
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

- (NSString*)description {
  return [self uidForKey:@"notification_id"];
}

@end
