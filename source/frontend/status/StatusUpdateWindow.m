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
#import "LinkAttachmentView.h"
#import "FBPreferenceManager.h"

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
  FBPreferenceManager* prefs = [FBPreferenceManager manager];
  [prefs registerForKey:kStatusUpdateWindowX
           defaultValue:[NSNumber numberWithFloat:0.5]];
  [prefs registerForKey:kStatusUpdateWindowY
           defaultValue:[NSNumber numberWithFloat:0.75]];
  [prefs registerForKey:kStatusUpdateWindowScreen
           defaultValue:[NSNumber numberWithInt:0]];

  // get prefered window position if set
  NSPoint loc = NSMakePoint([prefs floatForKey:kStatusUpdateWindowX],
                            [prefs floatForKey:kStatusUpdateWindowY]);

  if (self = [super initWithLocation:loc screenNum:[prefs intForKey:kStatusUpdateWindowScreen]]) {
    messageBox = [[FBExpandingTextView alloc] initWithFrame:NSMakeRect(0, 0, kStatusUpdateWindowWidth, 46)];
    messageBox.delegate = self;
    [self addSubview:messageBox];

    attachmentBox = [[AttachmentBox alloc] initWithFrame:NSMakeRect(0, 0, kStatusUpdateWindowWidth, 0)];
    [self addSubview:attachmentBox];

    NSView* buttonBar = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, kStatusUpdateWindowWidth, 18)];
    [self addSubview:buttonBar];
    [buttonBar release];

    // share button
    FBButton* button = [[FBButton alloc] initWithFrame:NSMakeRect(0, 0, 0, 18)];
    button.title = NSLocalizedString(@"Share", @"Button title for sending a status update");
    button.toolTip = @"⌘Enter";
    button.target = self;
    button.action = @selector(submit:);
    NSRect buttonFrame = button.frame;
    buttonFrame.origin.x = kStatusUpdateWindowWidth - button.frame.size.width;
    button.frame = buttonFrame;
    [buttonBar addSubview:button];
    [button release];

    // remove button
    removeButton = [[FBButton alloc] initWithFrame:NSMakeRect(0, 0, 0, 18)];
    removeButton.target = self;
    removeButton.action = @selector(removeButtonPressed);
    removeButton.isChromeless = YES;
    [buttonBar addSubview:removeButton];

    // set default case
    self.attachment = nil;
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

- (void)appendString:(NSString*)string
{
  NSTextView* view = ((NSTextView*)[messageBox documentView]);

  if ([[view string] length] > 0) {
    string = [NSString stringWithFormat:@" %@", string];
  }

  NSAttributedString *stringToAppend =
    [[NSAttributedString alloc] initWithString:string];

  [[view textStorage] appendAttributedString:stringToAppend];

  [stringToAppend release];
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
    [post setObject:((PhotoAttachmentView*)attachment).image forKey:@"image_data"];
  }

  if ([attachment isKindOfClass:[LinkAttachmentView class]] &&
      ((LinkAttachmentView*)attachment).link) {
    [post setObject:[((LinkAttachmentView*)attachment).link absoluteString] forKey:@"link"];
    if (((LinkAttachmentView*)attachment).image) {
      [post setObject:((LinkAttachmentView*)attachment).image forKey:@"image_url"];
    }
  }

  return post;
}

- (void)setAttachment:(NSView*)view
{
  // retain new view
  [view retain];
  [attachment release];
  attachment = view;

  // set appropriate margins
  [attachmentBox setContentViewMargins:(view == nil ? NSZeroSize :
                                        NSMakeSize(kAttachmentEdgeMargin, kAttachmentEdgeMargin))];

  // remove all existing views
  NSView* contentView = [attachmentBox contentView];
  for (NSView* v in contentView.subviews) {
    [v removeFromSuperview];
  }

  // attach new view & set the appropriate width to fit
  if (view) {
    [view setFrameSize:NSMakeSize(kStatusUpdateWindowWidth - attachmentBox.contentViewMargins.width * 2,
                                  view.frame.size.height)];
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
  if (!view) {
    removeButton.title = NSLocalizedString(@"Add Photo", @"Button to add a photo attachment");
  } else if ([view isKindOfClass:[PhotoAttachmentView class]]) {
    removeButton.title = NSLocalizedString(@"Remove Photo", @"Button to remove a photo attachment");
  } else if ([view isKindOfClass:[LinkAttachmentView class]]) {
    removeButton.title = NSLocalizedString(@"Remove Link", @"Button to remove a link attachment");
  } else {
    removeButton.title = NSLocalizedString(@"Remove Attachment", @"Button to remove a generic attachment");
  }
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
  FBPreferenceManager* prefs = [FBPreferenceManager manager];
  [prefs setFloat:self.location.x forKey:kStatusUpdateWindowX];
  [prefs setFloat:self.location.y forKey:kStatusUpdateWindowY];
  [prefs setFloat:self.screenNum  forKey:kStatusUpdateWindowScreen];
}

@end
