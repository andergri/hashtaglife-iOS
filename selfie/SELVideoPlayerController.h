//
//  SELVideoPlayerController.h
//  #life
//
//  Created by Griffin Anderson on 5/24/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SELVideoPlayerPlaybackState) {
    SELVideoPlayerPlaybackStateStopped = 0,
    SELVideoPlayerPlaybackStatePlaying,
    SELVideoPlayerPlaybackStatePaused,
    SELVideoPlayerPlaybackStateFailed,
};

typedef NS_ENUM(NSInteger, SELVideoPlayerBufferingState) {
    SELVideoPlayerBufferingStateUnknown = 0,
    SELVideoPlayerBufferingStateReady,
    SELVideoPlayerBufferingStateDelayed,
};

@protocol SELVideoPlayerControllerDelegate;

@interface SELVideoPlayerController : UIViewController

@property (nonatomic, weak) id<SELVideoPlayerControllerDelegate> delegate;
@property (nonatomic, copy) NSString *videoPath;
@property (nonatomic, copy) NSString *videoFillMode;
@property (nonatomic) BOOL playbackLoops;
@property (nonatomic) BOOL playbackFreezesAtEnd;
@property (nonatomic, readonly) SELVideoPlayerPlaybackState playbackState;
@property (nonatomic, readonly) SELVideoPlayerBufferingState bufferingState;
@property (nonatomic, readonly) NSTimeInterval maxDuration;

- (void)playFromBeginning;
- (void)playFromCurrentTime;
- (void)pause;
- (void)stop;

@end

@protocol SELVideoPlayerControllerDelegate <NSObject>

@required
- (void)videoPlayerReady:(SELVideoPlayerController *)videoPlayer;
- (void)videoPlayerPlaybackStateDidChange:(SELVideoPlayerController *)videoPlayer;
- (void)videoPlayerPlaybackWillStartFromBeginning:(SELVideoPlayerController *)videoPlayer;
- (void)videoPlayerPlaybackDidEnd:(SELVideoPlayerController *)videoPlayer;
@optional
- (void)videoPlayerBufferringStateDidChange:(SELVideoPlayerController *)videoPlayer;

@end
