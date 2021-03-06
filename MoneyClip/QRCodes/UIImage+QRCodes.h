//
//  UIImage+QRCodes.h
//  MoneyClip

//
//  Created by Dan Treiman on 11/1/14.
//  Copyright (c) 2014 Only The Best. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (QRCodes)


/**
 * @return An image which is a QR code containing the specified data.
 */
+ (UIImage *) imageWithCode:(NSData *)data;


/**
 * @return The data in a QR code image, or nil.
 */
- (NSData *) codeExtractedFromImage;


/**
 * @return an image by adding a LSB watermark.
 */
- (UIImage *) imageByWatermarkingWithCode:(UIImage *)code;


/**
 * @return an image by extracting an LSB watermark
 */
- (UIImage *) watermarkFromImage;


@end
