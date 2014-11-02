//
//  KeyboardViewController.m
//  BitcoinKeyboard
//
//  Created by Dan Treiman on 11/1/14.
//  Copyright (c) 2014 Only The Best. All rights reserved.
//

#import "KeyboardViewController.h"
#import "NSURL+BitcoinURI.h"
#import "UIImage+QRCodes.h"
#import "Wallet.h"


@interface KeyboardViewController ()


@property (weak, nonatomic) IBOutlet UISlider * amountSlider;
@property (weak, nonatomic) IBOutlet UIButton * requestButton;
@property (weak, nonatomic) IBOutlet UILabel * requestLabel;

@property (strong, nonatomic) Wallet *wallet;


- (IBAction) deleteBackward:(id)sender;
- (IBAction) nextInputMode:(id)sender;


@end


@implementation KeyboardViewController


- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    // Add custom view sizing constraints here
}


- (void) loadView
{
    [super loadView];
    UINib * nib = [UINib nibWithNibName:@"KeyboardViewController" bundle:nil];
    [nib instantiateWithOwner:self options:nil];
    [self amountChanged:self.amountSlider];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated
}


- (void)textWillChange:(id<UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.
}


- (void)textDidChange:(id<UITextInput>)textInput {
    // The app has just changed the document's contents, the document context has been updated.
    
    UIColor *textColor = nil;
    if (self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearanceDark) {
        textColor = [UIColor whiteColor];
    } else {
        textColor = [UIColor blackColor];
    }
}


#pragma mark - Actions


- (double) BTCAmount
{    
    // Increment by .002 (about $1 USD)
    float sliderValue = [self.amountSlider value];
    double BTC = sliderValue;
    return BTC;
}


- (IBAction) amountChanged:(id)sender
{
    double BTC = [self BTCAmount];
    double USD = BTC * 350.0; // Approximation
    NSString * title = [NSString stringWithFormat:@"Request %.3f BTC (%.2f USD)", BTC, USD];
    self.requestLabel.text = title;
}


- (IBAction) requestPayment:(id)sender
{
    NSUserDefaults * userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.money2020hack.hollaback"];
    NSString * address = [userDefaults stringForKey:@"Address"];
    // NSString * address = self.wallet.address;
    if (!address) {
#warning Replace this with fallback address for demo
        address = @"ADDRESS";
    }
    NSString * amount = [NSString stringWithFormat:@"%.3f", [self BTCAmount]];
    NSURL * url = [NSURL URLWithBitcoinAddress:address amount:amount message:nil];
    UIImage * qrCode = [UIImage imageWithCode:[url.absoluteString dataUsingEncoding:NSUTF8StringEncoding]];
    [UIPasteboard generalPasteboard].image = qrCode;
}


- (IBAction) deleteBackward:(id)sender
{
    [self.textDocumentProxy deleteBackward];
}


- (IBAction) nextInputMode:(id)sender
{
    [self advanceToNextInputMode];
}


@end
