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
#import "NSURL+BitcoinURI.h"
#import "Wallet.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView * imageView;
@property (strong, nonatomic) Wallet * wallet;

@end


@implementation ViewController


- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    __weak ViewController * weakSelf = self;
    [Wallet fetchOrCreateWallet:^(Wallet * wallet) {
        weakSelf.wallet = wallet;
        [wallet fetchAddresses:^(NSString * address) {
            NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:address forKey:@"Address"];
            [self generateQRCode];
        } failure:^{}];
        
    } failure:^{
        
    }];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}


- (void) generateQRCode
{
    // Create a QR code image
    NSString * address = self.wallet.address;
    NSURL * url = [NSURL URLWithBitcoinAddress:address amount:nil message:nil];
    
    UIImage * qrCode = [UIImage imageWithCode:[url.absoluteString dataUsingEncoding:NSUTF8StringEncoding]];
    [UIPasteboard generalPasteboard].image = qrCode;
    self.imageView.image = qrCode;
    
    // Decode QR Code image
    NSData * result = [qrCode codeExtractedFromImage];
    NSString * urlString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    NSURL * testURL = [NSURL URLWithString:urlString];
    NSString * testAddress = testURL.bitcoinAddress;
    NSDecimalNumber * testAmount = testURL.bitcoinAmount;
    NSString * testMessage = testURL.bitcoinMessage;
    
    NSLog(@"%@, %@, %@", testAddress, testAmount, testMessage);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Actions


- (IBAction) share:(UIButton *)sender
{
    // For testing, bring up UIActionSheet with the image
    NSArray * items = @[self.imageView.image];
    UIActivityViewController * controller = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    controller.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
    };
    if ([controller respondsToSelector:@selector(popoverPresentationController)] && controller.popoverPresentationController) {
        controller.popoverPresentationController.sourceView = sender;
        controller.popoverPresentationController.sourceRect = CGRectZero;
        controller.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown | UIPopoverArrowDirectionUp;
    }
    
    [self presentViewController:controller animated:YES completion:NULL];
}


@end
