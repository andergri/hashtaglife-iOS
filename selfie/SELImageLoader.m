//
//  SELImageLoader.m
//  #life
//
//  Created by Griffin Anderson on 5/26/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import "SELImageLoader.h"
#import "SELSelifeObject.h"

@interface SELImageLoader ()

@property SELSelfieImageLoadingState currentLoadingState;
@property NSMutableArray *selfiesList;

@end

@implementation SELImageLoader

@synthesize delegate;
@synthesize currentLoadingState;
@synthesize selfiesList;

- (void) loadSelfies:(NSMutableArray*)selfies{
    
    selfiesList = [[NSMutableArray alloc] init];
    currentLoadingState = SELSelfieImageLoadingStateUnknown;
    if (selfies.count > 0) {
        for (PFObject *selfie in selfies) {
            SELSelifeObject* selfObj = [[SELSelifeObject alloc] createSelife:selfie];
            [selfiesList addObject:selfObj];
        }
    }
}
- (SELSelfieImageLoadingState) loadingState{
    return currentLoadingState;
}

- (NSInteger) loadingProgress{
    NSInteger currentProgress = 0;
    for (int i = 0; i < selfiesList.count; i++) {
        currentProgress += [self loadingProgressFor:i];
    }
    if (currentProgress == selfiesList.count)
        currentLoadingState = SELSelfieImageLoadingStateReady;
    if (currentProgress == 0.0)
        currentLoadingState = SELSelfieImageLoadingStateUnknown;
    if (currentProgress < selfiesList.count)
        currentLoadingState = SELSelfieImageLoadingStateBuffering;
    return currentProgress;
}

- (SELSelfieImageStatus) imageStatusFor:(int)index{
    SELSelifeObject* selfObj = [selfiesList objectAtIndex:index];
    if ([selfObj isImageLoaded])
        return SELSelfieImageStatusSuccessus;
    if ([selfObj isImageError])
        return SELSelfieImageStatusFailed;
    if (![selfObj isImageLoaded] && ![selfObj isImageError]){
        return SELSelfieImageStatusBuffering;
    }else{
        return SELSelfieImageStatusUnknown;
    }
}

- (UIImage*) getImageAt:(int)index{
    
    SELSelifeObject* selfObj = [selfiesList objectAtIndex:index];
    if ([self imageStatusFor:index] == SELSelfieImageStatusSuccessus && selfObj) {
        return selfObj.image;
    }
    return  nil;
}

#pragma  - private methods

- (NSInteger) loadingProgressFor:(int)index{
    SELSelifeObject* selfObj = [selfiesList objectAtIndex:index];
    if ([self imageStatusFor:index] == SELSelfieImageStatusSuccessus && selfObj) {
        return 1;
    }
    if ([self imageStatusFor:index] == SELSelfieImageStatusFailed && selfObj) {
        [self.delegate selfieFailedToLoad:selfObj.selfie];
        return 1;
    }
    if ([self imageStatusFor:index] == SELSelfieImageStatusBuffering && selfObj) {
        return  0;
    }
    return  0;
}

@end
