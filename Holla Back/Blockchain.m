//
//  Blockchain.m
//  Holla Back
//
//  Created by Julian Vergel de Dios on 11/1/14.
//  Copyright (c) 2014 Only The Best. All rights reserved.
//

#import "Blockchain.h"
#import "AFHTTPRequestOperationManager.h"

@implementation Blockchain

NSString *const BlockchainBaseUrl = @"https://blockchain.info/";

- (NSString *)createWallet {
    return @"hello";
}

- (AFHTTPRequestOperationManager *)httpManager {
    return [AFHTTPRequestOperationManager manager];
}

@end
