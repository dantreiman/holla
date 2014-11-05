//
//  Wallet.h
//  Holla Back
//
//  Created by Julian Vergel de Dios on 11/1/14.
//  Copyright (c) 2014 Only The Best. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDecimalNumber+Bitcoin.h"


@interface Wallet : NSObject

@property (nonatomic, strong) NSString *guid;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSDecimalNumber *balance;  // The balance (in BTC)


- (instancetype)initWithGUID:(NSString *)guid andPassword:(NSString *)password;
- (void)generateAddress:(void (^)(NSString * address))success failure:(void (^)(void))failure;
- (void)fetchAddresses:(void (^)(NSString * address))success failure:(void (^)(void))failure;

/**
 * @param address The receiving address.
 * @param amount The amount in satoshi.
 */
- (void)sendPayment:(NSString *)address amount:(NSDecimalNumber *)amount success:(void (^)(NSString *))success failure:(void (^)(void))failure;
+ (void)fetchOrCreateWallet:(void (^)(Wallet *))success failure:(void (^)(void))failure;

@end
