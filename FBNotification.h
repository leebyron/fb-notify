//
//  FBNotification.h
//  Facebook
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FBNotification : NSObject {
  NSMutableDictionary *fields;
}

+ (FBNotification *)notificationWithXMLNode:(NSXMLNode *)node;
- (id)initWithXMLNode:(NSXMLNode *)node;

@end
