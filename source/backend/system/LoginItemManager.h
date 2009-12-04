//
//  LoginItemManager.h
//  FBDesktopNotifications
//
//  Created by Lee Byron on 8/20/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LoginItemManager : NSObject

+ (LoginItemManager*)manager;

- (void)loginItemAsDefault:(BOOL)isDefault;
- (void)setIsLoginItem:(BOOL)status;
- (BOOL)isLoginItem;
- (BOOL)wasLaunchedAsLoginItem;

@end
