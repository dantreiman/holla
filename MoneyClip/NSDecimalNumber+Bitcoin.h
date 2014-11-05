//
//  NSDecimalNumber+Bitcoin.h
//  MoneyClip

//
//  Created by Dan Treiman on 11/1/14.
//  Copyright (c) 2014 Only The Best. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDecimalNumber (Bitcoin)


- (NSDecimalNumber *) convertSatoshiToBTC;


- (NSDecimalNumber *) convertBTCToSatoshi;


@end
