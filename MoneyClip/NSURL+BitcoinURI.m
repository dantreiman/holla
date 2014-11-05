//
//  NSURL+BitcoinURI.m
//  MoneyClip

//
//  Created by Dan Treiman on 11/1/14.
//  Copyright (c) 2014 Only The Best. All rights reserved.
//

#import "NSURL+BitcoinURI.h"

@implementation NSURL (BitcoinURI)

+ (NSURL *) URLWithBitcoinAddress:(NSString *)address amount:(NSString *)amount message:(NSString *)message
{
    NSMutableString * urlString = [NSMutableString stringWithFormat:@"bitcoin:%@", address];
    
    NSMutableArray * queryParams = [[NSMutableArray alloc] init];
    
    if (amount) {
        [queryParams addObject:[NSString stringWithFormat:@"amount=%@", amount]];
    }
    
    if (message) {
        [queryParams addObject:[NSString stringWithFormat:@"message=%@", [message stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
    }
    
    if (queryParams.count > 0) {
        [urlString appendString:@"?"];
        NSString * query = [queryParams componentsJoinedByString:@"&"];
        [urlString appendString:query];
    }
    
    return [NSURL URLWithString:urlString];
}


// while the standard says url query may contain multiple key-value pairs with the same key,
// we don't need that for this application and don't handle that case. The last key-value pair
// will appear in the dictionary.
- (NSDictionary *) queryParameters
{
    NSString * query = [[self.absoluteString componentsSeparatedByString:@"?"] lastObject];
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    NSArray * queryPairs = [query componentsSeparatedByString:@"&"];
    for (NSString * key in queryPairs) {
        NSArray * pair = [key componentsSeparatedByString:@"="];
        if (pair.count == 2) {
            [dictionary setObject:pair[1] forKey:pair[0]];
        }
    }
    return dictionary;
}


- (NSString *) bitcoinAddress
{
    NSScanner * scanner = [NSScanner scannerWithString:self.absoluteString];
    [scanner scanString:@"bitcoin:" intoString:NULL];
    NSString * result = nil;
    [scanner scanUpToString:@"?" intoString:&result];
    return result;
}


- (NSDecimalNumber *) bitcoinAmount
{
    return [NSDecimalNumber decimalNumberWithString:self.queryParameters[@"amount"]];
}


- (NSString *) bitcoinMessage
{
    return self.queryParameters[@"message"];
}


@end
