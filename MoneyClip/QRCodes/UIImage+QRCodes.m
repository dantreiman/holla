//
//  UIImage+QRCodes.m
//  MoneyClip

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


- (UIImage *) imageByWatermarkingWithCode:(UIImage *)code
{
    CGImageRef imageRef = [self CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char * rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    unsigned char * codeRawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    unsigned char * newRawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextRef codeContext = CGBitmapContextCreate(codeRawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);

    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    CGContextDrawImage(codeContext, CGRectMake(0, 0, width, height), code.CGImage);
    CGContextRelease(codeContext);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            unsigned long byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
            unsigned char red   = rawData[byteIndex];
            unsigned char green = rawData[byteIndex + 1];
            unsigned char blue  = rawData[byteIndex + 2];
            unsigned char alpha = rawData[byteIndex + 3];
            
            unsigned char code = codeRawData[byteIndex];
            
            unsigned char value = (code > 100) ? 1 : 0;
            if (value) {
                newRawData[byteIndex] = red | 1;
            }
            else {
                newRawData[byteIndex] = red & 254;
            }
            newRawData[byteIndex + 1] = green;
            newRawData[byteIndex + 2] = blue;
            newRawData[byteIndex + 3] = alpha;
        }
    }
    
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL,
                                                              newRawData,
                                                              width * height * 4,
                                                              NULL);
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef newImageRef = CGImageCreate(width,
                                           height,
                                           8,
                                           32,
                                           4*width,colorSpaceRef,
                                           bitmapInfo,
                                           provider,NULL,NO,renderingIntent);
    /*I get the current dimensions displayed here */
    //NSLog(@"width=%fd, height: %d", CGImageGetWidth(newImageRef),
    //      CGImageGetHeight(newImageRef) );
    UIImage * newImage = [UIImage imageWithCGImage:newImageRef];
    
    free(rawData);
    free(codeRawData);
    return newImage;
}


- (UIImage *) watermarkFromImage
{
    CGImageRef imageRef = [self CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char * rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    unsigned char * newRawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            unsigned long byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
            unsigned char red   = rawData[byteIndex];
//            unsigned char green = rawData[byteIndex] + 1;
//            unsigned char blue  = rawData[byteIndex + 2];
//            unsigned char alpha = rawData[byteIndex + 3];
            unsigned char value = red & 1 ? 255 : 0;
            newRawData[byteIndex] = value;
            newRawData[byteIndex + 1] = value;
            newRawData[byteIndex + 2] = value;
            newRawData[byteIndex + 3] = 1;
        }
    }
    
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL,
                                                              newRawData,
                                                              width * height * 4,
                                                              NULL);
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef newImageRef = CGImageCreate(width,
                                        height,
                                        8,
                                        32,
                                        4*width,colorSpaceRef,
                                        bitmapInfo,
                                        provider,NULL,NO,renderingIntent);
    /*I get the current dimensions displayed here */
    //NSLog(@"width=%fd, height: %d", CGImageGetWidth(newImageRef),
    //      CGImageGetHeight(newImageRef) );
    UIImage * newImage = [UIImage imageWithCGImage:newImageRef];
    
    free(rawData);
    return newImage;
}



@end
