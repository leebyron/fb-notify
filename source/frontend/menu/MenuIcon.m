//
//  MenuIcon.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 9/17/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "MenuIcon.h"
#import "ApplicationController.h"

enum {
  MENU_ICON_NORMAL     = 29, //21
  MENU_ICON_SHARE_1    = 47, //39
  MENU_ICON_SHARE_2    = 58, //50
  MENU_ICON_SHARE_3    = 65, //57
  MENU_ICON_SHARE_FULL = 69  //61
};

@interface MenuIcon (Private)
  -(void)animateWithUpDirection:(BOOL)direction;
  -(void)animate;
@end

@implementation MenuIcon
-(id)initWithManager:(MenuManager*)mngr
{
  self = [super init];
  if (self) {
    manager = [mngr retain];
    fbActiveIcon = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"fb_active" ofType:@"png"]];
    fbEmptyIcon = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"fb_empty" ofType:@"png"]];
    fbFullIcon = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"fb_full" ofType:@"png"]];
    
    fbShareIcon1 = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"fb_share_1" ofType:@"png"]];
    fbShareIcon2 = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"fb_share_2" ofType:@"png"]];
    fbShareIcon3 = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"fb_share_3" ofType:@"png"]];
    fbShareIcon4 = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"fb_share_4" ofType:@"png"]];

    NSArray *draggedTypeArray = [NSArray arrayWithObjects:NSStringPboardType,
                                                          NSFilenamesPboardType,
                                                          NSTIFFPboardType,
                                                          NSURLPboardType, nil];
//    [self registerForDraggedTypes:draggedTypeArray]; // TODO: enable when share is good
    [self setIconStatus:MENU_ICON_NORMAL];
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

-(void)setIconStatus:(int)status
{
  iconStatus = status;
  [self display];
//  [self setNeedsDisplay:YES];
}

-(void)setIconIlluminated:(BOOL)illuminated
{
  iconIlluminated = illuminated;
  [self setNeedsDisplay:YES];
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
    [self setIconStatus:newStatus];
    [self performSelector:@selector(animate) withObject:nil afterDelay:0.03];
  }
}

- (void)viewWillDraw
{
  //int eventualLength = (iconStatus == MENU_ICON_NORMAL ? MENU_ICON_NORMAL : MENU_ICON_SHARE_FULL);
  [self setFrame:NSMakeRect(0, 0, iconStatus, 22)];
  [[manager statusItem] setLength:iconStatus];
}

- (void)drawRect:(NSRect)rect
{
  // which to draw?
  NSImage* pic = fbEmptyIcon;
  if (iconIlluminated) {
    pic = fbFullIcon;
  }
  if (menuOpen) {
    pic = fbActiveIcon;
  }
  if (iconStatus != MENU_ICON_NORMAL) {
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
  }

  // draw statusbar background
  [[manager statusItem] drawStatusBarBackgroundInRect:rect withHighlight:menuOpen];

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

- (void)mouseDown:(NSEvent *)event
{
  // draw the open menu icon
  menuOpen = YES;
  [self setNeedsDisplay:YES];

  // mark as interacted
  [[NSApp delegate] interacted];

  // open the manager's menu
  [manager openMenu];

  // cue up a draw with closed menu icon
  menuOpen = NO;
  [self setNeedsDisplay:YES];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
  NSLog(@"draggingEntered:");
  [self animateWithUpDirection:YES];
  return NSDragOperationLink;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
  NSLog(@"draggingExited");
  [self animateWithUpDirection:NO];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
  NSLog(@"prepareForDragOperation");
  [self animateWithUpDirection:NO];
  return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
  NSLog(@"performDragOperation");
  return YES;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
  NSLog(@"concludeDragOperation");
}

@end
