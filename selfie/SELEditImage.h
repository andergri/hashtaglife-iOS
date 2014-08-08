//
//  SELEditImage.h
//  selfie
//
//  Created by Griffin Anderson on 7/23/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SELEditImage : NSObject

+(UIImage *) scaleAndRotateImage:(UIImage *)image size:(CGSize)size;
+ (UIImage *) cropImage: (UIImage *) originalImage size:(CGSize)size;

@end
