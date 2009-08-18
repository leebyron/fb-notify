//
//  FBConnect.h
//  FBCocoa
//
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kFBErrorDomainKey @"kFBErrorDomainKey"
#define kFBErrorMessageKey @"kFBErrorMessageKey"

@class FBConnect;
@class FBSessionState;
@class FBWebViewWindowController;

/*!
 * @category FBConnectDelegate(NSObject)
 * These are methods that FBConnect may call on its delegate. They are all
 * optional.
 */
@interface NSObject (FBConnectDelegate)

/*!
 * Called when the FBConnect has completed logging in to Facebook.
 */
- (void)FBConnectLoggedIn:(FBConnect *)fbc;

/*!
 * Called when a login request has failed.
 */
- (void)FBConnectErrorLoggingIn:(FBConnect *)fbc;

/*!
 * Called when the FBConnect has completed logging out of Facebook.
 */
- (void)FBConnectLoggedOut:(FBConnect *)fbc ;

/*!
 * Called when a logout request has failed.
 */
- (void)FBConnectErrorLoggingOut:(FBConnect *)fbc ;

@end


/*!
 * @class FBConnect
 *
 * FBConnect handles all transactions with the Facebook API: logging in and
 * sending FQL queries.
 */
@interface FBConnect : NSObject {
  NSString *APIKey;
  NSString *appSecret;
  FBSessionState *sessionState;
  
  BOOL isLoggedIn;
  id delegate;
  
  FBWebViewWindowController *windowController;
}

/*!
 * Convenience constructor for an FBConnect.
 * @param key Your API key, provided by Facebook.
 * @param secret Your application secret, provided by Facebook.
 * @param delegate An object that will receive delegate method calls when
 * certain events happen in the session. See FBConnectDelegate.
 */
+ (FBConnect *)sessionWithAPIKey:(NSString *)key
                          secret:(NSString *)secret
                        delegate:(id)obj;

- (id)initWithAPIKey:(NSString *)key
              secret:(NSString *)secret
            delegate:(id)obj;

/*!
 * Returns the logged-in user's uid as a string. If the session has not been
 * logged in, returns nil. Note that this may return a non-nil value despite
 * the session key being expired.
 */
- (NSString *)uid;

- (BOOL)isLoggedIn;

/*!
 * Causes the session to start the login process. This method is asynchronous;
 * i.e. it returns immediately, and the session is not necessarily logged in
 * when this method returns. The receiver's delegate will receive a
 * -sessionCompletedLogin: or -session:failedLogin: message when the process
 * completes. See FBConnectDelegate.
 *
 * Note that in the process of logging in, FBConnect may cause a window to
 * appear onscreen, displaying a Facebook webpage where the user must enter
 * their login credentials.
 */
- (void)login;

- (void)loginWithPermissions:(NSArray *)perms;

/*!
 * Tests to see if the user has accepted a particular permission
 *
 * @result Whether the permission has been accepted
 */
- (BOOL)hasPermission:(NSString *)perm;

/*!
 * Logs out the current session. If a user defaults key for storing persistent
 * sessions has been set, this method clears the stored session, if any.
 *
 * @result Whether the request was sent. Returns NO if this session already has
 * a request in flight.
 */
- (void)logout;

/*!
 * Sends an API request with a particular method.
 */
- (void)callMethod:(NSString *)method
     withArguments:(NSDictionary *)dict
            target:(id)target
          selector:(SEL)selector
             error:(SEL)error;

/*!
 * Sends an FQL query within the session. See the Facebook Developer Wiki for
 * information about FQL. This method is asynchronous; the receiver's delegate
 * will receive a -session:receivedResponse: message when the process completes.
 * See FBConnectDelegate.
 */
- (void)sendFQLQuery:(NSString *)query
              target:(id)target
            selector:(SEL)selector
               error:(SEL)error;

/*!
 * Sends an FQL.multiquery request. See the Facebook Developer Wiki for
 * information about FQL. This method is asynchronous; the receiver's delegate
 * will receive a -session:receivedResponse: message when the process completes.
 * See FBConnectDelegate.
 *
 * @param queries A dictionary mapping strings (query names) to strings
 * (FQL query strings).
 */
- (void)sendFQLMultiquery:(NSDictionary *)queries
                   target:(id)target
                 selector:(SEL)selector
                    error:(SEL)error;

@end
