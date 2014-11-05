//
//  UIImage+ResizedImage.h
//  Holla Back
//
//  Created by Dan Treiman on 11/1/14.
//  Copyright (c) 2014 Only The Best. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ResizedImage)


- (UIImage *) scaledImageWithQuality:(CGInterpolationQuality)quality
                         scaleFactor:(CGFloat)scaleFactor;

- (UIImage *) scaledImageWithQuality:(CGInterpolationQuality)quality
                                size:(CGSize)size;


@end
