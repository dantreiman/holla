//
//  NSURL+BitcoinURI.h
//  Holla Back
//
//  Created by Dan Treiman on 11/1/14.
//  Copyright (c) 2014 Only The Best. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (BitcoinURI)

/**
 * @param address The bitcoin receiving address
 * @param amount The amount (optional)
 * @param message An optional message describing the request (optional)
 */
+ (NSURL *) URLWithBitcoinAddress:(NSString *)address amount:(NSString *)amount message:(NSString *)message;


@property (readonly) NSString * bitcoinAddress;
@property (readonly) NSDecimalNumber * bitcoinAmount;
@property (readonly) NSString * bitcoinMessage;


@end
