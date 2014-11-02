//
//  ViewController.m
//  Holla Back
//
//  Created by Dan Treiman on 11/1/14.
//  Copyright (c) 2014 Only The Best. All rights reserved.
//

#import "ViewController.h"
#import "NSURL+BitcoinURI.h"
#import "UIImage+QRCodes.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView * imageView;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString * address = @"ADDRESS";
    NSString * amount = @"0.03";
    NSURL * url = [NSURL URLWithBitcoinAddress:address amount:amount message:nil];
    
    UIImage * qrCode = [UIImage imageWithCode:[url.absoluteString dataUsingEncoding:NSUTF8StringEncoding]];
    [UIPasteboard generalPasteboard].image = qrCode;
    self.imageView.image = qrCode;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
