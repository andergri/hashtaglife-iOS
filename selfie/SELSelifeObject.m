//
//  SELSelifeObject.m
//  #life
//
//  Created by Griffin Anderson on 9/5/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import "SELSelifeObject.h"

@interface SELSelifeObject ()

@property BOOL imageLoaded;
@property BOOL imageError;
@property (nonatomic)  float imageProgress;

@end

@implementation SELSelifeObject

@synthesize selfie;
@synthesize image;
@synthesize imageError;
@synthesize imageLoaded;
@synthesize imageProgress;

- (SELSelifeObject*) createSelife:(PFObject*)aselfie{

    imageProgress = 0.00;
    imageLoaded = NO;
    imageError = NO;
    image = nil;
    selfie = aselfie;
    [self loadImage];
    
    return self;
}

- (void) loadImage {
    PFFile *imageFile = selfie[@"image"];
    if (imageFile) {
        [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                image = [UIImage imageWithData:imageData];
                imageLoaded = YES;
                imageError = NO;
            }else{
                imageLoaded = NO;
                imageError = YES;
            }
        } progressBlock:^(int percentDone) {
            imageProgress =  percentDone / 100.0;
        }];
    }
}

// Image public
- (BOOL) isImageLoaded{
    return imageLoaded;
}
- (BOOL) isImageError{
    return imageError;
}
- (float) imageProgress {
    return imageProgress;
}

@end
