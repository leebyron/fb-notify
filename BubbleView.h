//
//  BubbleView.h
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BubbleView : NSView {
  NSString *text;
}

+ (float)heightOfText:(NSString *)text inWidth:(float)width;
+ (float)totalHeightWithText:(NSString *)text inWidth:(float)width;

- (id)initWithFrame:(NSRect)frame text:(NSString *)aString;

@end
