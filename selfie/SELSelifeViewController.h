//
//  SELSelifeViewController.h
//  #life
//
//  Created by Griffin Anderson on 3/21/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SELColorPicker.h"
#import "SELLoadContent.h"
#import "SELContentManger.h"
#import "SELImageLoader.h"
#import "SELProgressManger.h"
#import "SELOverlayViewController.h"
#import "SELPictureViewController.h"
#import "SELMovieViewController.h"
#import "SELVotingOverlayViewController.h"
#import <TwitterKit/TwitterKit.h>

/**
typedef NS_ENUM(NSInteger, SELSelfieContent) {
    SELSelifePopular = 0,
    SELSelifeRecent,
    SELSelifeHashtag,
    SELSelifePhotos,
};**/

typedef NS_ENUM(NSInteger, SELSelfieLoadContent) {
    SELSelifePopular = 0,
    SELSelifeRecent = 1,
    SELSelifeHashtag = 2,
    SELSelifePhotos = 3,
    SELSelifeObject = 4,
};

@interface SELSelifeViewController : UIViewController <UIGestureRecognizerDelegate, SELLoadContentDelegate, SELContentMangerDelegate, SELProgressMangerDelegate,
    SELOverlayViewControllerDelegate, SELPictureViewControllerDelegate, SELImageLoaderDelegate, SELMovieViewControllerDelegate, TWTRComposerViewControllerDelegate>


// Init
- (id) initWithColor:(SELColorPicker *)acolor;

// Show Selfies
- (void) showSelfies:(SELSelfieLoadContent)selectingType hashtag:(NSString*)hashtag color:(UIColor*)acolor location:(BOOL)filtered objectId:(NSString*)objectId;
@end
