//
//  SELVideoPlayer.m
//  #life
//
//  Created by Griffin Anderson on 5/25/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import "SELVideoPlayer.h"
#import <AudioToolbox/AudioSession.h>
#import <objc/runtime.h>

static const void *Videotag = &Videotag;

@interface SELVideoPlayer ()
{
    BOOL routeChangedWhilePlaying;
    BOOL interruptedWhilePlaying;
    BOOL pauseReasonForced;
    BOOL pauseReasonBuffering;
    BOOL isPreBuffered;
    BOOL tookVideoFocus;
    
    NSUInteger prepareingItemHash;
    
    UIBackgroundTaskIdentifier bgTaskId;
    UIBackgroundTaskIdentifier removedId;
    
    dispatch_queue_t HBGQueue;
}

@property (nonatomic, strong, readwrite) NSArray *playerItems;
@property (nonatomic, readwrite) BOOL isInEmptyVideo;
@property (nonatomic) NSUInteger lastItemIndex;

@property (nonatomic) SELVideoPlayerRepeatMode repeatMode;
@property (nonatomic) SELVideoPlayerStatus SELVideoPlayerStatus;
@property (nonatomic, strong) NSMutableSet *playedItems;

- (void)longTimeBufferBackground;
- (void)longTimeBufferBackgroundCompleted;
- (void)setHysteriaIndex:(AVPlayerItem *)item Key:(NSNumber *)order;

@end

@implementation SELVideoPlayer

static SELVideoPlayer *sharedInstance = nil;
static dispatch_once_t onceToken;

#pragma mark -
#pragma mark ===========  Initialization, Setup  =========
#pragma mark -

+ (SELVideoPlayer *)sharedInstance {
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

+ (void)showAlertWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Player errors"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (id)init {
    self = [super init];
    if (self) {
        HBGQueue = dispatch_queue_create("com.ios.-life", NULL);
        _playerItems = [NSArray array];
        
        _repeatMode = SELVideoPlayerRepeatModeOff;
        _SELVideoPlayerStatus = SELVideoPlayerStatusUnknown;
    }
    
    return self;
}

- (void)preAction
{
    tookVideoFocus = YES;
    
    [self backgroundPlayable];
    [self AVPlayerNotification];
}

- (void)registerHandlerReadyToPlay:(ReadyToPlay)readyToPlay{}

-(void)registerHandlerFailed:(Failed)failed {}

- (void)setupSourceGetter:(SourceSyncGetter)itemBlock ItemsCount:(NSUInteger)count {}

- (void)asyncSetupSourceGetter:(SourceAsyncGetter)asyncBlock ItemsCount:(NSUInteger)count{}

- (void)setItemsCount:(NSUInteger)count {}

- (void)backgroundPlayable
{
    /**
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    if (audioSession.category != AVAudioSessionCategoryPlayback) {
        UIDevice *device = [UIDevice currentDevice];
        if ([device respondsToSelector:@selector(isMultitaskingSupported)]) {
            if (device.multitaskingSupported) {
                
                NSError *aError = nil;
                [audioSession setCategory:AVAudioSessionCategoryPlayback error:&aError];
                if (aError) {
                    if (!self.disableLogs) {
                        NSLog(@"set category error:%@",[aError description]);
                    }
                }
                aError = nil;
                [audioSession setActive:YES error:&aError];
                if (aError) {
                    if (!self.disableLogs) {
                        NSLog(@"set active error:%@",[aError description]);
                    }
                }
                //audioSession.delegate = self;
            }
        }
    }else {
        if (!self.disableLogs) {
            NSLog(@"unable to register background playback");
        }
    }**/
    
    [self longTimeBufferBackground];
}
 
/*
 * Tells OS this application starts one or more long-running tasks, should end background task when completed.
 */
-(void)longTimeBufferBackground
{
    bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:removedId];
        bgTaskId = UIBackgroundTaskInvalid;
    }];
    
    if (bgTaskId != UIBackgroundTaskInvalid && removedId == 0 ? YES : (removedId != UIBackgroundTaskInvalid)) {
        [[UIApplication sharedApplication] endBackgroundTask: removedId];
    }
    removedId = bgTaskId;
}

-(void)longTimeBufferBackgroundCompleted
{
    if (bgTaskId != UIBackgroundTaskInvalid && removedId != bgTaskId) {
        [[UIApplication sharedApplication] endBackgroundTask: bgTaskId];
        removedId = bgTaskId;
    }
    
}

#pragma mark -
#pragma mark ===========  Runtime AssociatedObject  =========
#pragma mark -

- (void)setHysteriaIndex:(AVPlayerItem *)item Key:(NSNumber *)order {
    objc_setAssociatedObject(item, Videotag, order, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)getHysteriaIndex:(AVPlayerItem *)item {
    NSLog(@"getHysteriaIndex= %@", objc_getAssociatedObject(item, Videotag));
    return objc_getAssociatedObject(item, Videotag);
}

#pragma mark -
#pragma mark ===========  AVPlayer Notifications  =========
#pragma mark -

- (void)AVPlayerNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
 /**   [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemFailedToReachEnd:)
                                                 name:AVPlayerItemFailedToPlayToEndTimeNotification
                                               object:nil];
 **/
    /**
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(interruption:)
                                                 name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(routeChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    **/
    [self.videoPlayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    [self.videoPlayer addObserver:self forKeyPath:@"rate" options:0 context:nil];
    [self.videoPlayer addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

#pragma mark -
#pragma mark ===========  Player Methods  =========
#pragma mark -

- (void)willPlayPlayerItemAtIndex:(NSUInteger)index
{
    if (!tookVideoFocus) {
        [self preAction];
    }
    self.lastItemIndex = index;
    [self.playedItems addObject:@(index)];
    
    if ([self.delegate respondsToSelector:@selector(SELVideoPlayerWillChangedAtIndex:)]) {
        [self.delegate SELVideoPlayerWillChangedAtIndex:self.lastItemIndex];
    }
}

- (void)fetchAndPlayPlayerItem:(NSUInteger)startAt
{
    NSLog(@"0) fetchAndPlayPlayerItem A");
    [self willPlayPlayerItemAtIndex:startAt];
    [self.videoPlayer pause];
    [self.videoPlayer removeAllItems];
    BOOL findInPlayerItems = NO;
    findInPlayerItems = [self findSourceInPlayerItems:startAt];
        NSLog(@"0) fetchAndPlayPlayerItem B");
    if (!findInPlayerItems) {
        [self getSourceURLAtIndex:startAt preBuffer:NO];
        NSLog(@"0) fetchAndPlayPlayerItem C");
    } else if (self.videoPlayer.currentItem.status == AVPlayerStatusReadyToPlay) {
        NSLog(@"0) fetchAndPlayPlayerItem D");
        [self.videoPlayer play];
    }
}

- (NSUInteger)SELVideoPlayerItemsCount
{
    if ([self.datasource respondsToSelector:@selector(SELVideoPlayerNumberOfItems)]) {
        return [self.datasource SELVideoPlayerNumberOfItems];
    }
    return self.itemsCount;
}

- (void)getSourceURLAtIndex:(NSUInteger)index preBuffer:(BOOL)preBuffer
{
    NSAssert([self.datasource respondsToSelector:@selector(SELVideoPlayerURLForItemAtIndex:preBuffer:)] || [self.datasource respondsToSelector:@selector(SELVideoPlayerAsyncSetUrlForItemAtIndex:preBuffer:)], @"You don't implement URL getter delegate from SELVideoPlayerDelegate, SELVideoPlayerURLForItemAtIndex:preBuffer: and SELVideoPlayerAsyncSetUrlForItemAtIndex:preBuffer: provides for the use of alternatives.");
    NSAssert([self SELVideoPlayerItemsCount] > index, ([NSString stringWithFormat:@"You are about to access index: %li URL when your SELVideoPlayer items count value is %lu, please check SELVideoPlayerNumberOfItems or set itemsCount directly.", (unsigned long)index, (unsigned long)[self SELVideoPlayerItemsCount]]));
    if ([self.datasource respondsToSelector:@selector(SELVideoPlayerURLForItemAtIndex:preBuffer:)] && [self.datasource SELVideoPlayerURLForItemAtIndex:index preBuffer:preBuffer]) {
        NSLog(@"0) getSourceURLAtIndex A");
        dispatch_async(HBGQueue, ^{
            [self setupPlayerItemWithUrl:[self.datasource SELVideoPlayerURLForItemAtIndex:index preBuffer:preBuffer] index:index];
        });
    } else if ([self.datasource respondsToSelector:@selector(SELVideoPlayerAsyncSetUrlForItemAtIndex:preBuffer:)]) {
        NSLog(@"0) getSourceURLAtIndex B");
        [self.datasource SELVideoPlayerAsyncSetUrlForItemAtIndex:index preBuffer:preBuffer];
    } else {
        NSLog(@"0) getSourceURLAtIndex C");
        NSException *exception = [[NSException alloc] initWithName:@"SELVideoPlayer Error" reason:[NSString stringWithFormat:@"Cannot find item URL at index %li", (unsigned long)index] userInfo:nil];
        @throw exception;
    }
}

- (void)setupPlayerItemWithUrl:(NSURL *)url index:(NSUInteger)index
{
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    if (!item)
        return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"1) setupPlayerItemWithURL");
        [self setHysteriaIndex:item Key:[NSNumber numberWithInteger:index]];
        NSMutableArray *playerItems = [NSMutableArray arrayWithArray:self.playerItems];
        [playerItems addObject:item];
        self.playerItems = playerItems;
        [self insertPlayerItem:item];
    });
}


- (BOOL)findSourceInPlayerItems:(NSUInteger)index
{
    for (AVPlayerItem *item in self.playerItems) {
        NSInteger checkIndex = [[self getHysteriaIndex:item] integerValue];
        if (checkIndex == index) {
            [item seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
                [self insertPlayerItem:item];
            }];
            return YES;
        }
    }
    return NO;
}

- (void)prepareNextPlayerItem
{
    // check before added, prevent add the same songItem
    NSNumber *currentIndexNumber = [self getHysteriaIndex:self.videoPlayer.currentItem];
    NSUInteger nowIndex = [currentIndexNumber integerValue];
    BOOL findInPlayerItems = NO;
    NSUInteger itemsCount = [self SELVideoPlayerItemsCount];
    
    if (currentIndexNumber) {
        if (_repeatMode == SELVideoPlayerRepeatModeOnce) {
            return;
        }
        if (nowIndex + 1 < itemsCount) {
            findInPlayerItems = [self findSourceInPlayerItems:nowIndex + 1];
            
            if (!findInPlayerItems) {
                [self getSourceURLAtIndex:nowIndex + 1 preBuffer:YES];
            }
        }
    }
}

- (void)insertPlayerItem:(AVPlayerItem *)item
{
    NSLog(@"2) insert player item");
    if ([self.videoPlayer.items count] > 1) {
        for (int i = 1 ; i < [self.videoPlayer.items count] ; i ++) {
            [self.videoPlayer removeItem:[self.videoPlayer.items objectAtIndex:i]];
        }
    }
    if ([self.videoPlayer canInsertItem:item afterItem:nil]) {
        [self.videoPlayer insertItem:item afterItem:nil];
    }
}

- (void)removeAllItems
{
    for (AVPlayerItem *obj in self.videoPlayer.items) {
        [obj seekToTime:kCMTimeZero];
        @try{
            [obj removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
            [obj removeObserver:self forKeyPath:@"status" context:nil];
        }@catch(id anException){
            //do nothing, obviously it wasn't attached because an exception was thrown
        }
    }
    
    self.playerItems = nil;
    [self.videoPlayer removeAllItems];
}

- (void)removeQueuesAtPlayer
{
    while (self.videoPlayer.items.count > 1) {
        [self.videoPlayer removeItem:[self.videoPlayer.items objectAtIndex:1]];
    }
}

- (void)removeItemAtIndex:(NSUInteger)order
{
    for (AVPlayerItem *item in [NSArray arrayWithArray:self.playerItems]) {
        NSUInteger CHECK_order = [[self getHysteriaIndex:item] integerValue];
        if (CHECK_order == order) {
            NSMutableArray *playerItems = [NSMutableArray arrayWithArray:self.playerItems];
            [playerItems removeObject:item];
            self.playerItems = playerItems;
            
            if ([self.videoPlayer.items indexOfObject:item] != NSNotFound) {
                [self.videoPlayer removeItem:item];
            }
        }else if (CHECK_order > order){
            [self setHysteriaIndex:item Key:[NSNumber numberWithInteger:CHECK_order -1]];
        }
    }
}

- (void)moveItemFromIndex:(NSUInteger)from toIndex:(NSUInteger)to
{
    for (AVPlayerItem *item in self.playerItems) {
        NSUInteger CHECK_index = [[self getHysteriaIndex:item] integerValue];
        if (CHECK_index == from || CHECK_index == to) {
            NSNumber *replaceOrder = CHECK_index == from ? [NSNumber numberWithInteger:to] : [NSNumber numberWithInteger:from];
            [self setHysteriaIndex:item Key:replaceOrder];
        }
    }
}

- (void)seekToTime:(double)seconds
{
    [self.videoPlayer seekToTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC)];
}

- (void)seekToTime:(double)seconds withCompletionBlock:(void (^)(BOOL))completionBlock
{
    [self.videoPlayer seekToTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        if (completionBlock) {
            completionBlock(finished);
        }
    }];
}

- (AVPlayerItem *)getCurrentItem
{
    return [self.videoPlayer currentItem];
}

- (void)play
{
    [self.videoPlayer play];
}

- (void)pause
{
    [self.videoPlayer pause];
}

- (void)playNext {

    NSNumber *nowIndexNumber = [self getHysteriaIndex:self.videoPlayer.currentItem];
    NSUInteger nowIndex = nowIndexNumber ? [nowIndexNumber integerValue] : self.lastItemIndex;
    if (nowIndex + 1 < [self SELVideoPlayerItemsCount]) {
        if (self.videoPlayer.items.count > 1) {
            [self willPlayPlayerItemAtIndex:nowIndex + 1];
            [self.videoPlayer advanceToNextItem];
        } else {
            [self fetchAndPlayPlayerItem:(nowIndex + 1)];
        }
    } else {
        if (_repeatMode == SELVideoPlayerRepeatModeOff) {
            [self pausePlayerForcibly:YES];
            if ([self.delegate respondsToSelector:@selector(SELVideoPlayerDidReachEnd)]) {
                [self.delegate SELVideoPlayerDidReachEnd];
            }
        }
        [self fetchAndPlayPlayerItem:0];
    }
}

- (void)playPrevious
{
    NSInteger nowIndex = [[self getHysteriaIndex:self.videoPlayer.currentItem] integerValue];
    if (nowIndex == 0)
    {
        if (_repeatMode == SELVideoPlayerRepeatModeOn) {
            [self fetchAndPlayPlayerItem:[self SELVideoPlayerItemsCount] - 1];
        } else {
            [self.videoPlayer.currentItem seekToTime:kCMTimeZero];
        }
    } else {
        [self fetchAndPlayPlayerItem:(nowIndex - 1)];
    }
}

/**********/

- (CMTime)playerItemDuration
{
    NSError *err = nil;
    if ([self.videoPlayer.currentItem.asset statusOfValueForKey:@"duration" error:&err] == AVKeyValueStatusLoaded) {
        AVPlayerItem *playerItem = [self.videoPlayer currentItem];
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

- (void)setPlayerRepeatMode:(SELVideoPlayerRepeatMode)mode
{
    _repeatMode = mode;
}

- (SELVideoPlayerRepeatMode)getPlayerRepeatMode
{
    return _repeatMode;
}

- (void)pausePlayerForcibly:(BOOL)forcibly
{
    pauseReasonForced = forcibly;
}

#pragma mark -
#pragma mark ===========  Player info  =========
#pragma mark -

- (BOOL)isPlaying
{
    if (!self.isInEmptySound)
        return [self.videoPlayer rate] != 0.f;
    else
        return NO;
}

- (SELVideoPlayerStatus)getSELVideoPlayerStatus
{
    if ([self isPlaying])
        return SELVideoPlayerStatusPlaying;
    else if (pauseReasonForced)
        return SELVideoPlayerStatusForcePause;
    else if (pauseReasonBuffering)
        return SELVideoPlayerStatusBuffering;
    else {
        return SELVideoPlayerStatusUnknown;
    }
}

- (float)getPlayingItemCurrentTime
{
    CMTime itemCurrentTime = [[self.videoPlayer currentItem] currentTime];
    float current = CMTimeGetSeconds(itemCurrentTime);
    if (CMTIME_IS_INVALID(itemCurrentTime) || !isfinite(current))
        return 0.0f;
    else
        return current;
}

- (float)getPlayingItemDurationTime
{
    CMTime itemDurationTime = [self playerItemDuration];
    float duration = CMTimeGetSeconds(itemDurationTime);
    if (CMTIME_IS_INVALID(itemDurationTime) || !isfinite(duration))
        return 0.0f;
    else
        return duration;
}

- (id)addPeriodicTimeObserverForInterval:(CMTime)interval
                                   queue:(dispatch_queue_t)queue
                              usingBlock:(void (^)(CMTime time))block
{
    id mTimeObserver = [self.videoPlayer addPeriodicTimeObserverForInterval:interval queue:queue usingBlock:block];
    return mTimeObserver;
}

#pragma mark -
#pragma mark ===========  Interruption, Route changed  =========
#pragma mark -






#pragma mark -
#pragma mark ===========  KVO  =========
#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    NSLog(@"KVO start");
    if (object == self.videoPlayer && [keyPath isEqualToString:@"status"]) {
        NSLog(@"KVO status");
        if (self.videoPlayer.status == AVPlayerStatusReadyToPlay) {
            if ([self.delegate respondsToSelector:@selector(SELVideoPlayerReadyToPlay:)]) {
                [self.delegate SELVideoPlayerReadyToPlay:SELVideoPlayerReadyToPlayPlayer];
            }
            if (![self isPlaying]) {
                [self.videoPlayer play];
            }
        } else if (self.videoPlayer.status == AVPlayerStatusFailed) {
            if (!self.disableLogs) {
                NSLog(@"%@", self.videoPlayer.error);
            }
            
            if (self.popAlertWhenError) {
                [SELVideoPlayer showAlertWithError:self.videoPlayer.error];
            }
            if ([self.delegate respondsToSelector:@selector(SELVideoPlayerDidFailed:error:)]) {
                [self.delegate SELVideoPlayerDidFailed:SELVideoPlayerFailedPlayer error:self.videoPlayer.error];
            }
        }
    }
    
    if(object == self.videoPlayer && [keyPath isEqualToString:@"rate"]){
        NSLog(@"KVO rate");
        if (!self.isInEmptySound) {
            if ([self.delegate respondsToSelector:@selector(SELVideoPlayerRateChanged:)]) {
                [self.delegate SELVideoPlayerRateChanged:[self isPlaying]];
            }
        }
    }
    
    if(object == self.videoPlayer && [keyPath isEqualToString:@"currentItem"]){
        NSLog(@"KVO currentItem");
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        AVPlayerItem *lastPlayerItem = [change objectForKey:NSKeyValueChangeOldKey];
        if (lastPlayerItem != (id)[NSNull null]) {
            self.isInEmptyVideo = NO;
            @try {
                [lastPlayerItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
                [lastPlayerItem removeObserver:self forKeyPath:@"status" context:nil];
            } @catch(id anException) {
                //do nothing, obviously it wasn't attached because an exception was thrown
            }
        }
        if (newPlayerItem != (id)[NSNull null]) {
            [newPlayerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
            [newPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
            if ([self.delegate respondsToSelector:@selector(SELVideoPlayerCurrentItemChanged:)]) {
                [self.delegate SELVideoPlayerCurrentItemChanged:newPlayerItem];
            }
        }
    }
    
    if (object == self.videoPlayer.currentItem && [keyPath isEqualToString:@"status"]) {
        NSLog(@"KVO status b");
        isPreBuffered = NO;
        if (self.videoPlayer.currentItem.status == AVPlayerItemStatusFailed) {
            if (self.popAlertWhenError) {
                [SELVideoPlayer showAlertWithError:self.videoPlayer.currentItem.error];
            }
            
            if ([self.delegate respondsToSelector:@selector(SELVideoPlayerDidFailed:error:)]) {
                [self.delegate SELVideoPlayerDidFailed:SELVideoPlayerFailedCurrentItem error:self.videoPlayer.currentItem.error];
            }
        }else if (self.videoPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay) {
            if ([self.delegate respondsToSelector:@selector(SELVideoPlayerReadyToPlay:)]) {
                [self.delegate SELVideoPlayerReadyToPlay:SELVideoPlayerReadyToPlayCurrentItem];
            }
            if (![self isPlaying] && !pauseReasonForced) {
                [self.videoPlayer play];
            }
        }
    }
    
    if (self.videoPlayer.items.count > 1 && object == [self.videoPlayer.items objectAtIndex:1] && [keyPath isEqualToString:@"loadedTimeRanges"]) {
        isPreBuffered = YES;
    }
    
    if(object == self.videoPlayer.currentItem && [keyPath isEqualToString:@"loadedTimeRanges"]){
        if (self.videoPlayer.currentItem.hash != prepareingItemHash) {
            [self prepareNextPlayerItem];
            prepareingItemHash = self.videoPlayer.currentItem.hash;
        }
        
        NSArray *timeRanges = (NSArray *)[change objectForKey:NSKeyValueChangeNewKey];
        if (timeRanges && [timeRanges count]) {
            CMTimeRange timerange=[[timeRanges objectAtIndex:0]CMTimeRangeValue];
            
            if ([self.delegate respondsToSelector:@selector(SELVideoPlayerCurrentItemPreloaded:)]) {
                [self.delegate SELVideoPlayerCurrentItemPreloaded:CMTimeAdd(timerange.start, timerange.duration)];
            }
            
            if (self.videoPlayer.rate == 0 && !pauseReasonForced) {
                pauseReasonBuffering = YES;
                
                [self longTimeBufferBackground];
                
                CMTime bufferdTime = CMTimeAdd(timerange.start, timerange.duration);
                CMTime milestone = CMTimeAdd(self.videoPlayer.currentTime, CMTimeMakeWithSeconds(5.0f, timerange.duration.timescale));
                
                if (CMTIME_COMPARE_INLINE(bufferdTime , >, milestone) && self.videoPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay && !interruptedWhilePlaying && !routeChangedWhilePlaying) {
                    if (![self isPlaying]) {
                        if (!self.disableLogs) {
                            NSLog(@"resume from buffering..");
                        }
                        pauseReasonBuffering = NO;
                        
                        [self.videoPlayer play];
                        [self longTimeBufferBackgroundCompleted];
                    }
                }
            }
        }
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    AVPlayerItem *item = [notification object];
    if(![item isEqual:self.videoPlayer.currentItem]){
        return;
    }
    
    NSNumber *CHECK_Order = [self getHysteriaIndex:self.videoPlayer.currentItem];
    if (CHECK_Order) {
        if (_repeatMode == SELVideoPlayerRepeatModeOnce) {
            NSInteger currentIndex = [CHECK_Order integerValue];
            [self fetchAndPlayPlayerItem:currentIndex];
        } else {
            if (self.videoPlayer.items.count == 1 || !isPreBuffered) {
                NSInteger nowIndex = [CHECK_Order integerValue];
                if (nowIndex + 1 < [self SELVideoPlayerItemsCount]) {
                    [self playNext];
                } else {
                    if (_repeatMode == SELVideoPlayerRepeatModeOff) {
                        [self pausePlayerForcibly:YES];
                        if ([self.delegate respondsToSelector:@selector(SELVideoPlayerDidReachEnd)]) {
                            [self.delegate SELVideoPlayerDidReachEnd];
                        }
                    }
                    [self fetchAndPlayPlayerItem:0];
                }
            }
        }
    }
}

#pragma mark -
#pragma mark ===========   Deprecation  =========
#pragma mark -

- (void)deprecatePlayer
{
    NSError *error;
    tookVideoFocus = NO;
    [[AVAudioSession sharedInstance] setActive:NO error:&error];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    
    [self.videoPlayer removeObserver:self forKeyPath:@"status" context:nil];
    [self.videoPlayer removeObserver:self forKeyPath:@"rate" context:nil];
    [self.videoPlayer removeObserver:self forKeyPath:@"currentItem" context:nil];
    
    [self removeAllItems];
    
    [self.videoPlayer pause];
    self.delegate = nil;
    self.datasource = nil;
    self.videoPlayer = nil;
    
    onceToken = 0;
}

#pragma mark -
#pragma mark ===========   Memory cached  =========
#pragma mark -

- (BOOL) isMemoryCached
{
    return (self.playerItems == nil);
}

- (void) enableMemoryCached:(BOOL)isMemoryCached
{
    if (self.playerItems == nil && isMemoryCached) {
        self.playerItems = [NSArray array];
    }else if (self.playerItems != nil && !isMemoryCached){
        self.playerItems = nil;
    }
}

#pragma mark -
#pragma mark ===========   Delegation  =========
#pragma mark -

- (void)addDelegate:(id<SELVideoPlayerDelegate>)delegate{}

- (void)removeDelegate:(id<SELVideoPlayerDelegate>)delegate{}

@end
