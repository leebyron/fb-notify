//
//  LinkAttachmentView.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 11/10/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "LinkAttachmentView.h"
#import "GlobalSession.h"

#define kEmptyLinkHeight 80


@implementation LinkAttachmentView

@synthesize link;

- (id)initWithFrame:(NSRect)frame
{
  frame.size.height = kEmptyLinkHeight;
  self = [super initWithFrame:frame];
  if (self) {
    link = nil;
  }
  return self;
}

- (void)dealloc
{
  [link release];
  [super dealloc];
}

- (void)setLink:(NSURL*)aLink
{
  [aLink retain];
  [link release];
  link = aLink;
  
  // start getting link details
  [connectSession callMethod:@"links.preview"
               withArguments:[NSDictionary dictionaryWithObject:[link absoluteString] forKey:@"url"]
                      target:self
                    selector:@selector(gotLinkPreview:)];

  [self setNeedsDisplay:YES];
}

- (void)gotLinkPreview:(id<FBRequest>)req
{
  if ([req error]) {
    NSLog(@"error getting preview %@", [req error], [[[req error] userInfo] objectForKey:kFBErrorMessageKey]);
    return;
  }

  NSLog(@"got preview %@", [req response]);
}

- (void)drawRect:(NSRect)dirtyRect
{
  NSRect promptBounds = [self bounds];
  promptBounds.size.height *= 0.6;
  NSMutableParagraphStyle* style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
  [style setAlignment:NSCenterTextAlignment];

  NSString* prompt = @"I'm a liiiink, linkin around... link. link. link. link. ";
  if (link) {
    prompt = [link absoluteString];
  }
  NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:
          style, NSParagraphStyleAttributeName,
          [NSColor colorWithCalibratedWhite:0.4 alpha:1.0], NSForegroundColorAttributeName, nil];
  [prompt drawInRect:promptBounds withAttributes:attr];
}

@end
