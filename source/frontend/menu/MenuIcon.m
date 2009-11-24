//
//  MenuIcon.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 9/17/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "MenuIcon.h"
#import "FacebookNotifierController.h"
#import "StatusUpdateManager.h"
#import "GlobalSession.h"
#import "NSImage+.h"
#import "NSPasteboard+.h"


enum {
  MENU_ICON_NORMAL     = 29, //21
  MENU_ICON_SHARE_1    = 47, //39
  MENU_ICON_SHARE_2    = 58, //50
  MENU_ICON_SHARE_3    = 65, //57
  MENU_ICON_SHARE_FULL = 69  //61
};


@interface MenuIcon (Private)

  - (void)setIconSize:(int)status;
  - (void)animateWithUpDirection:(BOOL)direction;
  - (void)animate;

@end


@implementation MenuIcon

-(id)initWithManager:(MenuManager*)mngr
{
  self = [super init];
  if (self) {
    manager = [mngr retain];
    fbActiveIcon  = [[NSImage bundlePNG:@"fb_active"] retain];
    fbEmptyIcon   = [[NSImage bundlePNG:@"fb_empty"] retain];
    fbFullIcon    = [[NSImage bundlePNG:@"fb_full"] retain];
    fbOfflineIcon = [[NSImage bundlePNG:@"fb_offline"] retain];
    fbShareIcon1  = [[NSImage bundlePNG:@"fb_share_1"] retain];
    fbShareIcon2  = [[NSImage bundlePNG:@"fb_share_2"] retain];
    fbShareIcon3  = [[NSImage bundlePNG:@"fb_share_3"] retain];
    fbShareIcon4  = [[NSImage bundlePNG:@"fb_share_4"] retain];

    NSArray *draggedTypeArray = [NSArray arrayWithObjects:NSFilenamesPboardType,
                                                          NSTIFFPboardType,
                                                          NSURLPboardType,
                                                          NSStringPboardType, nil];
    [self registerForDraggedTypes:draggedTypeArray];
    [self setIconSize:MENU_ICON_NORMAL];
  }
  return self;
}

- (void)dealloc
{
  [manager      release];
  [fbActiveIcon release];
  [fbEmptyIcon  release];
  [fbFullIcon   release];
  [fbShareIcon1 release];
  [fbShareIcon2 release];
  [fbShareIcon3 release];
  [fbShareIcon4 release];
  [super dealloc];
}

-(void)setIconSize:(int)status
{
  iconStatus = status;
  [self display];
}

-(void)animateWithUpDirection:(BOOL)direction
{
  animateUp = direction;
  [self animate];
}

-(void)animate
{
  int newStatus;
  switch (iconStatus) {
    case MENU_ICON_NORMAL:
      newStatus = animateUp ? MENU_ICON_SHARE_1 : MENU_ICON_NORMAL;
      break;
    case MENU_ICON_SHARE_1:
      newStatus = animateUp ? MENU_ICON_SHARE_2 : MENU_ICON_NORMAL;
      break;
    case MENU_ICON_SHARE_2:
      newStatus = animateUp ? MENU_ICON_SHARE_3 : MENU_ICON_SHARE_1;
      break;
    case MENU_ICON_SHARE_3:
      newStatus = animateUp ? MENU_ICON_SHARE_FULL : MENU_ICON_SHARE_2;
      break;
    case MENU_ICON_SHARE_FULL:
      newStatus = animateUp ? MENU_ICON_SHARE_FULL : MENU_ICON_SHARE_3;
      break;
  }
  if (newStatus != iconStatus) {
    [self setIconSize:newStatus];
    [self performSelector:@selector(animate) withObject:nil afterDelay:0.03];
  }
}

- (void)viewWillDraw
{
  int eventualLength = (iconStatus == MENU_ICON_NORMAL ? MENU_ICON_NORMAL : MENU_ICON_SHARE_FULL);
  [self setFrame:NSMakeRect(0, 0, eventualLength, 22)];
  [[manager statusItem] setLength:eventualLength];
}

- (void)drawRect:(NSRect)rect
{
  // which to draw?
  NSImage* pic;

  if (menuOpen) {
    pic = fbActiveIcon;
  } else if (iconStatus != MENU_ICON_NORMAL) {
    switch (iconStatus) {
      case MENU_ICON_SHARE_1:
        pic = fbShareIcon1;
        break;
      case MENU_ICON_SHARE_2:
        pic = fbShareIcon2;
        break;
      case MENU_ICON_SHARE_3:
        pic = fbShareIcon3;
        break;
      case MENU_ICON_SHARE_FULL:
        pic = fbShareIcon4;
        break;
    }
  } else if (manager.status == FBJewelStatusOffline ||
             manager.status == FBJewelStatusNotLoggedIn ||
             manager.status == FBJewelStatusConnecting) {
    pic = fbOfflineIcon;
  } else if (manager.status == FBJewelStatusUnseen) {
    pic = fbFullIcon;
  } else { // FBJewelStatusUnread FBJewelStatusEmpty
    pic = fbEmptyIcon;
  }

  // draw statusbar background
  [[manager statusItem] drawStatusBarBackgroundInRect:rect
                                        withHighlight:menuOpen];

  // draw pic
  [self lockFocus];
  NSSize iconSize = [pic size];
  NSRect iconRect = NSMakeRect(0, 0, iconSize.width, iconSize.height);
  NSRect iconPlacement = NSMakeRect((rect.size.width - iconSize.width) - 4,
                                    1, iconSize.width, iconSize.height);
  [pic drawInRect:iconPlacement
         fromRect:iconRect
        operation:NSCompositeSourceOver
         fraction:1.0];
  [self unlockFocus];
}

- (void)otherMouseDown:(NSEvent *)event
{
  [self mouseDown:event];
}

- (void)rightMouseDown:(NSEvent *)event
{
  [self mouseDown:event];
}

- (void)mouseDown:(NSEvent *)event
{
  // draw the open menu icon
  menuOpen = YES;
  [self setNeedsDisplay:YES];

  // mark errrverything seen
  [[NSApp delegate] markEverythingSeen];

  // open the manager's menu
  [manager openMenu];

  // cue up a draw with closed menu icon
  menuOpen = NO;
  [self setNeedsDisplay:YES];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
  if ([[sender draggingPasteboard] hasImage] ||
      [[sender draggingPasteboard] hasLink] ||
      [[sender draggingPasteboard] hasString]) {
    [self animateWithUpDirection:YES];
    return NSDragOperationLink;
  }

  return NSDragOperationNone;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
  [self animateWithUpDirection:NO];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
  [self animateWithUpDirection:NO];
  return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
  NSImage* img = [[sender draggingPasteboard] getImage];
  if (img) {
    [[StatusUpdateManager manager] attachPhoto:img];
    return YES;
  }

  NSURL* link = [[sender draggingPasteboard] getLink];
  if (link) {
    BOOL success = [[StatusUpdateManager manager] attachLink:link];

    if (!success || [[sender draggingPasteboard] hasMoreThanLink]) {
      [[StatusUpdateManager manager] appendString:[[sender draggingPasteboard] getString]];
    }
    return YES;
  }

  NSString* string = [[sender draggingPasteboard] getString];
  if (string) {
    [[StatusUpdateManager manager] appendString:string];
  }
  return YES;
}

@end
