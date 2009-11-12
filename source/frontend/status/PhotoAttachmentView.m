//
//  ImageAttachmentView.m
//  FBDesktopNotifications
//
//  Created by Lee Byron on 11/7/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "PhotoAttachmentView.h"

#define kEmptyImageHeight 80
#define kMaxImageHeight 300
#define kMinImageHeight 50


@interface ImageAttachmentImageView : FBImageView {
  id delegate;
}

@property(assign) id delegate;

@end


@interface PhotoAttachmentView (Private)

- (void)setImageFromView:(NSImage*)aImage;

@end


@implementation PhotoAttachmentView

@synthesize image;

- (id)initWithFrame:(NSRect)frame
{
  frame.size.height = kEmptyImageHeight;
  self = [super initWithFrame:frame];
  if (self) {
    self.boxType = NSBoxCustom;
    self.borderWidth = 0;
    self.contentViewMargins = NSZeroSize;

    imageView = [[ImageAttachmentImageView alloc] initWithFrame:
                 NSMakeRect(0, 0, frame.size.width - self.contentViewMargins.width * 2, frame.size.height)];
    imageView.autoresizingMask = NSViewWidthSizable;
    ((ImageAttachmentImageView*)imageView).delegate = self;
    [[self contentView] addSubview:imageView];
  }
  return self;
}

- (void)dealloc
{
  [image release];
  [imageView release];
  [super dealloc];
}

- (void)setImage:(NSImage *)aImage
{
  imageView.image = aImage;
}

- (void)setImageFromView:(NSImage*)aImage
{
  [aImage retain];
  [image release];
  image = aImage;

  NSSize viewSize = NSMakeSize(self.frame.size.width - self.contentViewMargins.width * 2, kEmptyImageHeight);
  if (image != nil) {
    viewSize.height = image.size.height;
    if (image.size.width > viewSize.width) {
      viewSize.height = (image.size.height / image.size.width) * viewSize.width;
    }
    viewSize.height = CLAMP(viewSize.height, kMinImageHeight, kMaxImageHeight);
  }

  [imageView setFrameSize:viewSize];
  [self sizeToFit];
  [self setNeedsDisplay:YES];
}

@end


@implementation ImageAttachmentImageView

@synthesize delegate;

- (void)setImage:(NSImage*)aImage
{
  [super setImage:aImage];
  [(PhotoAttachmentView*)self.delegate setImageFromView:aImage];
}

@end
