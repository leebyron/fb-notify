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
  id<FBRequest> lastUpdateRequest;
}

@property(assign) id<FBRequest> lastUpdateRequest;

+ (StatusUpdateManager*)manager;

- (BOOL)attachPhoto:(NSImage*)image;
- (void)removeAttachment;

- (BOOL)sendPost:(NSDictionary*)post;

@end
