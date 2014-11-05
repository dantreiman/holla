//
//  ChainNotificationCenter.h
//  Holla Back
//
//  Created by Julian Vergel de Dios on 11/1/14.
//  Copyright (c) 2014 Only The Best. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket/SRWebSocket.h>

@interface ChainNotificationCenter : NSObject <SRWebSocketDelegate>

@property (nonatomic, strong) NSString *address;

+ (id)sharedCenter;

- (instancetype)init;

- (void)open;

@end
