//
//  SELImageLoader.h
//  #life
//
//  Created by Griffin Anderson on 5/26/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SELSelfieImageLoadingState) {
    SELSelfieImageLoadingStateUnknown = 0,
    SELSelfieImageLoadingStateReady,
    SELSelfieImageLoadingStateFailed,
    SELSelfieImageLoadingStateBuffering,
};

typedef NS_ENUM(NSInteger, SELSelfieImageStatus) {
    SELSelfieImageStatusUnknown = 0,
    SELSelfieImageStatusSuccessus,
    SELSelfieImageStatusFailed,
    SELSelfieImageStatusBuffering,
};

@protocol SELImageLoaderDelegate <NSObject>

- (void) selfieFailedToLoad:(PFObject*)selfie;

@end

@interface SELImageLoader : NSObject

- (void) loadSelfies:(NSMutableArray*)selfies;
- (SELSelfieImageLoadingState) loadingState;
- (NSInteger) loadingProgress;

- (SELSelfieImageStatus) imageStatusFor:(int)index;
- (UIImage*) getImageAt:(int)index;

@property (nonatomic) id<SELImageLoaderDelegate> delegate;

@end
