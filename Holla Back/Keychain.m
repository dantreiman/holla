//
//  Keychain.m
//  Holla Back
//
//  Created by Dan Treiman on 11/1/14.
//  Copyright (c) 2014 Dan Treiman. All rights reserved.
//

#import "Keychain.h"


static NSString * ServiceName = @"HollaBack";


@implementation Keychain


+ (Keychain *) sharedKeychain
{
    static Keychain * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Keychain alloc] init];
    });
    return sharedInstance;
}


- (void) storePassword:(NSString *)password forAccount:(NSString *)account
{
    // See if we already have a password entered for these credentials.
    
    NSString * existingPassword = [self retrievePasswordForAccount:account];
    
    OSStatus status = noErr;
    
    if (existingPassword) {
        // We have an existing, properly entered item with a password.
        // Update the existing item.
        
        NSDictionary * query = @{(__bridge NSString *)kSecClass : (__bridge NSString *)kSecClassGenericPassword,
                                 (__bridge NSString *)kSecAttrService : ServiceName,
                                 (__bridge NSString *)kSecAttrAccount : account};
        
        NSDictionary * attributesToUpdate = @{(__bridge NSString *)kSecValueData : [password dataUsingEncoding:NSUTF8StringEncoding]};
        status = SecItemUpdate((__bridge CFDictionaryRef) query, (__bridge CFDictionaryRef) attributesToUpdate);
        if (status != noErr) {
            NSString * errorDescription = [NSString stringWithFormat:@"Could not update password for account %@.", account];
            NSLog(@"%@", errorDescription);
        }
    }
    else {
        // No existing entry, create a new entry.
        
        NSDictionary * query = @{
                                 (__bridge NSString *)kSecClass : (__bridge NSString *)kSecClassGenericPassword,
                                 (__bridge NSString *)kSecAttrService : ServiceName,
                                 (__bridge NSString *)kSecAttrAccount : account,
                                 (__bridge NSString *)kSecValueData : [password dataUsingEncoding:NSUTF8StringEncoding]
                                 };
        
        status = SecItemAdd((__bridge CFDictionaryRef) query, NULL);
        if (status != noErr) {
            NSString * errorDescription = [NSString stringWithFormat:@"Could not add password for account %@.", account];
            NSLog(@"%@", errorDescription);
        }
    }
    // TODO: if status != noErr, report error
}


- (void) forgetPasswordForAccount:(NSString *)account
{
    NSDictionary * query = @{(__bridge NSString *) kSecClass : (__bridge NSString *) kSecClassGenericPassword,
                             (__bridge NSString *)kSecAttrAccount : account,
                             (__bridge NSString *)kSecAttrService : ServiceName,
                             (__bridge NSString *)kSecReturnAttributes : (__bridge id)kCFBooleanTrue
                             };
    SecItemDelete((__bridge CFDictionaryRef) query);
}


- (NSString *) retrievePasswordForAccount:(NSString *)account
{
    // Set up a query dictionary with the base query attributes: item type (generic), username, and service
    
    NSDictionary * query = @{
                             (__bridge NSString *)kSecClass : (__bridge NSString *)kSecClassGenericPassword,
                             (__bridge NSString *)kSecAttrAccount : account,
                             (__bridge NSString *)kSecAttrService : ServiceName,
                             (__bridge NSString *) kSecReturnData : (__bridge id) kCFBooleanTrue
                             };
    
    // query item for the password data associated with it.
    OSStatus status = noErr;
    
    CFTypeRef resultData = NULL;
    
    status = SecItemCopyMatching((__bridge CFDictionaryRef) query, &resultData);
    
    if (status != noErr) {
        if (status == errSecItemNotFound) {
            // password for this account was not found
            // This is expected behavior, so don't log an error.
            //            NSString * errorDescription = [NSString stringWithFormat:@"Password not found for account %@.", account];
            //            WVRError * error = [WVRError errorWithCode:WVRKeychainReadError detailedDescription:errorDescription];
            //            [WVRErrorReporter reportError:error];
        }
        else {
            // Something else went wrong.
            NSString * errorDescription = [NSString stringWithFormat:@"Could not read password for account %@.", account];
            NSLog(@"%@", errorDescription);
        }
        return nil;
    }
    
    if (resultData) {
        NSString * password = [[NSString alloc] initWithData:(__bridge NSData *)resultData encoding:NSUTF8StringEncoding];
        return password;
    }
    return nil;
}


@end
