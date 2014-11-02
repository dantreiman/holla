//
//  UIImage+QRCodes.m
//  Holla Back
//
//  Created by Dan Treiman on 11/1/14.
//  Copyright (c) 2014 Only The Best. All rights reserved.
//

#import "UIImage+QRCodes.h"
#import "UIImage+ResizedImage.h"

@implementation UIImage (QRCodes)


+ (UIImage *) imageWithCode:(NSData *)data
{
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    //    NSLog(@"filterAttributes:%@", filter.attributes);
    [filter setDefaults];
    [filter setValue:data forKey:@"inputMessage"];

    CIImage * outputImage = [filter outputImage];

    CIContext * context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputImage
                                       fromRect:[outputImage extent]];

    UIImage *image = [UIImage imageWithCGImage:cgImage
                                         scale:1.
                                   orientation:UIImageOrientationUp];

    // Resize without interpolating
    UIImage *resized = [image scaledImageWithQuality:kCGInterpolationNone
                                         scaleFactor:5.0];
    CGImageRelease(cgImage);
    return resized;
}


@end
