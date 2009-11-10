//
//  StatusUpdateWindow.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 11/4/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "StatusUpdateWindow.h"
#import "StatusUpdateManager.h"
#import "PhotoAttachmentView.h"

#define kStatusUpdateWindowX @"statusUpdateWindowX"
#define kStatusUpdateWindowY @"statusUpdateWindowY"
#define kStatusUpdateWindowScreen @"statusUpdateWindowScreen"
#define kStatusUpdateWindowWidth 480


@implementation StatusUpdateWindow

static StatusUpdateWindow* currentWindow = nil;

////////////////////////////////////////////////////////////////////////////////////
// Static Methods

+ (id)open
{
  currentWindow = [[[StatusUpdateWindow alloc] init] autorelease];
  return currentWindow;
}

+ (StatusUpdateWindow*)currentWindow
{
  return currentWindow;
}

////////////////////////////////////////////////////////////////////////////////////
// Instance Methods

@synthesize attachment;

- (id)init
{
  // get prefered window position if set
  NSPoint loc;
  loc.x = [[NSUserDefaults standardUserDefaults] floatForKey:kStatusUpdateWindowX];
  loc.y = [[NSUserDefaults standardUserDefaults] floatForKey:kStatusUpdateWindowY];
  NSUInteger screen = [[NSUserDefaults standardUserDefaults] integerForKey:kStatusUpdateWindowScreen];
  if (loc.x == 0 && loc.y == 0) {
    loc.x = 0.5;
    loc.y = 0.75;
  }

  if (self = [super initWithLocation:loc screenNum:screen]) {
    messageBox = [[FBExpandingTextView alloc] initWithFrame:NSMakeRect(0, 0, kStatusUpdateWindowWidth, 46)];
    messageBox.delegate = self;
    [self addSubview:messageBox];

    attachmentBox = [[AttachmentBox alloc] initWithFrame:NSMakeRect(0, 0, kStatusUpdateWindowWidth, 0)];
    [self addSubview:attachmentBox];

    NSView* buttonBar = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, kStatusUpdateWindowWidth, 18)];
    [self addSubview:buttonBar];
    [buttonBar release];

    NSButton* button = [[FBButton alloc] initWithFrame:NSMakeRect(kStatusUpdateWindowWidth - 60, 0, 60, 18)];
    button.bezelStyle = NSRoundRectBezelStyle;//NSShadowlessSquareBezelStyle;//NSSmallSquareBezelStyle;
    button.title = NSLocalizedString(@"Share", @"Button title for sending a status update");
    button.toolTip = @"⌘Enter";
    button.target = self;
    button.action = @selector(share:);
    [buttonBar addSubview:button];
    [button release];

    removeButton = [[FBButton alloc] initWithFrame:NSMakeRect(0, 0, 100, 18)];
    removeButton.target = self;
    removeButton.action = @selector(removeButtonPressed);
    removeButton.title = @"Add Photo";
    removeButton.showsBorderOnlyWhileMouseInside = YES;
    removeButton.bezelStyle = NSRecessedBezelStyle;
    [buttonBar addSubview:removeButton];
  }
  return self;
}

- (void)dealloc
{
  [messageBox release];
  [attachmentBox release];
  [attachment release];
  [super dealloc];
}

- (void)removeButtonPressed
{
  if (attachment) {
    [[StatusUpdateManager manager] removeAttachment];
  } else {
    self.attachment = [[[PhotoAttachmentView alloc] init] autorelease];
  }
}

- (void)close
{
  [super close];
  currentWindow = nil;
}

- (IBAction)cancel:(id)sender
{
  [self close];
}

- (IBAction)submit:(id)sender
{
  if ([[StatusUpdateManager manager] sendPost:[self streamPost]]) {
    [self close];
  }
}

- (NSDictionary*)streamPost
{
  NSMutableDictionary* post = [NSMutableDictionary dictionary];
  [post setObject:[[[messageBox documentView] string] copy] forKey:@"message"];

  if ([attachment isKindOfClass:[PhotoAttachmentView class]] &&
      ((PhotoAttachmentView*)attachment).image) {
    [post setObject:((PhotoAttachmentView*)attachment).image forKey:@"image"];
  }

  return post;
}

- (NSString *)statusMessage
{
  return [NSString stringWithString:[[messageBox documentView] string]];
}

- (void)setAttachment:(NSView*)view
{
  // retain new view
  [view retain];
  [attachment release];
  attachment = view;
  
  // set the appropriate width to fit
  [view setFrameSize:NSMakeSize(kStatusUpdateWindowWidth, view.frame.size.height)];

  // remove all existing views
  NSView* contentView = [attachmentBox contentView];
  for (NSView* v in contentView.subviews) {
    [v removeFromSuperview];
  }

  // attach new view
  if (view) {
    [contentView addSubview:view];
  }
  [attachmentBox sizeToFit];

  // listen for future resizing!
  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(attachmentFrameDidChange:)
   name:NSViewFrameDidChangeNotification
   object:view];
  
  // set remove button
  removeButton.title = view ? @"Remove Photo" : @"Add Photo";
}

- (void)attachmentFrameDidChange:(NSNotification*)notif
{
  if (currentlySizing) {
    return;
  }
  currentlySizing = YES;
  [attachmentBox sizeToFit];
  currentlySizing = NO;
}

- (void)windowDidMove:(NSNotification*)notif
{
  [super windowDidMove:notif];

  // record to prefs
  [[NSUserDefaults standardUserDefaults] setFloat:self.location.x forKey:kStatusUpdateWindowX];
  [[NSUserDefaults standardUserDefaults] setFloat:self.location.y forKey:kStatusUpdateWindowY];
  [[NSUserDefaults standardUserDefaults] setInteger:self.screenNum forKey:kStatusUpdateWindowScreen];
  [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
