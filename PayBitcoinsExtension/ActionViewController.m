//
//  ActionViewController.m
//  PayBitcoinsExtension
//
//  Created by Dan Treiman on 11/1/14.
//  Copyright (c) 2014 Only The Best. All rights reserved.
//

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+QRCodes.h"
#import "NSURL+BitcoinURI.h"
#import "Wallet.h"

@interface ActionViewController ()

@property (weak ,nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView * successView;
@property (weak, nonatomic) IBOutlet UILabel * requestedLabel;
@property (weak, nonatomic) IBOutlet UILabel * balanceLabel;
@property (weak, nonatomic) IBOutlet UILabel * messageLabel;
@property (weak, nonatomic) IBOutlet UIButton * confirmButton;
@property (weak, nonatomic) IBOutlet UIButton * cancelButton;

@end

@implementation ActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get the item[s] we're handling from the extension context.
    
    // For example, look for an image and place it into an image view.
    // Replace this with something appropriate for the type[s] your extension supports.
    BOOL imageFound = NO;
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                // This is an image. We'll load it, then place it in our image view.
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *image, NSError *error) {
                    if(image) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [self loadImage:image];
                        }];
                    }
                }];
                
                imageFound = YES;
                break;
            }
        }
        
        if (imageFound) {
            // We only handle one image, so stop looking for more.
            break;
        }
    }
}


- (void) loadImage:(UIImage *)image
{
    [self.imageView setImage:image];
    NSData * code = [image codeExtractedFromImage];
    if (code) {
        NSString * urlString = [[NSString alloc] initWithData:code encoding:NSUTF8StringEncoding];
        NSURL * url = [NSURL URLWithString:urlString];
        NSString * address = url.bitcoinAddress;
        NSString * amount = url.bitcoinAmount;
        NSString * message = url.bitcoinMessage;
        
        self.requestedLabel.text = [NSString stringWithFormat:@"Requested: %@ BTC", amount];
        self.messageLabel.text = message ? message : @"";
        [self loadWallet];
    }
    else {
        // Warn user no sender information detected
    }
}


- (void) loadWallet
{
    self.balanceLabel.text = @"";
    [Wallet fetchOrCreateWallet:^(Wallet * wallet)
     {
         
     } failure:^{}];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions


- (IBAction) done {
    // Return any edited content to the host app.
    // This template doesn't do anything, so we just echo the passed in items.
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}


- (IBAction) confirm:(id)sender {
    // Do Transaction
    //...
    
    // Show feedback
    [self.view exchangeSubviewAtIndex:0 withSubviewAtIndex:self.view.subviews.count - 1];
    [UIView animateWithDuration:1.0 animations:^{
        self.successView.alpha = 1.0;
    }];
}


@end
