//
//  NSStringAdditions.h
//  FBCocoa
//
//  Created by Owen Yamauchi on 7/22/09.
//  Copyright 2009 Facebook Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (NSStringAdditions)

+ (NSString *)urlEncodeArguments:(NSDictionary *)dict;

- (NSString *)stringByEscapingQuotesAndBackslashes;

- (NSDictionary *)simpleJSONDecode;

- (NSString *)hexMD5;

- (BOOL)containsString:(NSString *)string;

@end
