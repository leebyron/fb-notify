//
//  BubbleView.h
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BubbleView : NSView {
  NSString *text;
  NSImage *image;
}

+ (float)heightOfText:(NSString *)text maxWidth:(float)width;
+ (float)widthOfText:(NSString *)text maxWidth:(float)width;
+ (NSSize)totalSizeWithText:(NSString *)text withImage:(BOOL)hasImage maxWidth:(float)width;

- (id)initWithFrame:(NSRect)frame
              image:(NSImage *)image
               text:(NSString *)aString;

@end
