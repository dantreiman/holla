//
//  UIImage+QRCodes.m
//  Holla Back
//
//  Created by Dan Treiman on 11/1/14.
//  Copyright (c) 2014 Only The Best. All rights reserved.
//

#import "UIImage+QRCodes.h"
#import "UIImage+ResizedImage.h"
#import "ZBarSDK.h"


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


- (NSData *) codeExtractedFromImage
{
    ZBarImageScanner * scanner = [[ZBarImageScanner alloc] init];
    [scanner setSymbology: 0
                   config: ZBAR_CFG_X_DENSITY
                       to: 2];
    [scanner setSymbology: 0
                   config: ZBAR_CFG_Y_DENSITY
                       to: 2];
    ZBarImage * image = [[ZBarImage alloc] initWithCGImage:self.CGImage];
    [scanner scanImage:image];
    ZBarSymbolSet * symbols = scanner.results;
    NSData * data = nil;
    for (ZBarSymbol * symbol in symbols) {
        NSString * string = symbol.data;
        data = [string dataUsingEncoding:NSUTF8StringEncoding];
    }
    return data;
}


@end
