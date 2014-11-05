//
//  PastingImageView.m
//  Holla Back
//
//  Created by Dan Treiman on 11/1/14.
//  Copyright (c) 2014 Only The Best. All rights reserved.
//

#import "PastingImageView.h"


@interface PastingImageView()

@property (weak, nonatomic) UITapGestureRecognizer * tapRecognizer;

@end


@implementation PastingImageView


- (void) awakeFromNib
{
    [super awakeFromNib];
    self.userInteractionEnabled = YES;
    // Long press on image view shows paste menu
    UILongPressGestureRecognizer * longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self addGestureRecognizer:longPressRecognizer];
    
    UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tapRecognizer];
    tapRecognizer.enabled = NO;
    self.tapRecognizer = tapRecognizer;
}


- (BOOL) canPerformAction:(SEL) action withSender:(id)sender
{
    return (action == @selector(paste:));
}


- (BOOL) canBecomeFirstResponder
{
    return YES;
}


- (BOOL) becomeFirstResponder
{
    UIMenuController * menuController = [UIMenuController sharedMenuController];
    [menuController setTargetRect:self.bounds inView:self];
    [menuController setMenuVisible:YES animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuWillHide:)
                                                 name:UIMenuControllerWillHideMenuNotification
                                               object:nil];
    return [super becomeFirstResponder];
}


- (BOOL) resignFirstResponder
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
    return [super resignFirstResponder];
}


- (void) menuWillHide:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
    if (self.isFirstResponder) {
        [self resignFirstResponder];
    }
}


#pragma mark - Actions


- (void) handleLongPress:(UILongPressGestureRecognizer *)longPressRecognizer
{
    [self becomeFirstResponder];
    self.tapRecognizer.enabled = YES;
}


- (void) handleTap:(UITapGestureRecognizer *)tapRecognizer
{
    self.tapRecognizer.enabled = NO;
    if (self.isFirstResponder) {
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    }
}


- (void) paste:(id)sender
{
    UIPasteboard * pasteboard = [UIPasteboard generalPasteboard];
    UIImage * image = pasteboard.image;
    if (image) {
        self.image = image;
    }
    [self resignFirstResponder];
}


@end
