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
#define kBlockchainListAddressesPath @"merchant/%@/list"

#define kBlockchainPaymentPath @"merchant/%@/payment"
// Free to use without a code, but subject to rate limit
#define kBlockchainAPICode @"3b69c012-a33a-41fe-b849-d7670fd8d3b3"

#define kWalletGUIDDefaultKey @"holla:defaults:wallet_guid"


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
    NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.money2020hack.hollaback"];
    Keychain * keychain = [Keychain sharedKeychain];
    
    // Dan's iPhone address and password
//    [defaults setObject:@"e28aa765-9c7c-4768-9e65-3b7380a7be0b" forKey:kWalletGUIDDefaultKey];
//    [defaults synchronize];
//    [keychain storePassword:@"yiG6Cal3neK3ep8d" forAccount:@"e28aa765-9c7c-4768-9e65-3b7380a7be0b"];
    
    NSString * walletGUID = [defaults stringForKey:kWalletGUIDDefaultKey];
    NSString * password = [keychain retrievePasswordForAccount:walletGUID];
    
    if (walletGUID != nil) {
        success([[Wallet alloc] initWithGUID:walletGUID andPassword:password]);
        return;
    }
    
    NSString *walletUrl = [NSString stringWithFormat:@"%@%@",
                           kBlockchainBaseURL, kBlockchainCreateWalletPath];
    password = [self generateRandomPassword:25];
    NSDictionary *params = @{ @"password" : password,
                             @"api_code": kBlockchainAPICode};
    
    [[self httpManager] POST:walletUrl
                  parameters:params
                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                         NSDictionary *response = (NSDictionary *)responseObject;
                         NSString *walletGUID = response[@"guid"];
                         [defaults setValue:walletGUID forKey:kWalletGUIDDefaultKey];
                         [defaults synchronize];
                         [keychain storePassword:password forAccount:walletGUID];
                         Wallet *wallet = [[Wallet alloc] initWithGUID:walletGUID andPassword:password];
                         NSLog(@"Successfully created wallet: %@", wallet.guid);
                         success(wallet);
                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         NSLog(@"Error: %@", error.debugDescription);
                         
//#warning Fix this once we get a token with wallet create permission
//                         NSString * walletGUID = @"e28aa765-9c7c-4768-9e65-3b7380a7be0b";
//                         NSString * password = @"yiG6Cal3neK3ep8d";
//                         [defaults setValue:walletGUID forKey:kWalletGUIDDefaultKey];
//                         [defaults synchronize];
//                         [keychain storePassword:password forAccount:walletGUID];
//                         NSLog(@"Could not create wallet, initializing with dan's test wallet ID: %@", walletGUID);
//                         Wallet * wallet = [[Wallet alloc] initWithGUID:walletGUID andPassword:password];
//                         success(wallet);
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
                           self.address = address;
                           success(address);
                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                           NSLog(@"Error generating address: %@", error.debugDescription);
                           failure();
                       }];
    
}


- (void)fetchAddresses:(void (^)(NSString * address))success failure:(void (^)(void))failure {
    NSString *listPath = [NSString stringWithFormat:kBlockchainListAddressesPath, self.guid];
    NSString *listAddressesURL = [NSString stringWithFormat:@"%@%@",
                           kBlockchainBaseURL, listPath];

    NSDictionary * params = @{ @"password": self.password };
    
    [[Wallet httpManager] GET:listAddressesURL
                    parameters:params
                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                           NSDictionary *response = (NSDictionary *)responseObject;
                           NSArray *addresses = response[@"addresses"];
                           if (addresses.count > 0) {
                               NSDictionary * addressJSON = addresses.firstObject;
                               self.address = addressJSON[@"address"];
                               NSDecimalNumber * balanceSatoshi = [NSDecimalNumber decimalNumberWithString:[addressJSON[@"balance"] stringValue]];
                               self.balance = [balanceSatoshi convertSatoshiToBTC];
                               success(self.address);
                           }
                           else {
                               NSLog(@"No addreses in response");
                               failure();
                           }
                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                           NSLog(@"Error listing address: %@", error.debugDescription);
                           failure();
                       }];
    
}


- (void)sendPayment:(NSString *)address
             amount:(NSDecimalNumber *)amount
            success:(void (^)(NSString *))success
            failure:(void (^)(void))failure {
    
    NSString * paymentPath = [NSString stringWithFormat:kBlockchainPaymentPath, self.guid];
    NSString * paymentURL = [kBlockchainBaseURL stringByAppendingString:paymentPath];
    NSMutableDictionary * params = [self baseParams];
    [params setObject:address forKey:@"to"];
    [params setObject:amount.stringValue forKey:@"amount"];
    
    [[Wallet httpManager] POST:paymentURL
                    parameters:params
                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                           NSDictionary *response = (NSDictionary *)responseObject;
                           NSString *message = response[@"message"];
                           NSLog(@"Made a transaction: %@", response[@"tx_hash"]);
                           success(message);
                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                           NSLog(@"Failed to post payment: %@", error.debugDescription);
                           failure();
                       }];
}

- (NSMutableDictionary *)baseParams {
    return [NSMutableDictionary
            dictionaryWithDictionary:@{@"api_code":kBlockchainAPICode, @"password": self.password}];
}

+ (AFHTTPRequestOperationManager *)httpManager {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        AFHTTPRequestSerializer * serializer = [AFHTTPRequestSerializer serializer];
//        [serializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//        [[AFHTTPRequestOperationManager manager] setRequestSerializer:serializer];
//    });
    
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
