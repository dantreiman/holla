//
//  UIImage+ResizedImage.m
//  Holla Back
//
//  Created by Dan Treiman on 11/1/14.
//  Copyright (c) 2014 Only The Best. All rights reserved.
//

#import "UIImage+ResizedImage.h"

@implementation UIImage (ResizedImage)


- (UIImage *) scaledImageWithQuality:(CGInterpolationQuality)quality
                         scaleFactor:(CGFloat)scaleFactor
{
    UIImage * resized = nil;
    CGFloat width = self.size.width * scaleFactor;
    CGFloat height = self.size.height * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, quality);
    [self drawInRect:CGRectMake(0, 0, width, height)];
    resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resized;
}

@end
