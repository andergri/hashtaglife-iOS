//
//  SELEditImage.m
//  selfie
//
//  Created by Griffin Anderson on 7/23/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import "SELEditImage.h"

@implementation SELEditImage



+ (UIImage *) cropImage: (UIImage *) originalImage size:(CGSize)size{
    
    NSLog(@"origImg %f", originalImage.size.width);
    NSLog(@"origImg %f", originalImage.size.height);
    
    CGRect cropRect = CGRectMake(0, 0, size.width, size.height);

    CGRect transformedRect = [self TransformCGRectForUIImageOrientation:cropRect sourcea:originalImage.imageOrientation image:originalImage.size];
    
    CGImageRef resultImageRef = CGImageCreateWithImageInRect(originalImage.CGImage, transformedRect);
    
    UIImage *newImage = [[UIImage alloc] initWithCGImage:resultImageRef scale:1.0 orientation:originalImage.imageOrientation];
    
    return newImage;
}

+ (CGRect) TransformCGRectForUIImageOrientation: (CGRect)rect sourcea:(UIImageOrientation) orientation image:(CGSize)imageSize {
    
    switch (orientation) {
        case UIImageOrientationLeft: { // EXIF #8
            CGAffineTransform txTranslate = CGAffineTransformMakeTranslation(
                                                                             imageSize.height, 0.0);
            CGAffineTransform txCompound = CGAffineTransformRotate(txTranslate,
                                                                   M_PI_2);
            return CGRectApplyAffineTransform(rect, txCompound);
        }
        case UIImageOrientationDown: { // EXIF #3
            CGAffineTransform txTranslate = CGAffineTransformMakeTranslation(
                                                                             imageSize.width, imageSize.height);
            CGAffineTransform txCompound = CGAffineTransformRotate(txTranslate,
                                                                   M_PI);
            return CGRectApplyAffineTransform(rect, txCompound);
        }
        case UIImageOrientationRight: { // EXIF #6
            CGAffineTransform txTranslate = CGAffineTransformMakeTranslation(
                                                                             0.0, imageSize.width);
            CGAffineTransform txCompound = CGAffineTransformRotate(txTranslate,
                                                                   M_PI + M_PI_2);
            return CGRectApplyAffineTransform(rect, txCompound);
        }
        case UIImageOrientationUp: // EXIF #1 - do nothing
        default: // EXIF 2,4,5,7 - ignore
            return rect;
    }
}


+(UIImage *) scaleAndRotateImage:(UIImage *)image size:(CGSize)size {
    
    int kMaxResolution = size.height; // Or whatever
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = (int)ceilf(bounds.size.height * ratio);
        }
    }else if(height < kMaxResolution){
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = (int)ceilf(bounds.size.height * ratio);
            bounds.size.height = kMaxResolution;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = (int)ceilf(bounds.size.height * ratio);
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    
  /**
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"A"
                                                      message:[NSString stringWithFormat:@"kMax %d w %f h %f || bounds w %f h %f scale %f", kMaxResolution, width, height, bounds.size.width, bounds.size.height, scaleRatio]
                                                     delegate:nil
                                            cancelButtonTitle:@"k"
                                            otherButtonTitles:nil];
    [message show];
    **/
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    
    switch(orient) {
        case UIImageOrientationUp: //EXIF = 0 -- photo left
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationUpMirrored:
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 1 -- photo right
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 2 -- photo down
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 3 -- photo normal
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
     
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGFloat bwidth = CGImageGetWidth(imageCopy.CGImage);
    CGFloat bheight = CGImageGetHeight(imageCopy.CGImage);
    //CGRect imageRect = CGRectMake(0, 0, imageCopy.size.width, imageCopy.size.height);
    
    if (bwidth > bheight) {
        
        CGImageRef imgRef = imageCopy.CGImage;
        
        CGFloat width = CGImageGetWidth(imgRef);
        CGFloat height = CGImageGetHeight(imgRef);
        
        
        CGAffineTransform transform = CGAffineTransformIdentity;
        CGRect bounds = CGRectMake(0, 0, width, height);
        if (width > kMaxResolution || height > kMaxResolution) {
            CGFloat ratio = width/height;
            if (ratio > 1) {
                bounds.size.width = kMaxResolution;
                bounds.size.height = bounds.size.width / ratio;
            }
            else {
                bounds.size.height = kMaxResolution;
                bounds.size.width = bounds.size.height * ratio;
            }
        }
        
        CGFloat scaleRatio = bounds.size.width / width;
        
        
        
        CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
        CGFloat boundHeight;
        UIImageOrientation orient = imageCopy.imageOrientation;
        

        boundHeight = bounds.size.height;
        bounds.size.height = bounds.size.width;
        bounds.size.width = boundHeight;
        transform = CGAffineTransformMakeTranslation(imageSize.height, -(imageSize.width / 3));
        transform = CGAffineTransformRotate(transform, M_PI / 2.0);
        
        UIGraphicsBeginImageContext(bounds.size);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        /**
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"b"
                                                          message:[NSString stringWithFormat:@"h %f bh %f w %f bw %f", height, bounds.size.height, width, bounds.size.width]
                                                         delegate:nil
                                                cancelButtonTitle:@"k"
                                                otherButtonTitles:nil];
        [message show];
        **/
        if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
            CGContextScaleCTM(context, -scaleRatio, scaleRatio);
            CGContextTranslateCTM(context, -(height ), 0);
        }
        else {
            CGContextScaleCTM(context, scaleRatio, -scaleRatio);
            CGContextTranslateCTM(context, 0, -(height + ( 59.0 - (height  - 320))));

        }
        
        CGContextConcatCTM(context, transform);
        
        CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
        imageCopy = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    }
    
    return imageCopy;
}

@end
