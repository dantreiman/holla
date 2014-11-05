//
//  AppDelegate.m
//  MoneyClip

//
//  Created by Dan Treiman on 11/1/14.
//  Copyright (c) 2014 Only The Best. All rights reserved.
//

#import "AppDelegate.h"
#import "Chain.h"
#import "Wallet.h"
#import "ChainNotificationCenter.h"
#import "ViewController.h"


@interface AppDelegate ()

@property (nonatomic, strong) NSTimer * backgroundTimer;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

@end

@implementation AppDelegate


- (ViewController *) viewController
{
    return (ViewController *) self.window.rootViewController;
}


- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Initialize Chain
    Chain * chain = [Chain sharedInstanceWithToken:@"08f3b259a2d06e8515a01426de687f34"];
    
    // Sample Code
//    NSString * address = @"1A3tnautz38PZL15YWfxTeh8MtuMDhEPVB";
//    [chain getAddress:address completionHandler:^(NSDictionary *dict, NSError *error) {
//        NSLog(@"data=%@ error=%@", dict, error);
//    }];
    
    
    [Wallet fetchOrCreateWallet:^(Wallet * wallet) {
        NSLog(@"Loaded Wallet:\n GUID: %@\n Password: %@\n", wallet.guid, wallet.password);
        
        [wallet fetchAddresses:^(NSString * address) {
            NSLog(@"Address = %@", address);
            NSUserDefaults * userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.money2020hack.moneyclip"];
            [userDefaults setObject:address forKey:@"Address"];
            [userDefaults synchronize];
            ChainNotificationCenter *chainNotifier = [ChainNotificationCenter sharedCenter];
            chainNotifier.address = address;
            [chainNotifier open];
            [self.viewController walletLoaded:wallet];
        } failure:^{}];
        
    } failure:^{

    }];

    [self registerForNotifications];
    return YES;
}


- (void) registerForNotifications
{
    UIUserNotificationSettings * settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound
                                                                              categories:[NSSet set]];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    NSLog(@"Application entered background state.");
    // NSAssert(self.backgroundTask == UIBackgroundTaskInvalid, nil);
    
    self.backgroundTask = [application beginBackgroundTaskWithExpirationHandler: ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Background task expired");
            if (self.backgroundTimer)
            {
                [self.backgroundTimer invalidate];
                self.backgroundTimer = nil;
            }
            [application endBackgroundTask:self.backgroundTask];
            self.backgroundTask = UIBackgroundTaskInvalid;
        });
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.backgroundTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timerUpdate:) userInfo:nil repeats:YES];
    });
}


- (void) timerUpdate:(NSTimer *) timer
{
    UIApplication * application = [UIApplication sharedApplication];
    NSLog(@"Timer update, background time left: %f", application.backgroundTimeRemaining);
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    if (self.backgroundTask != UIBackgroundTaskInvalid) {
        [application endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
    [self.backgroundTimer invalidate];
    self.backgroundTimer = nil;
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
