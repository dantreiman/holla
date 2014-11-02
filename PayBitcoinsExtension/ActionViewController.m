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

@property (strong, nonatomic) NSDecimalNumber * amount;
@property (strong, nonatomic) Wallet * wallet;
@property (strong, nonatomic) NSString * receivingAddress;

@end


@implementation ActionViewController


- (UIFont *) boldFont
{
    return [UIFont boldSystemFontOfSize:17];
}


- (UIFont *) regularFont
{
    return [UIFont systemFontOfSize:17];
}


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
                            [self loadWallet];
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
        self.receivingAddress = url.bitcoinAddress;
        self.amount = url.bitcoinAmount;
        NSString * message = url.bitcoinMessage;
        
        NSDictionary * boldAttrs = @{ NSFontAttributeName: self.boldFont };
        NSDictionary * regularAttrs = @{ NSFontAttributeName: self.regularFont };
        NSMutableAttributedString * requestText = [[NSMutableAttributedString alloc] initWithString:@"Requested: " attributes:regularAttrs];
        
        [requestText appendAttributedString:[[NSAttributedString alloc] initWithString:self.amount.stringValue attributes:boldAttrs]];
        [requestText appendAttributedString:[[NSAttributedString alloc] initWithString:@" BTC" attributes:regularAttrs]];

        self.requestedLabel.attributedText = requestText;
        self.messageLabel.text = message ? message : @"";
    }
    else {
        // Warn user no sender information detected
    }
}


- (void) loadWallet
{
    self.balanceLabel.text = @"";
    __weak ActionViewController * weakSelf = self;
    [Wallet fetchOrCreateWallet:^(Wallet * wallet)
     {
         weakSelf.wallet = wallet;
         [wallet fetchAddresses:^(NSString * address) {
             [weakSelf displayBalance];
         } failure:^{}];
     } failure:^{}];
}


- (void) displayBalance
{
    Wallet * wallet = self.wallet;
    NSDecimalNumber * balance = wallet.balance ? wallet.balance : [NSDecimalNumber zero];
    BOOL balanceSufficient = [balance compare:self.amount] == NSOrderedDescending;
    
    NSDictionary * boldAttrs = @{ NSFontAttributeName: self.boldFont };
    NSDictionary * regularAttrs = @{ NSFontAttributeName: self.regularFont };
    NSDictionary * redAttrs = @{ NSFontAttributeName: self.boldFont, NSForegroundColorAttributeName: [UIColor redColor] };

    NSMutableAttributedString * balanceText = [[NSMutableAttributedString alloc] initWithString:@"Current Balance: " attributes:regularAttrs];
    [balanceText appendAttributedString:[[NSAttributedString alloc] initWithString:balance.stringValue attributes:balanceSufficient ? boldAttrs : redAttrs]];
    [balanceText appendAttributedString:[[NSAttributedString alloc] initWithString:@" BTC" attributes:regularAttrs]];
    self.balanceLabel.attributedText = balanceText;
    
    if (!balanceSufficient) {
        self.messageLabel.text = @"Insufficient Balance.";
    }
    else {
        self.confirmButton.enabled = YES;
    }
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
    [self.wallet sendPayment:self.receivingAddress
                      amount:[self.amount convertBTCToSatoshi]
                     success:^(NSString * message) {
                         [self paymentSucceeded];
                     }
                     failure:^ {
                         
                     }];
}


- (void) paymentSucceeded
{
        // Show feedback
    [self.view exchangeSubviewAtIndex:0 withSubviewAtIndex:self.view.subviews.count - 1];
    [UIView animateWithDuration:1.0 animations:^{
        self.successView.alpha = 1.0;
    }];
}


@end
