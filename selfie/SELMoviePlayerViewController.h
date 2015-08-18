//
//  SELMoviePlayerViewController.h
//  #life
//
//  Created by Griffin Anderson on 5/27/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SELVideoView.h"
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, SELVideoPlayerPlaybackState) {
    SELVideoPlayerPlaybackStateStopped = 0,
    SELVideoPlayerPlaybackStatePlaying,
    SELVideoPlayerPlaybackStatePaused,
    SELVideoPlayerPlaybackStateFailed,
};

typedef NS_ENUM(NSUInteger, SELVideoPlayerReadyToPlay) {
    SELVideoPlayerReadyToPlayPlayer = 3000,
    SELVideoPlayerReadyToPlayCurrentItem = 3001,
};

typedef NS_ENUM(NSUInteger, SELVideoPlayerFailed) {
    SELVideoPlayerFailedPlayer = 4000,
    SELVideoPlayerFailedCurrentItem = 4001,
};

// Delegate

@protocol SELMoviePlayerDelegate <NSObject>
@optional

- (void)SELVideoPlayerCurrentItemPreloaded:(CMTime)time;
- (void)SELVideoPlayerCurrentItemChanged:(AVPlayerItem *)item;
- (void)SELVideoPlayerRateChanged:(BOOL)isPlaying;
- (void)SELVideoPlayerDidFailed:(SELVideoPlayerFailed)identifier error:(NSError *)error;
- (void)SELVideoPlayerReadyToPlay:(SELVideoPlayerReadyToPlay)identifier;
- (void)SELVIdeoPlayerPlayerItemErrorAt:(NSUInteger)index;
- (void)SELVideoPlayerPlayerItemBuffering:(BOOL)buffering;
@end

@interface SELMoviePlayerViewController : UIViewController

@property (nonatomic) NSUInteger itemsCount;

// Delegate
@property (nonatomic) id<SELMoviePlayerDelegate> delegate;

// Setup //
- (void)setupUrl:(NSURL *)url index:(NSUInteger)index;
- (void)playItem:(NSUInteger)index;
- (void)removeItems;

// Controls //
- (AVPlayerItem *)getCurrentItem;
- (void)play;
- (void)pause;
- (void)mute;

// Player //
- (BOOL)isPlaying;
- (SELVideoPlayerPlaybackState)getSELVideoPlayerStatus;
- (float)getPlayingItemCurrentTime;
- (float)getPlayingItemDurationTime;
- (id)addPeriodicTimeObserverForInterval:(CMTime)interval
                                   queue:(dispatch_queue_t)queue
                              usingBlock:(void (^)(CMTime time))block;

@end
