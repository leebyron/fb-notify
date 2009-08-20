//
//  BubbleView.h
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BubbleView : NSView {
  NSString* text;
  NSString* subText;
  NSImage*  image;
}

+ (float)heightOfText:(NSString*)text subText:(NSString*)subText maxWidth:(float)width;
+ (float)widthOfText:(NSString*)text subText:(NSString*)subText maxWidth:(float)width;
+ (NSSize)totalSizeWithText:(NSString*)text subText:(NSString*)subText withImage:(BOOL)hasImage maxWidth:(float)width;

- (id)initWithFrame:(NSRect)frame
              image:(NSImage*)image
               text:(NSString*)aString
            subText:(NSString*)bString;

@end
