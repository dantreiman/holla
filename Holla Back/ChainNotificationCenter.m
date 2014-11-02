//
//  ChainNotificationCenter.m
//  Holla Back
//
//  Created by Julian Vergel de Dios on 11/1/14.
//  Copyright (c) 2014 Only The Best. All rights reserved.
//

#import "ChainNotificationCenter.h"
@import UIKit;

@interface ChainNotificationCenter ()

@property (nonatomic, strong) SRWebSocket *socket;


@end

@implementation ChainNotificationCenter

+ (id)sharedCenter {
    static ChainNotificationCenter *sharedCenter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCenter = [[self alloc] init];
    });
    return sharedCenter;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        NSURL *url = [NSURL URLWithString:@"wss://ws.chain.com/v2/notifications"];
        self.socket = [[SRWebSocket alloc] initWithURL:url];
        self.socket.delegate = self;
    }
    
    return self;
}

- (void)open {
    [self.socket open];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (!json) {
        NSLog(@"Error: %@", error.debugDescription);
        return;
    }
    
    NSDictionary *payload = json[@"payload"];
    NSNumber *received = payload[@"received"];
    NSNumber *confirmations = payload[@"confirmations"];
    if (received > 0 && confirmations == 0) {
        NSNumber *amountInBTC = [NSNumber numberWithDouble:[received doubleValue] / 100000000.0f];
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = [NSString stringWithFormat:@"You received %f BTC!", [amountInBTC doubleValue]];
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.applicationIconBadgeNumber = 1;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSDictionary *params = @{@"type": @"address", @"address": self.address, @"block_chain": @"bitcoin"};
//    NSDictionary *params = @{@"type": @"new-transaction", @"block_chain": @"bitcoin"};
    NSString *jsonString = [self jsonStringFromDictionary:params];
    [webSocket send:jsonString];
}

- (NSString *)jsonStringFromDictionary:(NSDictionary *)dictionary {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
        return nil;
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }

}

@end
