//
//  Wallet.h
//  Holla Back
//
//  Created by Julian Vergel de Dios on 11/1/14.
//  Copyright (c) 2014 Only The Best. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Wallet : NSObject

@property (nonatomic, strong) NSString *guid;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *address;

- (instancetype)initWithGUID:(NSString *)guid andPassword:(NSString *)password;
- (void)generateAddress:(void (^)(NSString *))success failure:(void (^)(void))failure;
- (void)sendPayment:(NSString *)address amount:(int)amount success:(void (^)(NSString *))success failure:(void (^)(void))failure;
+ (instancetype)fetchOrCreateWallet:(void (^)(Wallet *))success failure:(void (^)(void))failure;

@end
