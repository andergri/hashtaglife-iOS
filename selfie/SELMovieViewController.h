//
//  SELMovieViewController.h
//  #life
//
//  Created by Griffin Anderson on 5/27/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SELMoviePlayerViewController.h"

typedef NS_ENUM(NSInteger, SELMoviePlayerPlaybackState) {
    SELMoviePlayerPlaybackStateNew = 0,
    SELMoviePlayerPlaybackStatePlaying = 1,
    SELMoviePlayerPlaybackStateBuffering = 2,
    SELMoviePlayerPlaybackStateFailed = 3
};

@protocol SELMovieViewControllerDelegate <NSObject>
@optional
- (void)moviePlayerPlaybackStateChanged:(SELMoviePlayerPlaybackState)moviePlayerPlaybackState;
@end

@interface SELMovieViewController : UIViewController <SELMoviePlayerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;

@property (nonatomic) id<SELMovieViewControllerDelegate> delegate;
- (void) loadVideos:(NSMutableArray*)selfies;
- (void)playAtIndex:(int)index;
- (void)cancel;
- (void)pause;
- (void)play;
- (SELMoviePlayerPlaybackState) getMoviePlayerPlaybackState;

@end
