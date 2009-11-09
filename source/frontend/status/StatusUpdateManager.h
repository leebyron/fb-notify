//
//  StatusUpdateManager.h
//  FBDesktopNotifications
//
//  Created by Lee Byron on 11/9/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <FBCocoa/FBCocoa.h>


@interface StatusUpdateManager : NSObject {
  NSString* lastStatusUpdate;
  id<FBRequest> lastUpdateRequest;
}

@property(retain) NSString* lastStatusUpdate;
@property(assign) id<FBRequest> lastUpdateRequest;

+ (StatusUpdateManager*)manager;

- (BOOL)attachPhoto:(NSImage*)image;
- (void)removeAttachment;

- (void)sendPost:(NSDictionary*)post;

@end
