//
//  Keychain.h
//  Holla Back
//
//  Created by Dan Treiman on 11/1/14.
//  Copyright (c) 2014 Only The Best. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Keychain : NSObject


+ (Keychain *) sharedKeychain;


- (void) storePassword:(NSString *)password forAccount:(NSString *)account;
- (void) forgetPasswordForAccount:(NSString *)account;
- (NSString *) retrievePasswordForAccount:(NSString *)account;

@end
