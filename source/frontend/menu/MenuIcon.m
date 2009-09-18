//
//  MenuIcon.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 9/17/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "MenuIcon.h"
#import "ApplicationController.h"


@implementation MenuIcon
-(id)initWithManager:(MenuManager*)mngr
{
  self = [super init];
  if (self) {
    manager = [mngr retain];
    fbActiveIcon = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"fb_active" ofType:@"png"]];
    fbEmptyIcon = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"fb_empty" ofType:@"png"]];
    fbFullIcon = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"fb_full" ofType:@"png"]];

    NSArray *draggedTypeArray = [NSArray arrayWithObjects:NSStringPboardType,
                                                          NSFilenamesPboardType,
                                                          NSTIFFPboardType,
                                                          NSURLPboardType, nil];
    //[self registerForDraggedTypes:draggedTypeArray];
  }
  return self;
}

- (void)dealloc
{
  [manager release];
  [fbActiveIcon release];
  [fbEmptyIcon release];
  [fbFullIcon release];
  [super dealloc];
}

-(void)setIconIlluminated:(BOOL)illuminated
{
  iconIlluminated = illuminated;
  [self setNeedsDisplay:YES];
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

  // draw statusbar background
  [[manager statusItem] drawStatusBarBackgroundInRect:NSMakeRect(0,0,29,22) withHighlight:menuOpen];

  // draw pic
  [self lockFocus];
  NSSize iconSize = [pic size];
  NSRect iconRect = NSMakeRect(0, 0, iconSize.width, iconSize.height);
  NSRect iconPlacement = NSMakeRect(round(0.5 * (rect.size.width - iconSize.width)),
                                    round(0.5 * (rect.size.height - iconSize.height)),
                                    iconSize.width, iconSize.height);
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
  return NSDragOperationLink;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
  NSLog(@"draggingExited");
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
  NSLog(@"prepareForDragOperation");
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
