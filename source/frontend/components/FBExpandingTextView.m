//
//  SUScrollView.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 11/5/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "FBExpandingTextView.h"
#import "StatusUpdateManager.h"
#import "NSEvent+.h"
#import "NSPasteboard+.h"


//=====================================================================
// Subview private interfaces

@interface SUScrollEdgeView : NSView
@end
@interface SUTextView : NSTextView
@end


//=====================================================================
// Main view implementation

@implementation FBExpandingTextView

@synthesize delegate, maxSize;

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {

    [self setBorderType:NSBezelBorder];
    [self setHasVerticalScroller:YES];
    [self setHasHorizontalScroller:NO];
    [self setAutohidesScrollers:YES];
    self.maxSize = NSMakeSize(10000000, 250);

    // set view
    NSRect textViewRect = frame;
    textViewRect.size.width -= 17; // compensate for scrollview padding
    SUTextView* textView = [[SUTextView alloc] initWithFrame:textViewRect];
    [textView setDelegate:self];
    [self setDocumentView:textView];
    [textView release];

    // add edge
    edge = [[SUScrollEdgeView alloc] initWithFrame:[self frame]];
    [self addSubview:edge];
  }
  return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [edge release];
  [super dealloc];
}

- (void)setDocumentView:(NSView*)aView
{
  // remove old notification
  [[NSNotificationCenter defaultCenter] removeObserver:self];

  [super setDocumentView:aView];

  // listen for resize events
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(documentViewFrameDidChange:)
                                               name:NSViewFrameDidChangeNotification
                                             object:aView];
}

// on resize, also resize the scroll view
- (void)documentViewFrameDidChange:(NSNotification*)notif
{
  if (isResizing) {
    return;
  }

  NSRect documentBounds = [[self documentView] frame];
  documentBounds.size.height = MAX(46, MIN(documentBounds.size.height + 3, self.maxSize.height));
  documentBounds.size.width = [self frame].size.width;

  isResizing = YES;
  [self setFrameSize:documentBounds.size];
  isResizing = NO;
}

@end


//=====================================================================
// EDGE INSERT

@implementation SUScrollEdgeView

- (void)drawRect:(NSRect)rect
{
  NSRect bounds = [self bounds];
  [[NSColor colorWithCalibratedWhite:0.0 alpha:0.1] set];
  [[NSBezierPath bezierPathWithRect:
    NSMakeRect(1, bounds.size.height - 2, bounds.size.width - 2, 1)] fill];
}

@end


//=====================================================================
// TextView with key command hooks

@implementation SUTextView

- (id)initWithFrame:(NSRect)frame
{
  if (self = [super initWithFrame:frame]) {
    [self setFieldEditor:YES];
    [self setAllowsUndo:YES];
    [self setRichText:NO];
    [self setTextContainerInset:NSMakeSize(0.0, 3.0)];
    [self setFont:[NSFont labelFontOfSize:14.0]];
    [self setContinuousSpellCheckingEnabled:YES];
    [self setAutoresizingMask:NSViewWidthSizable];
  }
  return self;
}

- (void)interpretKeyEvents:(id)events
{
  for (NSEvent* e in events) {

    // capture key events to do standard text manipulation
    if ([e isKey:@"a" modifiers:NSCommandKeyMask]) {
      [self selectAll:self];
    } else if ([e isKey:@"c" modifiers:NSCommandKeyMask]) {
      [self copy:self];
    } else if ([e isKey:@"v" modifiers:NSCommandKeyMask]) {
      [self paste:self];
    } else if ([e isKey:@"x" modifiers:NSCommandKeyMask]) {
      [self cut:self];
    } else if ([e isKey:@"z" modifiers:NSCommandKeyMask]) {
      [[self undoManager] undo];
    } else if ([e isKey:@"z" modifiers:NSCommandKeyMask|NSShiftKeyMask]) {
      [[self undoManager] redo];

    // capture line breaks and shortcut for share button
    } else if ([e isKeyCode:36 modifiers:0]) {
      [self insertText:@"\n"];

    // delegate methods
    } else if ([e isKeyCode:36 modifiers:NSShiftKeyMask] ||
               [e isKeyCode:36 modifiers:NSCommandKeyMask]) {
      DELEGATE([[self delegate] delegate], @selector(submit:));
    } else if ([e isKey:@"w" modifiers:NSCommandKeyMask]) {
      DELEGATE([[self delegate] delegate], @selector(cancel:));

    // everything else pass on as per usual
    } else {
      [super interpretKeyEvents:[NSArray arrayWithObject:e]];
    }
  }
}

- (void)paste:(id)sender
{
  // pasting an image?
  if ([[NSPasteboard generalPasteboard] hasImage]) {
    NSImage* img = [[NSPasteboard generalPasteboard] getImage];
    [[StatusUpdateManager manager] attachPhoto:img];

  // pasting a link
  } else if ([[NSPasteboard generalPasteboard] hasLink]) {
    NSURL* link = [[NSPasteboard generalPasteboard] getLink];
    BOOL success = [[StatusUpdateManager manager] attachLink:link];

    // if the link wasn't attached, or contains more than just a link, paste it
    if (!success || [[NSPasteboard generalPasteboard] hasMoreThanLink]) {
      [self pasteAsPlainText:sender];
    }

  // otherwise do text
  } else {
    [self pasteAsPlainText:sender];
  }
}


- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
  return NSDragOperationCopy;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
  // attempt to paste an image
  if ([[sender draggingPasteboard] hasImage]) {
    [[StatusUpdateManager manager] attachPhoto:[[sender draggingPasteboard] getImage]];
    return YES;
  }

  if ([[sender draggingPasteboard] hasLink]) {
    BOOL success = [[StatusUpdateManager manager] attachLink:[[sender draggingPasteboard] getLink]];

    if (!success || [[sender draggingPasteboard] hasMoreThanLink]) {
      [super performDragOperation:sender];
    }
    return YES;
  }

  // paste normally
  [super performDragOperation:sender];
  return YES;
}

@end
