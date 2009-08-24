//
//  MessageManager.h
//  Facebook
//
//  Created by Lee Byron on 8/13/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>


NSComparisonResult sortMessages(id firstItem, id secondItem, void *context);

@interface MessageManager : NSObject {
  NSMutableDictionary* allDict;
  NSMutableArray*      allMessages;
  NSMutableArray*      unreadMessages;
  int                  mostRecentUpdateTime;
}

@property(retain) NSMutableArray* allMessages;
@property(retain) NSMutableArray* unreadMessages;

-(NSArray*)addMessagesFromXML:(NSXMLNode*)xml;
-(void)verifyMessagesFromXML:(NSXMLNode*)xml;
-(int)unreadCount;
-(int)mostRecentUpdateTime;

@end
