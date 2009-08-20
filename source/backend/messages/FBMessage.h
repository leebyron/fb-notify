//
//  FBMessage.h
//  Facebook
//
//  Created by Lee Byron on 8/13/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MessageManager.h"
#import "FBObject.h"


@interface FBMessage : FBObject {
  MessageManager* manager;
}

+ (FBMessage*)messageWithXMLNode:(NSXMLNode*)node manager:(MessageManager*)mngr;
- (id)initWithXMLNode:(NSXMLNode*)node manager:(MessageManager*)mngr;

- (void)markAsRead;

@end
