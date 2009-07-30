//
//  MenuManager.h
//  Facebook
//
//  Created by Lee Byron on 7/29/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MenuManager : NSObject {
  NSImage *fbActiveIcon;
  NSImage *fbEmptyIcon;
  NSImage *fbFullIcon;

  NSStatusItem *statusItem;
  NSMenu *statusItemMenu;

  NSString *userName;
  NSString *profileURL;
}

@property(retain) NSString *userName;
@property(retain) NSString *profileURL;

- (void)setName:(NSString *)name profileURL:(NSString *)url;
- (void)constructWithNotifications:(NSMutableArray *)notifications;

@end
