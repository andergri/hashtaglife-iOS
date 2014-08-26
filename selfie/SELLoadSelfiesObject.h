//
//  SELLoadSelfiesObject.h
//  #life
//
//  Created by Griffin Anderson on 8/20/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SELFlagObject.h"
#import "SELHeartObject.h"
#import "SELImageCountObject.h"

@interface SELLoadSelfiesObject : NSObject

@property NSMutableArray *aselfies;
@property NSMutableArray *aselfiesImages;
@property NSInteger selfiesCounter;

- (void) initDefault:(UIView*)popView imageView:(UIImageView*)imageView flag:(SELFlagObject *)flag heart:(SELHeartObject *)heart imagCount:(SELImageCountObject*)imageCount tap:(UITapGestureRecognizer *)tgr alertTap:(UITapGestureRecognizer *)alertTgr vc:(UIViewController *)vc;
- (void) loadHashtag:(NSString *)hashtag color:(UIColor *)acolor;
- (void) loadUserPhotos:(UIColor *)acolor;
- (void) showPopup;
- (void) hidePopup;
- (void) tapFlag;
- (void) tapHeart;
- (void) loadNextImage;

@end
