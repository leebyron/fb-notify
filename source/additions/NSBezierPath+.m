//
//  NSBezierPath+.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 11/7/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "NSBezierPath+.h"


@implementation NSBezierPath (Additions)

- (void)fillWithInnerShadow:(NSShadow*)shadow
{
	[NSGraphicsContext saveGraphicsState];

	NSSize offset = shadow.shadowOffset;
	NSSize originalOffset = offset;
	CGFloat radius = shadow.shadowBlurRadius;
	NSRect bounds = NSInsetRect(self.bounds, -(ABS(offset.width) + radius), -(ABS(offset.height) + radius));
	offset.height += bounds.size.height;
	shadow.shadowOffset = offset;
	NSAffineTransform *transform = [NSAffineTransform transform];
	if ([[NSGraphicsContext currentContext] isFlipped])
		[transform translateXBy:0 yBy:bounds.size.height];
	else
		[transform translateXBy:0 yBy:-bounds.size.height];

	NSBezierPath *drawingPath = [NSBezierPath bezierPathWithRect:bounds];
	[drawingPath setWindingRule:NSEvenOddWindingRule];
	[drawingPath appendBezierPath:self];
	[drawingPath transformUsingAffineTransform:transform];

	[self addClip];
	[shadow set];
	[[NSColor blackColor] set];
	[drawingPath fill];

	shadow.shadowOffset = originalOffset;

	[NSGraphicsContext restoreGraphicsState];
}


// Credit for the next two methods goes to Matt Gemmell
- (void)strokeInside
{
  [self strokeInsideWithinRect:NSZeroRect];
}

- (void)strokeInsideWithinRect:(NSRect)clipRect
{
  NSGraphicsContext *thisContext = [NSGraphicsContext currentContext];
  float lineWidth = [self lineWidth];

  [thisContext saveGraphicsState];

  // Double the stroke width, since -stroke centers strokes on paths.
  [self setLineWidth:(lineWidth * 2.0)];

  // Clip
  [self setClip];
  if (clipRect.size.width > 0 && clipRect.size.height > 0) {
    [NSBezierPath clipRect:clipRect];
  }

  // Stroke the path.
  [self stroke];

  // Restore
  [thisContext restoreGraphicsState];
  [self setLineWidth:lineWidth];
}

@end
