//
//  QueryManager.h
//  FBDesktopNotifications
//
//  Created by Lee Byron on 8/19/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>


enum {
  QUERY_OFF,
  QUERY_DELAY_UNTIL_NEXT,
  QUERY_WAITING_FOR_RESPONSE
};

@class ApplicationController;

@interface QueryManager : NSObject {
  int                     status;
  ApplicationController*  parent;
  NSTimer*                queryTimer;
  NSTimeInterval          lastQuery;
}

-(id) initWithParent:(ApplicationController*)app;

-(void) start;
-(void) stop;

@end
