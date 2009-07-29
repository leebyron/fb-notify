//
//  BubbleManager.h
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BubbleManager : NSObject {
  NSMutableArray *windows;
}

- (void)addBubbleWithText:(NSString *)text duration:(NSTimeInterval)secs;

@end
