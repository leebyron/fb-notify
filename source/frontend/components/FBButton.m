//
//  FBButton.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 11/9/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "FBButton.h"
#import "NSBezierPath+.h"
#import "NSShadow+.h"


@interface FBButtonCell : NSButtonCell

@end


@implementation FBButton

@synthesize padding, minWidth, isChromeless, isHovering;

+ (Class)cellClass
{
	return [FBButtonCell class];
}

- (id)initWithFrame:(NSRect)frameRect
{
  if (self = [super initWithFrame:frameRect]) {
    self.bezelStyle = NSRoundRectBezelStyle;
    self.padding = 8;
    self.minWidth = 60;
    trackingRect = [self addTrackingRect:[self bounds] owner:self userData:nil assumeInside:NO];
    [self setFont:[NSFont labelFontOfSize:12]];
  }
  return self;
}

- (void)setFrame:(NSRect)frameRect
{
  [super setFrame:frameRect];
  [self removeTrackingRect:trackingRect];
  trackingRect = [self addTrackingRect:[self bounds] owner:self userData:nil assumeInside:NO];
}

- (void)setIsChromeless:(BOOL)to
{
  isChromeless = to;
  [self setTextColor:[NSColor colorWithCalibratedWhite:0.0 alpha:(isChromeless ? 0.8 : 1.0)]];
}

- (void)setTextColor:(NSColor*)aColor
{
  NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc]
                                          initWithAttributedString:[self attributedTitle]];
  int len = [attrTitle length];
  NSRange range = NSMakeRange(0, len);
  [attrTitle addAttribute:NSForegroundColorAttributeName
                    value:aColor
                    range:range];
  [attrTitle fixAttributesInRange:range];
  [self setAttributedTitle:attrTitle];
  [attrTitle release];
}

- (void)setTitle:(NSString *)aTitle
{
  [super setTitle:aTitle];
  
  [self setTextColor:[NSColor colorWithCalibratedWhite:0.0 alpha:(isChromeless ? 0.6 : 1.0)]];

  NSSize labelSize = [aTitle sizeWithAttributes:[NSDictionary dictionaryWithObject:self.font
                                                                            forKey:NSFontAttributeName]];
  labelSize.height = self.frame.size.height;
  labelSize.width += padding * 2;
  labelSize.width = MAX(minWidth, labelSize.width);
  [self setFrame:NSMakeRect(self.frame.origin.x, self.frame.origin.y, labelSize.width, labelSize.height)];
}

- (void)mouseEntered:(NSEvent*)theEvent
{
  isHovering = YES;
  [self setNeedsDisplay:YES];
  if (isChromeless) {
    [self setTextColor:[NSColor colorWithCalibratedWhite:0.0 alpha:1.0]];
  }
}

- (void)mouseExited:(NSEvent*)theEvent
{
  isHovering = NO;
  [self setNeedsDisplay:YES];
  if (isChromeless) {
    [self setTextColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.6]];
  }
}

- (void)viewWillDraw
{
  NSPoint m = [[self window] mouseLocationOutsideOfEventStream];
  isHovering = [[[self window] contentView] hitTest:m] == self;
}

@end


@implementation FBButtonCell

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView
{
  static NSGradient* pressedGradient    = nil;
  static NSGradient* normalGradient     = nil;
  static NSGradient* hoverGradient      = nil;
  static NSShadow*   pressedInnerShadow = nil;

  if (pressedGradient == nil) {
    pressedGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.65 alpha:1.0]
                                                    endingColor:[NSColor colorWithCalibratedWhite:0.60 alpha:1.0]];

    normalGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.85 alpha:1.0]
                                                   endingColor:[NSColor colorWithCalibratedWhite:0.98 alpha:1.0]];

    hoverGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.75 alpha:1.0]
                                                  endingColor:[NSColor colorWithCalibratedWhite:0.75 alpha:1.0]];

    pressedInnerShadow = [[NSShadow alloc] initWithColor:[NSColor colorWithCalibratedWhite:0.0 alpha:.25]
                                                  offset:NSMakeSize(0.0, -2.0)
                                              blurRadius:2.0];
  }

  FBButton* button = (FBButton*)self.controlView;

  // adjust the drawing area by 1 point to account for the drop shadow
  NSRect rect = frame;
  CGFloat radius = frame.size.height * 0.5;
  NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:radius yRadius:radius];

  // draw the gradient fill
  if (self.isHighlighted) {
    [pressedGradient drawInBezierPath:path angle:-90];
    [path fillWithInnerShadow:pressedInnerShadow];
  } else if (!button.isChromeless) {
    [normalGradient drawInBezierPath:path angle:-90];
  } else if (button.isHovering) {
    [hoverGradient drawInBezierPath:path angle:-90];
  }

  // draw the inner stroke
  if (!button.isChromeless) {
    [[NSColor colorWithCalibratedWhite:0.0 alpha:0.35] setStroke];
    [path setLineWidth:1];
    [path strokeInside];
  } else if (self.isHighlighted) {
    [[NSColor colorWithCalibratedWhite:0.0 alpha:0.1] setStroke];
    [path setLineWidth:1];
    [path strokeInside];
  }

}

@end
