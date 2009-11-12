//
//  LinkAttachmentView.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 11/10/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "LinkAttachmentView.h"
#import "AttachmentBox.h"
#import "GlobalSession.h"
#import "AsyncImage.h"
#import "NSDictionary+.h"
#import "NSImage+.h"

#define kEmptyLinkHeight 80
#define kMaxLinkImageHeight 130
#define kMaxLinkImageWidth 130
#define kLoaderSize 30
#define kLoadingImageSize 50
#define kHorizontalMargin 10
#define kVerticalMargin 3
#define kTextDrawingOptions NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading


@interface LinkAttachmentView (Private)

- (void)calculateBounds;

@end


@implementation LinkAttachmentView

@synthesize link, attachment;

- (id)initWithFrame:(NSRect)frame
{
  frame.size.height = kEmptyLinkHeight;
  self = [super initWithFrame:frame];
  if (self) {
    link = nil;
    attachment = nil;
    currentImageIndex = -1;
    images = [[NSMutableArray alloc] init];
    loader = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, kLoaderSize, kLoaderSize)];
    loader.style = NSProgressIndicatorSpinningStyle;
    [loader setDisplayedWhenStopped:NO];
    [self addSubview:loader];
  }
  return self;
}

- (void)dealloc
{
  [link release];
  [attachment release];
  [images release];
  [super dealloc];
}

- (NSString*)image
{
  if (currentImageIndex == -1) {
    return nil;
  }

  NSArray* media = [self.attachment objectForKey:@"media"];
  NSDictionary* imageItem = [media objectAtIndex:currentImageIndex];
  return [imageItem objectForKey:@"src"];
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

  // remember that we're loading
  isLoading = YES;

  // set size and position loader
  NSRect emptyBounds = self.bounds;
  emptyBounds.size.height = kEmptyLinkHeight;
  [self setBounds:emptyBounds];
  NSRect loaderFrame = NSMakeRect(round((emptyBounds.size.width - kLoaderSize) * 0.5),
                                  round((emptyBounds.size.height - kLoaderSize) * 0.5),
                                  kLoaderSize, kLoaderSize);
  [loader setFrame:loaderFrame];
  [loader startAnimation:self];

  [self setNeedsDisplay:YES];
}

- (void)gotLinkPreview:(id<FBRequest>)req
{
  // finished loading
  isLoading = NO;

  // stop loader, redisplay
  [loader stopAnimation:self];
  [self setNeedsDisplay:YES];

  if ([req error]) {
    // detach link
    link = nil;
    NSLog(@"error getting preview %@", [req error], [[[req error] userInfo] objectForKey:kFBErrorMessageKey]);
    return;
  }

  // set attachment
  self.attachment = [req response];
  NSLog(@"got preview %@", self.attachment);

  // purge array
  [images removeAllObjects];

  // load any images?
  for (NSDictionary* imageDict in [self.attachment objectForKey:@"media"]) {
    NSURL* url = [NSURL URLWithString:[imageDict objectForKey:@"src"]];
    AsyncImage* image = [AsyncImage imageByLoadingURL:url];
    image.delegate = self;
    [images addObject:image];
  }

  // focus on the first image by default
  currentImageIndex = [images count] > 0 ? 0 : -1;

  // calc bounds based on size of text and image and things
  [self calculateBounds];
}


// asyncimagedelegate methods
- (void)imageHasData:(AsyncImage*)image
{
  if (image == [images objectAtIndex:currentImageIndex]) {
    [image.image resizeToFit:NSMakeSize(kMaxLinkImageWidth, kMaxLinkImageHeight)
                   usingMode:NSScaleProportionally];
    [self calculateBounds];
    [self setNeedsDisplay:YES];
  }
}

- (void)imageFailed:(AsyncImage*)image
{
  if (image == [images objectAtIndex:currentImageIndex]) {
    // try to move to the next one, without creating an infinite loop of awfulness
    if (currentImageIndex < [images count] - 1) {
      currentImageIndex++;
    } else if (currentImageIndex = [images count] - 1 &&
               [[images objectAtIndex:0] isLoaded]) {
      currentImageIndex = 0;
    }
    [self calculateBounds];
    [self setNeedsDisplay:YES];
  }
}


// layout

- (void)calculateBounds
{
  imageSize = NSMakeSize(0,0);
  if (currentImageIndex != -1) {
    AsyncImage* currentImage = [images objectAtIndex:currentImageIndex];
    if ([currentImage isLoading]) {
      imageSize.width = kLoadingImageSize;
      imageSize.height = kLoadingImageSize;
    } else if ([currentImage isLoaded]) {
      imageSize = currentImage.image.size;
    }
  }

  NSSize contentMaxSize = NSMakeSize(self.bounds.size.width, 400);
  if (imageSize.width > 0) {
    contentMaxSize.width -= imageSize.width + kHorizontalMargin;
  }

  // get text size within these bounds
  nameSize = NSMakeSize(0,0);
  NSString* name = [self.attachment stringForKey:@"name"];
  if (name) {
    nameSize = [name boundingRectWithSize:contentMaxSize
                                  options:kTextDrawingOptions
                               attributes:self.nameStyle].size;
  }

  captionSize = NSMakeSize(0,0);
  NSString* caption = [self.attachment stringForKey:@"caption"];
  if (caption) {
    caption = [NSString stringWithFormat:@"%@: %@",
               NSLocalizedString(@"Source", @"Source domain for an attached link"),
               caption];
    captionSize = [caption boundingRectWithSize:contentMaxSize
                                        options:kTextDrawingOptions
                                     attributes:self.captionStyle].size;
  }

  descriptionSize = NSMakeSize(0,0);
  NSString* description = [self.attachment stringForKey:@"description"];
  if (description) {
    descriptionSize = [description boundingRectWithSize:contentMaxSize
                                                options:kTextDrawingOptions
                                             attributes:self.descriptionStyle].size;
  }

  // get total content size
  NSSize contentSize = contentMaxSize;
  contentSize.height = nameSize.height;
  if (captionSize.height > 0 && contentSize.height > 0) {
    contentSize.height += kVerticalMargin;
  }
  contentSize.height += captionSize.height;
  if (descriptionSize.height > 0 && contentSize.height > 0) {
    contentSize.height += kVerticalMargin;
  }
  contentSize.height += descriptionSize.height;

  // get total size
  NSRect finalFrame = NSMakeRect(self.frame.origin.x,
                                 self.frame.origin.y,
                                 self.frame.size.width,
                                 ceil(MAX(imageSize.height, contentSize.height)));
  [self setFrame:finalFrame];
}

- (void)drawRect:(NSRect)dirtyRect
{
  if (isLoading) {
    return;
  }

  CGFloat fullHeight = self.bounds.size.height;

  if (!attachment) {
    NSRect errorBounds = [self bounds];
    errorBounds.size.height = (fullHeight - 12) * 0.5 + 12;
    NSMutableParagraphStyle* style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];

    NSString* errorString = @"Error attaching link";

    // draw the light edge first
    NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:
                          style, NSParagraphStyleAttributeName,
                          [NSColor colorWithCalibratedWhite:1.0 alpha:0.5], NSForegroundColorAttributeName, nil];
    [errorString drawInRect:errorBounds withAttributes:attr];

    // then draw the dark text
    attr = [NSDictionary dictionaryWithObjectsAndKeys:
            style, NSParagraphStyleAttributeName,
            [NSColor colorWithCalibratedWhite:0.4 alpha:1.0], NSForegroundColorAttributeName, nil];
    [errorString drawInRect:errorBounds withAttributes:attr];

    return;
  }

  // draw image
  if (currentImageIndex == -1) {
    [loader stopAnimation:self];
  } else {
    AsyncImage* currentImage = [images objectAtIndex:currentImageIndex];
    if ([currentImage isLoading]) {
      NSRect loaderFrame = NSMakeRect(round((imageSize.width + (kHorizontalMargin - kAttachmentEdgeMargin) - kLoaderSize) * 0.5),
                                      round((imageSize.height - kLoaderSize) * 0.5),
                                      kLoaderSize, kLoaderSize);
      loaderFrame.origin.y = fullHeight - loaderFrame.origin.y - loaderFrame.size.height;
      [loader setFrame:loaderFrame];

      [loader startAnimation:self];
    } else {
      [loader stopAnimation:self];

      if ([currentImage isLoaded]) {
        // draw the image!
        NSRect imageRect = NSMakeRect(0, ceil(fullHeight - imageSize.height), imageSize.width, imageSize.height);
        [currentImage.image drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceAtop fraction:1.0];
      }
    }
  }

  // draw text
  NSPoint textOffset = NSZeroPoint;
  if (imageSize.width > 0) {
    textOffset.x += imageSize.width + kHorizontalMargin;
  }

  NSString* name = [self.attachment stringForKey:@"name"];
  if (name) {
    NSRect nameBounds = NSMakeRect(textOffset.x, textOffset.y, nameSize.width, nameSize.height);
    nameBounds.origin.y = fullHeight - nameBounds.origin.y - nameBounds.size.height;
    [name drawWithRect:nameBounds
               options:kTextDrawingOptions
            attributes:self.nameStyle];
    textOffset.y += nameSize.height + kVerticalMargin;
  }

  NSString* caption = [self.attachment stringForKey:@"caption"];
  if (caption) {
    caption = [NSString stringWithFormat:@"%@: %@",
               NSLocalizedString(@"Source", @"Source domain for an attached link"),
               caption];
    NSRect captionBounds = NSMakeRect(textOffset.x, textOffset.y, captionSize.width, captionSize.height);
    captionBounds.origin.y = fullHeight - captionBounds.origin.y - captionBounds.size.height;
    [caption drawWithRect:captionBounds
                  options:kTextDrawingOptions
               attributes:self.captionStyle];
    textOffset.y += captionSize.height + kVerticalMargin;
  }

  NSString* description = [self.attachment stringForKey:@"description"];
  if (description) {
    NSRect descriptionBounds = NSMakeRect(textOffset.x, textOffset.y, descriptionSize.width, descriptionSize.height);
    descriptionBounds.origin.y = fullHeight - descriptionBounds.origin.y - descriptionBounds.size.height;
    [description drawWithRect:descriptionBounds
                      options:kTextDrawingOptions
                   attributes:self.descriptionStyle];
    textOffset.y += descriptionSize.height + kVerticalMargin;
  }
}


// styles

- (NSDictionary*)nameStyle
{
  if (nameStyle) {
    return nameStyle;
  }

  NSMutableParagraphStyle *paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
  [paraStyle setTighteningFactorForTruncation:0.0];
  [paraStyle setLineBreakMode:NSLineBreakByTruncatingTail];

  nameStyle = [[NSDictionary dictionaryWithObjectsAndKeys:
                [NSFont systemFontOfSize:12.0], NSFontAttributeName,
                [NSColor colorWithCalibratedWhite:0.1 alpha:1.0], NSForegroundColorAttributeName,
                paraStyle, NSParagraphStyleAttributeName,
                nil] retain];
  return nameStyle;
}

- (NSDictionary*)captionStyle
{
  if (captionStyle) {
    return captionStyle;
  }

  NSMutableParagraphStyle *paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
  [paraStyle setTighteningFactorForTruncation:0.0];
  [paraStyle setLineBreakMode:NSLineBreakByTruncatingTail];

  captionStyle = [[NSDictionary dictionaryWithObjectsAndKeys:
                   [NSFont systemFontOfSize:10.0], NSFontAttributeName,
                   [NSColor colorWithCalibratedWhite:0.5 alpha:1.0], NSForegroundColorAttributeName,
                   paraStyle, NSParagraphStyleAttributeName,
                   nil] retain];
  return captionStyle;
}

- (NSDictionary*)descriptionStyle
{
  if (descriptionStyle) {
    return descriptionStyle;
  }

  NSMutableParagraphStyle *paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
  [paraStyle setTighteningFactorForTruncation:0.0];
  [paraStyle setLineBreakMode:NSLineBreakByWordWrapping];

  descriptionStyle = [[NSDictionary dictionaryWithObjectsAndKeys:
                       [NSFont systemFontOfSize:12.0], NSFontAttributeName,
                       [NSColor colorWithCalibratedWhite:0.3 alpha:1.0], NSForegroundColorAttributeName,
                       paraStyle, NSParagraphStyleAttributeName,
                       nil] retain];
  return descriptionStyle;
}

@end
