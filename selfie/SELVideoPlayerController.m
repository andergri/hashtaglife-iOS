//
//  SELVideoPlayerController.m
//  #life
//
//  Created by Griffin Anderson on 5/24/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import "SELVideoPlayerController.h"
#import "SELVideoView.h"
#import <AVFoundation/AVFoundation.h>

#define LOG_PLAYER 0
#ifndef DLog
#if !defined(NDEBUG) && LOG_PLAYER
#   define DLog(fmt, ...) NSLog((@"player: " fmt), ##__VA_ARGS__);
#else
#   define DLog(...)
#endif
#endif

// KVO contexts
static NSString * const SELVideoPlayerObserverContext = @"SELVideoPlayerObserverContext";
static NSString * const SELVideoPlayerItemObserverContext = @"SELVideoPlayerItemObserverContext";
static NSString * const SELVideoPlayerLayerObserverContext = @"SELVideoPlayerLayerObserverContext";

// KVO player keys
static NSString * const SELVideoPlayerControllerTracksKey = @"tracks";
static NSString * const SELVideoPlayerControllerPlayableKey = @"playable";
static NSString * const SELVideoPlayerControllerDurationKey = @"duration";
static NSString * const SELVideoPlayerControllerRateKey = @"rate";

// KVO player item keys
static NSString * const SELVideoPlayerControllerStatusKey = @"status";
static NSString * const SELVideoPlayerControllerEmptyBufferKey = @"playbackBufferEmpty";
static NSString * const SELVideoPlayerControllerPlayerKeepUpKey = @"playbackLikelyToKeepUp";

// KVO player layer keys
static NSString * const SELVideoPlayerControllerReadyForDisplay = @"readyForDisplay";

@interface SELVideoPlayerController () <
UIGestureRecognizerDelegate>
{
    AVAsset *_asset;
    AVPlayer *_player;
    AVPlayerItem *_playerItem;
    
    NSString *_videoPath;
    SELVideoView *_videoView;
    
    SELVideoPlayerPlaybackState _playbackState;
    SELVideoPlayerBufferingState _bufferingState;
    
    // flags
    struct {
        unsigned int playbackLoops:1;
        unsigned int playbackFreezesAtEnd:1;
    } __block _flags;
}

@end

@implementation SELVideoPlayerController

@synthesize delegate = _delegate;
@synthesize videoPath = _videoPath;
@synthesize playbackState = _playbackState;
@synthesize bufferingState = _bufferingState;
@synthesize videoFillMode = _videoFillMode;

#pragma mark - getters/setters

- (void)setVideoFillMode:(NSString *)videoFillMode
{
    if (_videoFillMode != videoFillMode) {
        _videoFillMode = videoFillMode;
        _videoView.videoFillMode = _videoFillMode;
    }
}

- (NSString *)videoPath
{
    return _videoPath;
}

- (void)setVideoPath:(NSString *)videoPath
{
    if (!videoPath || [videoPath length] == 0)
        return;
    
    NSURL *videoURL = [NSURL URLWithString:videoPath];
    if (!videoURL || ![videoURL scheme]) {
        videoURL = [NSURL fileURLWithPath:videoPath];
    }
    _videoPath = [videoPath copy];
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    [self _setAsset:asset];
}

- (BOOL)playbackLoops
{
    return _flags.playbackLoops;
}

- (void)setPlaybackLoops:(BOOL)playbackLoops
{
    _flags.playbackLoops = (unsigned int)playbackLoops;
    if (!_player)
        return;
    
    if (!_flags.playbackLoops) {
        _player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    } else {
        _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    }
}

- (BOOL)playbackFreezesAtEnd
{
    return _flags.playbackFreezesAtEnd;
}

- (void)setPlaybackFreezesAtEnd:(BOOL)playbackFreezesAtEnd
{
    _flags.playbackFreezesAtEnd = (unsigned int)playbackFreezesAtEnd;
}

- (NSTimeInterval)maxDuration {
    NSTimeInterval maxDuration = -1;
    
    if (CMTIME_IS_NUMERIC(_playerItem.duration)) {
        maxDuration = CMTimeGetSeconds(_playerItem.duration);
    }
    
    return maxDuration;
}

- (void)_setAsset:(AVAsset *)asset
{
    if (_asset == asset)
        return;
    
    if (_playbackState == SELVideoPlayerPlaybackStatePlaying) {
        [self pause];
    }
    
    _bufferingState = SELVideoPlayerBufferingStateUnknown;
    if ([_delegate respondsToSelector:@selector(videoPlayerBufferringStateDidChange:)]){
        [_delegate videoPlayerBufferringStateDidChange:self];
    }
    
    _asset = asset;
    
    if (!_asset) {
        [self _setPlayerItem:nil];
    }
    
    NSArray *keys = @[SELVideoPlayerControllerTracksKey, SELVideoPlayerControllerPlayableKey, SELVideoPlayerControllerDurationKey];
    
    [_asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        [self _enqueueBlockOnMainQueue:^{
            
            // check the keys
            for (NSString *key in keys) {
                NSError *error = nil;
                AVKeyValueStatus keyStatus = [asset statusOfValueForKey:key error:&error];
                if (keyStatus == AVKeyValueStatusFailed) {
                    _playbackState = SELVideoPlayerPlaybackStateFailed;
                    [_delegate videoPlayerPlaybackStateDidChange:self];
                    return;
                }
            }
            
            // check playable
            if (!_asset.playable) {
                _playbackState = SELVideoPlayerPlaybackStateFailed;
                [_delegate videoPlayerPlaybackStateDidChange:self];
                return;
            }
            
            // setup player
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:_asset];
            [self _setPlayerItem:playerItem];
            
        }];
    }];
}

- (void)_setPlayerItem:(AVPlayerItem *)playerItem
{
    if (_playerItem == playerItem)
        return;
    
    // remove observers
    if (_playerItem) {
        // AVPlayerItem KVO
        [_playerItem removeObserver:self forKeyPath:SELVideoPlayerControllerEmptyBufferKey context:(__bridge void *)(SELVideoPlayerItemObserverContext)];
        [_playerItem removeObserver:self forKeyPath:SELVideoPlayerControllerPlayerKeepUpKey context:(__bridge void *)(SELVideoPlayerItemObserverContext)];
        [_playerItem removeObserver:self forKeyPath:SELVideoPlayerControllerStatusKey context:(__bridge void *)(SELVideoPlayerItemObserverContext)];
        
        // notifications
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:_playerItem];
    }
    
    _playerItem = playerItem;
    
    // add observers
    if (_playerItem) {
        // AVPlayerItem KVO
        [_playerItem addObserver:self forKeyPath:SELVideoPlayerControllerEmptyBufferKey options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:(__bridge void *)(SELVideoPlayerItemObserverContext)];
        [_playerItem addObserver:self forKeyPath:SELVideoPlayerControllerPlayerKeepUpKey options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:(__bridge void *)(SELVideoPlayerItemObserverContext)];
        [_playerItem addObserver:self forKeyPath:SELVideoPlayerControllerStatusKey options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:(__bridge void *)(SELVideoPlayerItemObserverContext)];
        
        // notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_playerItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_playerItemFailedToPlayToEndTime:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:_playerItem];
    }
    
    if (!_flags.playbackLoops) {
        _player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    } else {
        _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    }
    
    [_player replaceCurrentItemWithPlayerItem:_playerItem];
}

#pragma mark - init

- (void)dealloc {
    _videoView.player = nil;
    _delegate = nil;
    
    // notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Layer KVO
    [_videoView.layer removeObserver:self forKeyPath:SELVideoPlayerControllerReadyForDisplay context:(__bridge void *)SELVideoPlayerLayerObserverContext];
    
    // AVPlayer KVO
    [_player removeObserver:self forKeyPath:SELVideoPlayerControllerRateKey context:(__bridge void *)SELVideoPlayerObserverContext];
    
    // player
    [_player pause];
    
    // player item
    [self _setPlayerItem:nil];
}

#pragma mark - view lifecycle

- (void)loadView
{
    _player = [[AVPlayer alloc] init];
    _player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    
    // Player KVO
    [_player addObserver:self forKeyPath:SELVideoPlayerControllerRateKey options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:(__bridge void *)(SELVideoPlayerObserverContext)];
    
    // load the playerLayer view
    _videoView = [[SELVideoView alloc] initWithFrame:CGRectZero];
    _videoView.videoFillMode = AVLayerVideoGravityResizeAspect;
    _videoView.playerLayer.hidden = YES;
    self.view = _videoView;
    
    // playerLayer KVO
    [_videoView.playerLayer addObserver:self forKeyPath:SELVideoPlayerControllerReadyForDisplay options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:(__bridge void *)(SELVideoPlayerLayerObserverContext)];
    
    // Application NSNotifications
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(_applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [nc addObserver:self selector:@selector(_applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (_playbackState == SELVideoPlayerPlaybackStatePlaying)
        [self pause];
}

#pragma mark - private methods

- (void)_videoPlayerAudioSessionActive:(BOOL)active
{
    NSString *category = active ? AVAudioSessionCategoryPlayback : AVAudioSessionCategoryAmbient;
    
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:category error:&error];
    if (error) {
        DLog(@"audio session active error (%@)", error);
    }
}

- (void)_updatePlayerRatio
{
}

#pragma mark - public methods

- (void)playFromBeginning
{
    DLog(@"playing from beginnging...");
    
    [_delegate videoPlayerPlaybackWillStartFromBeginning:self];
    [_player seekToTime:kCMTimeZero];
    [self playFromCurrentTime];
}

- (void)playFromCurrentTime
{
    DLog(@"playing...");
    
    _playbackState = SELVideoPlayerPlaybackStatePlaying;
    [_delegate videoPlayerPlaybackStateDidChange:self];
    [_player play];
}

- (void)pause
{
    if (_playbackState != SELVideoPlayerPlaybackStatePlaying)
        return;
    
    DLog(@"pause");
    
    [_player pause];
    _playbackState = SELVideoPlayerPlaybackStatePaused;
    [_delegate videoPlayerPlaybackStateDidChange:self];
}

- (void)stop
{
    if (_playbackState == SELVideoPlayerPlaybackStateStopped)
        return;
    
    DLog(@"stop");
    
    [_player pause];
    _playbackState = SELVideoPlayerPlaybackStateStopped;
    [_delegate videoPlayerPlaybackStateDidChange:self];
}

#pragma mark - main queue helper

typedef void (^SELVideoPlayerBlock)();

- (void)_enqueueBlockOnMainQueue:(SELVideoPlayerBlock)block {
    dispatch_async(dispatch_get_main_queue(), ^{
        block();
    });
}

#pragma mark - UIResponder

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_videoPath) {
        
        switch (_playbackState) {
            case SELVideoPlayerPlaybackStateStopped:
            {
                [self playFromBeginning];
                break;
            }
            case SELVideoPlayerPlaybackStatePaused:
            {
                [self playFromCurrentTime];
                break;
            }
            case SELVideoPlayerPlaybackStatePlaying:
            case SELVideoPlayerPlaybackStateFailed:
            default:
            {
                [self pause];
                break;
            }
        }
        
    } else {
        [super touchesEnded:touches withEvent:event];
    }
    
}

- (void)_handleTap:(UIGestureRecognizer *)gestureRecognizer
{
    if (_playbackState == SELVideoPlayerPlaybackStatePlaying) {
        [self pause];
    } else if (_playbackState == SELVideoPlayerPlaybackStateStopped) {
        [self playFromBeginning];
    } else {
        [self playFromCurrentTime];
    }
}

#pragma mark - AV NSNotificaions

- (void)_playerItemDidPlayToEndTime:(NSNotification *)aNotification
{
    if (_flags.playbackLoops || !_flags.playbackFreezesAtEnd) {
        [_player seekToTime:kCMTimeZero];
    }
    
    if (!_flags.playbackLoops) {
        [self stop];
        [_delegate videoPlayerPlaybackDidEnd:self];
    }
}

- (void)_playerItemFailedToPlayToEndTime:(NSNotification *)aNotification
{
    _playbackState = SELVideoPlayerPlaybackStateFailed;
    [_delegate videoPlayerPlaybackStateDidChange:self];
    DLog(@"error (%@)", [[aNotification userInfo] objectForKey:AVPlayerItemFailedToPlayToEndTimeErrorKey]);
}

#pragma mark - App NSNotifications

- (void)_applicationWillResignActive:(NSNotification *)aNotfication
{
    if (_playbackState == SELVideoPlayerPlaybackStatePlaying)
        [self pause];
}

- (void)_applicationDidEnterBackground:(NSNotification *)aNotfication
{
    if (_playbackState == SELVideoPlayerPlaybackStatePlaying)
        [self pause];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( context == (__bridge void *)(SELVideoPlayerObserverContext) ) {
        
        // Player KVO
        
    } else if ( context == (__bridge void *)(SELVideoPlayerItemObserverContext) ) {
        
        // PlayerItem KVO
        
        if ([keyPath isEqualToString:SELVideoPlayerControllerEmptyBufferKey]) {
            if (_playerItem.playbackBufferEmpty) {
                _bufferingState = SELVideoPlayerBufferingStateDelayed;
                if ([_delegate respondsToSelector:@selector(videoPlayerBufferringStateDidChange:)]) {
                    [_delegate videoPlayerBufferringStateDidChange:self];
                }
                DLog(@"playback buffer is empty");
            }
        } else if ([keyPath isEqualToString:SELVideoPlayerControllerPlayerKeepUpKey]) {
            if (_playerItem.playbackLikelyToKeepUp) {
                _bufferingState = SELVideoPlayerBufferingStateReady;
                if ([_delegate respondsToSelector:@selector(videoPlayerBufferringStateDidChange:)]) {
                    [_delegate videoPlayerBufferringStateDidChange:self];
                }
                DLog(@"playback buffer is likely to keep up");
                if (_playbackState == SELVideoPlayerPlaybackStatePlaying) {
                    [self playFromCurrentTime];
                }
            }
        }
        
        AVPlayerStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
            case AVPlayerStatusReadyToPlay:
            {
                _videoView.playerLayer.backgroundColor = [[UIColor blackColor] CGColor];
                [_videoView.playerLayer setPlayer:_player];
                _videoView.playerLayer.hidden = NO;
                break;
            }
            case AVPlayerStatusFailed:
            {
                _playbackState = SELVideoPlayerPlaybackStateFailed;
                [_delegate videoPlayerPlaybackStateDidChange:self];
                break;
            }
            case AVPlayerStatusUnknown:
            default:
                break;
        }
        
    } else if ( context == (__bridge void *)(SELVideoPlayerLayerObserverContext) ) {
        
        // PlayerLayer KVO
        
        if ([keyPath isEqualToString:SELVideoPlayerControllerReadyForDisplay]) {
            if (_videoView.playerLayer.readyForDisplay) {
                [_delegate videoPlayerReady:self];
            }
        }
        
    } else {
        
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        
    }
}

@end
