//
//  SELContentManger.h
//  #life
//
//  Created by Griffin Anderson on 5/26/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SELSelfieContentDirection) {
    SELSelfieDirectionForward = 0,
    SELSelfieDirectionBackward,
    SELSelfieDirectionExit,
};

typedef NS_ENUM(NSInteger, SELSelfieContentType) {
    SELSelfieContentTypeVideo = 0,
    SELSelfieContentTypeImage,
    SELSelfieContentTypeError,
};

@protocol SELContentMangerDelegate <NSObject>

- (void) selfiesLoaded:(NSMutableArray*)selfies;
- (void) hideViewer;
- (void) directionChanged:(NSUInteger)index;

@end

@interface SELContentManger : NSObject

- (void) initWithSelfies:(NSArray*)loadselfies;
- (void) moveToDirection:(SELSelfieContentDirection)direction;
- (PFObject *) getCurrentSelfie;
- (SELSelfieContentType) getCurrentSelfieType;
- (void) selfieFailedToLoad:(PFObject *)selfie;

@property (nonatomic) id<SELContentMangerDelegate> delegate;

@end
