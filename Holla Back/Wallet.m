//
//  Wallet.m
//  Holla Back
//
//  Created by Julian Vergel de Dios on 11/1/14.
//  Copyright (c) 2014 Only The Best. All rights reserved.
//

#import "Wallet.h"
#import "AFHTTPRequestOperationManager.h"
#import "Keychain.h"

#define kBlockchainBaseURL @"https://blockchain.info/"
#define kBlockchainCreateWalletPath @"api/v2/create_wallet"
#define kBlockchainAddressPath @"merchant/%@/new_address"
#define kBlockchainPaymentPath @"merchant/%@/payment"
#define kBlockchainAPICode @""

#define kWalletGUIDDefaultKey @"holla:defaults:wallet_guid"
#define kWalletPasswordDefaultKey @"holla:defaults:wallet_password"

@implementation Wallet

- (instancetype)initWithGUID:(NSString *)guid andPassword:(NSString *)password {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.guid = guid;
    self.password = password;
    
    return self;
}

+ (void)fetchOrCreateWallet:(void (^)(Wallet *))success failure:(void (^)(void))failure {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    Keychain *keychain = [Keychain sharedKeychain];
    NSString *walletGUID = [defaults stringForKey:kWalletGUIDDefaultKey];
    NSString *password = [keychain retrievePasswordForAccount:kWalletPasswordDefaultKey];
    
    if (walletGUID != nil) {
        success([[Wallet alloc] initWithGUID:walletGUID andPassword:password]);
    }
    
    NSString *walletUrl = [NSString stringWithFormat:@"%@%@",
                           kBlockchainBaseURL, kBlockchainCreateWalletPath];
    password = [self generateRandomPassword:25];
    [keychain storePassword:password forAccount:kWalletPasswordDefaultKey];
    NSDictionary *params = @{@"password": password,
                             @"api_code": kBlockchainAPICode};
    
    [[self httpManager] POST:walletUrl
                  parameters:params
                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                         NSDictionary *response = (NSDictionary *)responseObject;
                         NSString *walletGUID = response[@"guid"];
                         [defaults setValue:walletGUID forKey:kWalletGUIDDefaultKey];
                         [defaults synchronize];
                         Wallet *wallet = [[Wallet alloc] initWithGUID:walletGUID andPassword:password];
                         success(wallet);
                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         failure();
                     }];
}

- (void)generateAddress:(void (^)(NSString *))success
                failure:(void (^)(void))failure {
    NSString *addressURL = [NSString stringWithFormat:kBlockchainAddressPath, self.guid];
    NSMutableDictionary *params = [self baseParams];
    
    [[Wallet httpManager] POST:addressURL
                    parameters:params
                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                           NSDictionary *response = (NSDictionary *)responseObject;
                           NSString *address = response[@"address"];
                           success(address);
                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                           failure();
                       }];
    
}

- (void)sendPayment:(NSString *)address
             amount:(int)amount
            success:(void (^)(NSString *))success
            failure:(void (^)(void))failure {
    
    NSString *paymentURL = [NSString stringWithFormat:kBlockchainPaymentPath, self.guid];
    NSMutableDictionary *params = [self baseParams];
    [params setObject:address forKey:@"to"];
    [params setObject:[NSString stringWithFormat:@"%i", amount] forKey:@"amount"];
    
    [[Wallet httpManager] POST:paymentURL
                    parameters:params
                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                           NSDictionary *response = (NSDictionary *)responseObject;
                           NSString *message = response[@"message"];
                           success(message);
                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                           failure();
                       }];
}

- (NSMutableDictionary *)baseParams {
    return [NSMutableDictionary
            dictionaryWithDictionary:@{@"api_code":kBlockchainAPICode, @"password": self.password}];
}

+ (AFHTTPRequestOperationManager *)httpManager {
    return [AFHTTPRequestOperationManager manager];
}

+ (NSString *)generateRandomPassword:(int)len {
    // DON'T DO THIS FOR REAL PW GENERATION
    // THIS IS FOR A HACKATHON, THIS PROVIDES
    // NO REAL SECURITY
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}

@end
