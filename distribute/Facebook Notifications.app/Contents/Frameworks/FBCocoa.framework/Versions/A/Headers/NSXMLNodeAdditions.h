//
//  NSXMLNodeAdditions.h
//  FBCocoa
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSXMLNode (NSXMLNodeAdditions)

- (NSXMLNode *)childWithName:(NSString *)childName;

@end
