//
//  FBNotification.m
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import "FBNotification.h"


@implementation FBNotification

+ (FBNotification *)notificationWithXMLNode:(NSXMLNode *)node
{
  return [[[self alloc] initWithXMLNode:node] autorelease];
}

- (id)initWithXMLNode:(NSXMLNode *)node
{
  self = [super init];
  if (self) {
    fields = [[NSMutableDictionary alloc] init];
    for (NSXMLNode *child in [node children]) {
      // Convert from underscore_words to camelCase
      NSArray *words = [[child name] componentsSeparatedByString:@"_"];
      NSMutableString *key = [NSMutableString stringWithString:[words objectAtIndex:0]];
      int i;
      for (i = 1; i < [words count]; i++) {
        [key appendString:[[words objectAtIndex:i] capitalizedString]];
      }

      [fields setObject:[child stringValue] forKey:key];
    }
  }
  return self;
}

- (void)dealloc
{
  [fields release];
  [super dealloc];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
  // Small sanity check: make sure it's a no-parameter method
  NSString *name = NSStringFromSelector(sel);
  if ([[name componentsSeparatedByString:@":"] count] > 1) {
    return nil;
  }

  return [super methodSignatureForSelector:@selector(thing)];
}

- (id)thing {
  return nil;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
  // Kids, don't try this at home
  NSString *name = NSStringFromSelector([invocation selector]);

  // Look up the key
  id content = [fields objectForKey:name];
  [invocation setReturnValue:&content];
}

@end
