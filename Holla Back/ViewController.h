//
//  ViewController.h
//  Holla Back
//
//  Created by Dan Treiman on 11/1/14.
//  Copyright (c) 2014 Only The Best. All rights reserved.
//

#import <UIKit/UIKit.h>


@class Wallet;


@interface ViewController : UIViewController

- (void) walletLoaded:(Wallet *)wallet;

@end

