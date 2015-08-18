//
//  SELMoviePlayerViewController.m
//  #life
//
//  Created by Griffin Anderson on 5/27/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import "SELMoviePlayerViewController.h"
#import <objc/runtime.h>

static const void *Videotag = &Videotag;

// KVO contexts
static NSString * const SELVideoPlayerObserverContext = @"SELVideoPlayerObserverContext";
static NSString * const SELVideoPlayerItemObserverContext = @"SELVideoPlayerItemObserverContext";
static NSString * const SELVideoPlayerLayerObserverContext = @"SELVideoPlayerLayerObserverContext";

// KVO player keys
static NSString * const SELVideoPlayerControllerTracksKey = @"tracks";
static NSString * const SELVideoPlayerControllerPlayableKey = @"playable";
static NSString * const SELVideoPlayerControllerDurationKey = @"duration";
static NSString * const SELVideoPlayerControllerRateKey = @"rate";
static NSString * const SELVideoPlayerControllerCurrentItemKey = @"currentItem";

// KVO player item keys
static NSString * const SELVideoPlayerControllerStatusKey = @"status";
static NSString * const SELVideoPlayerControllerEmptyBufferKey = @"playbackBufferEmpty";
static NSString * const SELVideoPlayerControllerPlayerKeepUpKey = @"playbackLikelyToKeepUp";
static NSString * const SELVideoPlayerControllerPlayerTimeRangesKey = @"loadedTimeRanges";

// KVO player layer keys
static NSString * const SELVideoPlayerControllerReadyForDisplay = @"readyForDisplay";

@interface SELMoviePlayerViewController (){
    
    AVQueuePlayer *_queuePlayer;
    SELVideoView *_videoView;
    
    SELVideoPlayerPlaybackState _playbackState;
    
    NSUInteger prepareingItemHash;
}

@property (nonatomic, strong, readwrite) NSArray *playerItems;
@property (nonatomic, readwrite) BOOL isInEmptyVideo;
@property (nonatomic) NSUInteger lastItemIndex;
@property (nonatomic, strong) NSMutableSet *playedItems;

@end

@implementation SELMoviePlayerViewController

@synthesize delegate;

#pragma mark -
#pragma mark ===========  Runtime AssociatedObject  =========
#pragma mark -

- (void)setMovieIndex:(AVPlayerItem *)item Key:(NSNumber *)order {
    objc_setAssociatedObject(item, Videotag, order, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)getMovieIndex:(AVPlayerItem *)item {
    return objc_getAssociatedObject(item, Videotag);
}

#pragma mark -
#pragma mark ===========  Player Methods  =========
#pragma mark -

- (void)setupUrl:(NSURL *)url index:(NSUInteger)index {
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    if (!item)
        return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setMovieIndex:item Key:[NSNumber numberWithInteger:index]];
        NSMutableArray *playerItems = [NSMutableArray arrayWithArray:self.playerItems];
        [playerItems addObject:item];
        self.playerItems = playerItems;
        if ([_queuePlayer canInsertItem:item afterItem:nil]) {
            [_queuePlayer insertItem:item afterItem:nil];
        }
    });
}

- (void)playItem:(NSUInteger)index {
    self.lastItemIndex = index;
    [self.playedItems addObject:@(index)];
    [_queuePlayer pause];
    BOOL findInPlayerItems = NO;
    for (AVPlayerItem *item in self.playerItems) {
        NSInteger checkIndex = [[self getMovieIndex:item] integerValue];
        if (checkIndex == index) {
            [item seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
                if (_queuePlayer.currentItem != item) {
                    [_queuePlayer removeItem:item];
                    if ([_queuePlayer canInsertItem:item afterItem:_queuePlayer.currentItem]) {
                        [_queuePlayer insertItem:item afterItem:_queuePlayer.currentItem];
                    }
                    [_queuePlayer advanceToNextItem];
                }
            }];
            findInPlayerItems = YES;
        }
    }
    if (!findInPlayerItems) {
        //Delegate - Cant Find Player Item
        [self.delegate SELVIdeoPlayerPlayerItemErrorAt:index];
    } else if (_queuePlayer.currentItem.status == AVPlayerStatusReadyToPlay) {
        _queuePlayer.muted = NO;
        [_queuePlayer play];
    }
}

- (void)removeItems {
    for (AVPlayerItem *obj in _queuePlayer.items) {
        [obj seekToTime:kCMTimeZero];
        @try{
            // Deleage NEED TO DO //
            [obj removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
            [obj removeObserver:self forKeyPath:@"status" context:nil];
        }@catch(id anException){
            //do nothing, obviously it wasn't attached because an exception was thrown
        }
    }
    self.playerItems = nil;
    [_queuePlayer removeAllItems];
}



#pragma mark -
#pragma mark ===========  Player Methods  =========
#pragma mark -


- (AVPlayerItem *)getCurrentItem {
    return [_queuePlayer currentItem];
}

- (void)play {
    [_queuePlayer play];
}

- (void)pause {
    [_queuePlayer pause];
}

- (void)mute {
    _queuePlayer.muted = YES;
}

/** Play Item Duration **/

- (CMTime)playerItemDuration {
    NSError *err = nil;
    if ([_queuePlayer.currentItem.asset statusOfValueForKey:@"duration" error:&err] == AVKeyValueStatusLoaded) {
        AVPlayerItem *playerItem = [_queuePlayer currentItem];
        NSArray *loadedRanges = playerItem.seekableTimeRanges;
        if (loadedRanges.count > 0)
        {
            CMTimeRange range = [[loadedRanges objectAtIndex:0] CMTimeRangeValue];
            //Float64 duration = CMTimeGetSeconds(range.start) + CMTimeGetSeconds(range.duration);
            return (range.duration);
        }else {
            return (kCMTimeInvalid);
        }
    } else {
        return (kCMTimeInvalid);
    }
}

#pragma mark -
#pragma mark ===========  Player info  =========
#pragma mark -

- (BOOL)isPlaying {
    return [_queuePlayer rate] != 0.f;
}

- (SELVideoPlayerPlaybackState)getSELVideoPlayerStatus {
    return _playbackState;
}

- (float)getPlayingItemCurrentTime {
    CMTime itemCurrentTime = [[_queuePlayer currentItem] currentTime];
    float current = CMTimeGetSeconds(itemCurrentTime);
    if (CMTIME_IS_INVALID(itemCurrentTime) || !isfinite(current))
        return 0.0f;
    else
        return current;
}

- (float)getPlayingItemDurationTime {
    CMTime itemDurationTime = [self playerItemDuration];
    float duration = CMTimeGetSeconds(itemDurationTime);
    if (CMTIME_IS_INVALID(itemDurationTime) || !isfinite(duration))
        return 0.0f;
    else
        return duration;
}

- (id)addPeriodicTimeObserverForInterval:(CMTime)interval
                                   queue:(dispatch_queue_t)queue
                              usingBlock:(void (^)(CMTime time))block {
    id mTimeObserver = [_queuePlayer addPeriodicTimeObserverForInterval:interval queue:queue usingBlock:block];
    return mTimeObserver;
}


#pragma mark - ---
#pragma mark - ---
#pragma mark - ---
#pragma mark - ---


#pragma mark - view lifecycle

- (void)loadView
{
    _queuePlayer = [[AVQueuePlayer alloc] init];
    _queuePlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    _queuePlayer.muted = YES;
    
    // Player KVO
    [_queuePlayer addObserver:self forKeyPath:SELVideoPlayerControllerRateKey options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:(__bridge void *)(SELVideoPlayerObserverContext)];
    [_queuePlayer addObserver:self forKeyPath:SELVideoPlayerControllerStatusKey options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:(__bridge void *)(SELVideoPlayerObserverContext)];
    [_queuePlayer addObserver:self forKeyPath:SELVideoPlayerControllerCurrentItemKey options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:(__bridge void *)(SELVideoPlayerObserverContext)];
    
    // load the playerLayer view
    _videoView = [[SELVideoView alloc] initWithFrame:CGRectZero];
    _videoView.videoFillMode = AVLayerVideoGravityResizeAspectFill;
    _videoView.playerLayer.hidden = YES;
    self.view = _videoView;
    
    // playerLayer KVO
    [_videoView.playerLayer addObserver:self forKeyPath:SELVideoPlayerControllerReadyForDisplay options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:(__bridge void *)(SELVideoPlayerLayerObserverContext)];
    
    // Application notifications
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(_applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [nc addObserver:self selector:@selector(_applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    // Item notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_playerItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_playerItemFailedToPlayToEndTime:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (_playbackState == SELVideoPlayerPlaybackStatePlaying){
       // [self pause];
    }
}

#pragma mark - Item NSNotificaions

- (void)_playerItemDidPlayToEndTime:(NSNotification *)aNotification {
    
    AVPlayerItem *item = [aNotification object];
    if(![item isEqual:_queuePlayer.currentItem]){
        return;
    }
    
    NSNumber *CHECK_Order = [self getMovieIndex:_queuePlayer.currentItem];
    if (CHECK_Order) {
        NSInteger currentIndex = [CHECK_Order integerValue];
        [self playItem:currentIndex];
    }
}

- (void)_playerItemFailedToPlayToEndTime:(NSNotification *)aNotification {
    _playbackState = SELVideoPlayerPlaybackStateFailed;
    // Delegate the video did not play
}

#pragma mark - App NSNotifications

- (void)_applicationWillResignActive:(NSNotification *)aNotfication {
    if (_playbackState == SELVideoPlayerPlaybackStatePlaying){
        [self pause];
    }
}

- (void)_applicationDidEnterBackground:(NSNotification *)aNotfication {
    if (_playbackState == SELVideoPlayerPlaybackStatePlaying){
        [self pause];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(context == (__bridge void *)(SELVideoPlayerObserverContext)) {
        
        // Player KVO
        if ([keyPath isEqualToString:SELVideoPlayerControllerStatusKey]) {
           
            if (_queuePlayer.status == AVPlayerStatusReadyToPlay) {
                // Delegate - Player Ready to Play
                if ([self.delegate respondsToSelector:@selector(SELVideoPlayerReadyToPlay:)]) {
                    [self.delegate SELVideoPlayerReadyToPlay:SELVideoPlayerReadyToPlayPlayer];
                }
                
                if (![self isPlaying]) {
                    [_queuePlayer play];
                }
            } else if (_queuePlayer.status == AVPlayerStatusFailed) {
                NSLog(@"%@", _queuePlayer.error);
                // Delegate - Player Failed
                if ([self.delegate respondsToSelector:@selector(SELVideoPlayerDidFailed:error:)]) {
                    [self.delegate SELVideoPlayerDidFailed:SELVideoPlayerFailedPlayer error:_queuePlayer.error];
                }
            }
       
        // Player Rate Change
        }else if(object == _queuePlayer && [keyPath isEqualToString:SELVideoPlayerControllerRateKey]){
            // Delegate - Rate Change
            if ([self.delegate respondsToSelector:@selector(SELVideoPlayerRateChanged:)]) {
                [self.delegate SELVideoPlayerRateChanged:[self isPlaying]];
            }
            
        // Item set and unset
        }else if ([keyPath isEqualToString:SELVideoPlayerControllerCurrentItemKey]) {
            
            AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
            AVPlayerItem *lastPlayerItem = [change objectForKey:NSKeyValueChangeOldKey];
            if (newPlayerItem != (id)[NSNull null]) {
                @try {
                    [newPlayerItem addObserver:self forKeyPath:SELVideoPlayerControllerEmptyBufferKey options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:(__bridge void *)(SELVideoPlayerItemObserverContext)];
                    [newPlayerItem addObserver:self forKeyPath:SELVideoPlayerControllerPlayerKeepUpKey options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:(__bridge void *)(SELVideoPlayerItemObserverContext)];
                    [newPlayerItem addObserver:self forKeyPath:SELVideoPlayerControllerStatusKey options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:(__bridge void *)(SELVideoPlayerItemObserverContext)];
                    //[newPlayerItem addObserver:self forKeyPath:SELVideoPlayerControllerPlayerTimeRangesKey options:(NSKeyValueObservingOptionNew) context:(__bridge void *)(SELVideoPlayerItemObserverContext)];
                    // Delegate CurrentItemChanged
                    if ([self.delegate respondsToSelector:@selector(SELVideoPlayerCurrentItemChanged:)]) {
                        [self.delegate SELVideoPlayerCurrentItemChanged:newPlayerItem];
                    }
                    
                } @catch(id anException) {
                    NSLog(@"error lastplayerItem %@", anException);
                    //do nothing, obviously it wasn't attached because an exception was thrown
                }
            }
            if (lastPlayerItem != (id)[NSNull null]) {
                @try {
                    [lastPlayerItem removeObserver:self forKeyPath:SELVideoPlayerControllerEmptyBufferKey context:(__bridge void *)(SELVideoPlayerItemObserverContext)];
                    [lastPlayerItem removeObserver:self forKeyPath:SELVideoPlayerControllerPlayerKeepUpKey context:(__bridge void *)(SELVideoPlayerItemObserverContext)];
                    [lastPlayerItem removeObserver:self forKeyPath:SELVideoPlayerControllerStatusKey context:(__bridge void *)(SELVideoPlayerItemObserverContext)];
             //       [lastPlayerItem removeObserver:self forKeyPath:SELVideoPlayerControllerPlayerTimeRangesKey context:(__bridge void *)(SELVideoPlayerItemObserverContext)];
                    // Delegate - current item changed
                } @catch(id anException) {
                    NSLog(@"error newplayerItem %@", anException);
                    //do nothing, obviously it wasn't attached because an exception was thrown
                }
            }
        }
        
    }else if (context == (__bridge void *)(SELVideoPlayerItemObserverContext)) {
        
        // PlayerItem KVO
        
        if([keyPath isEqualToString:SELVideoPlayerControllerEmptyBufferKey]) {
            if (_queuePlayer.currentItem.playbackBufferEmpty) {
                //[self pause];
                [delegate SELVideoPlayerPlayerItemBuffering:YES];
               // NSLog(@"playback buffer is empty");
            }
        }else if([keyPath isEqualToString:SELVideoPlayerControllerPlayerKeepUpKey]) {
            if (_queuePlayer.currentItem.playbackLikelyToKeepUp) {
                // Delegate - BufferingStateReady
                [delegate SELVideoPlayerPlayerItemBuffering:NO];
                // ! Not sure need to check
                // play only when playing, but also play when in buffer state
                if (_playbackState == SELVideoPlayerPlaybackStatePlaying) {
                    [self play];
                }
            }
        }else if([keyPath isEqualToString:SELVideoPlayerControllerStatusKey]){
            
            if(_queuePlayer.currentItem.status == AVPlayerItemStatusFailed) {
                // Delegate - player item failed
                if ([self.delegate respondsToSelector:@selector(SELVideoPlayerDidFailed:error:)]) {
                    [self.delegate SELVideoPlayerDidFailed:SELVideoPlayerFailedCurrentItem error:_queuePlayer.currentItem.error];
                }
            }else if(_queuePlayer.currentItem.status == AVPlayerItemStatusReadyToPlay){
                // Delegate - ready to play
                if ([self.delegate respondsToSelector:@selector(SELVideoPlayerReadyToPlay:)]) {
                    [self.delegate SELVideoPlayerReadyToPlay:SELVideoPlayerReadyToPlayCurrentItem];
                }
                if (![self isPlaying]) {
                    [_queuePlayer play];
                }
            }
        }else if(_queuePlayer.items.count > 1 && object == [_queuePlayer.items objectAtIndex:1] && [keyPath isEqualToString:SELVideoPlayerControllerPlayerTimeRangesKey]){
            // isPreBuffered = YES;
        }else if(object == _queuePlayer.currentItem && [keyPath isEqualToString:SELVideoPlayerControllerPlayerTimeRangesKey]){
         
            /**if (_queuePlayer.currentItem.hash != prepareingItemHash) {
                [self prepareNextPlayerItem];
                prepareingItemHash = _queuePlayer.currentItem.hash;
            }**/
            NSLog(@"Debug Time Ranges 0");
            NSArray *timeRanges = (NSArray *)[change objectForKey:NSKeyValueChangeNewKey];
            if (timeRanges && [timeRanges count]) {
                CMTimeRange timerange=[[timeRanges objectAtIndex:0]CMTimeRangeValue];
                NSLog(@"Debug Time Ranges A ");
                // Delegate preload item
                if ([self.delegate respondsToSelector:@selector(SELVideoPlayerCurrentItemPreloaded:)]) {
                    [self.delegate SELVideoPlayerCurrentItemPreloaded:CMTimeAdd(timerange.start, timerange.duration)];
                }
                NSLog(@"Debug Time Ranges B 1");
                
                if (_queuePlayer.rate == 0) {
                    //pauseReasonBuffering = YES; && !pauseReasonForced
                    
                    //[self longTimeBufferBackground];
                     NSLog(@"Debug Time Ranges B 2");
                    CMTime bufferdTime = CMTimeAdd(timerange.start, timerange.duration);
                     NSLog(@"Debug Time Ranges B 3");
                    CMTime milestone = CMTimeAdd(_queuePlayer.currentTime, CMTimeMakeWithSeconds(5.0f, timerange.duration.timescale));
                    NSLog(@"Debug Time Ranges C");
                    if (CMTIME_COMPARE_INLINE(bufferdTime , >, milestone) && _queuePlayer.currentItem.status == AVPlayerItemStatusReadyToPlay) {
                        // && !interruptedWhilePlaying && !routeChangedWhilePlaying
                        if (![self isPlaying]) {
                            NSLog(@"resume from buffering..");
                            //pauseReasonBuffering = NO;
                            [_queuePlayer play];
                            NSLog(@"Debug Time Ranges D");
                            //[self longTimeBufferBackgroundCompleted];
                        }
                    }
                }
            }
        }
    
        AVPlayerStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        switch (status){
            case AVPlayerStatusReadyToPlay: {
                _videoView.playerLayer.backgroundColor = [[UIColor blackColor] CGColor];
                [_videoView.playerLayer setPlayer:_queuePlayer];
                _videoView.playerLayer.hidden = NO;
                break;
            }
            case AVPlayerStatusFailed: {
                _playbackState = SELVideoPlayerPlaybackStateFailed;
                //[_delegate videoPlayerPlaybackStateDidChange:self];
                break;
            }
            case AVPlayerStatusUnknown:
            default:
                break;
        }
        
    }else if(context == (__bridge void *)(SELVideoPlayerLayerObserverContext)){
        
        // PlayerLayer KVO
        if ([keyPath isEqualToString:SELVideoPlayerControllerReadyForDisplay]) {
            if (_videoView.playerLayer.readyForDisplay) {
                //[_delegate videoPlayerReady:self];
            }
        }
        
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - init

- (void)dealloc {
    _videoView.player = nil;
    
    // notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Item notifications
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    
    // Layer KVO
    [_videoView.layer removeObserver:self forKeyPath:SELVideoPlayerControllerReadyForDisplay context:(__bridge void *)SELVideoPlayerLayerObserverContext];
    
    // AVPlayer KVO
    [_queuePlayer removeObserver:self forKeyPath:SELVideoPlayerControllerRateKey context:(__bridge void *)SELVideoPlayerObserverContext];
    [_queuePlayer removeObserver:self forKeyPath:SELVideoPlayerControllerStatusKey context:(__bridge void *)SELVideoPlayerObserverContext];
    [_queuePlayer removeObserver:self forKeyPath:SELVideoPlayerControllerCurrentItemKey context:(__bridge void *)SELVideoPlayerObserverContext];
    
    // AV Items
    [self removeItems];
    
    // player
    [_queuePlayer pause];
    _queuePlayer = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
