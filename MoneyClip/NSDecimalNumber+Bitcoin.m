//
//  NSDecimalNumber+Bitcoin.m
//  MoneyClip

//
//  Created by Dan Treiman on 11/1/14.
//  Copyright (c) 2014 Only The Best. All rights reserved.
//

#import "NSDecimalNumber+Bitcoin.h"

@implementation NSDecimalNumber (Bitcoin)


- (NSDecimalNumber *) convertSatoshiToBTC
{
    return [self decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"100000000"]];
}


- (NSDecimalNumber *) convertBTCToSatoshi
{
    return [self decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"100000000"]];
}


@end
