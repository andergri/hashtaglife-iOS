//
//  SELVideoPlayer.h
//  #life
//
//  Created by Griffin Anderson on 5/25/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import <AvailabilityMacros.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, SELVideoPlayerReadyToPlay) {
    SELVideoPlayerReadyToPlayPlayer = 3000,
    SELVideoPlayerReadyToPlayCurrentItem = 3001,
};

typedef NS_ENUM(NSUInteger, SELVideoPlayerFailed) {
    SELVideoPlayerFailedPlayer = 4000,
    SELVideoPlayerFailedCurrentItem = 4001,
};

// Delegate

@protocol SELVideoPlayerDelegate <NSObject>
@optional
- (void)SELVideoPlayerWillChangedAtIndex:(NSUInteger)index;
- (void)SELVideoPlayerCurrentItemChanged:(AVPlayerItem *)item;
- (void)SELVideoPlayerRateChanged:(BOOL)isPlaying;
- (void)SELVideoPlayerDidReachEnd;
- (void)SELVideoPlayerCurrentItemPreloaded:(CMTime)time;
- (void)SELVideoPlayerDidFailed:(SELVideoPlayerFailed)identifier error:(NSError *)error;
- (void)SELVideoPlayerReadyToPlay:(SELVideoPlayerReadyToPlay)identifier;
@end

// Delegate

@protocol SELVideoPlayerDataSource <NSObject>
@optional
- (NSUInteger)SELVideoPlayerNumberOfItems;
- (NSURL *)SELVideoPlayerURLForItemAtIndex:(NSUInteger)index preBuffer:(BOOL)preBuffer;
- (void)SELVideoPlayerAsyncSetUrlForItemAtIndex:(NSUInteger)index preBuffer:(BOOL)preBuffer;
@end

typedef void (^ Failed)(SELVideoPlayerFailed identifier, NSError *error) DEPRECATED_MSG_ATTRIBUTE("deprecated since 2.5 version");
typedef void (^ ReadyToPlay)(SELVideoPlayerReadyToPlay identifier) DEPRECATED_MSG_ATTRIBUTE("deprecated since 2.5 version");
typedef void (^ SourceAsyncGetter)(NSUInteger index) DEPRECATED_MSG_ATTRIBUTE("deprecated since 2.5 version");
typedef NSURL * (^ SourceSyncGetter)(NSUInteger index) DEPRECATED_MSG_ATTRIBUTE("deprecated since 2.5 version");

typedef NS_ENUM(NSUInteger, SELVideoPlayerStatus) {
    SELVideoPlayerStatusPlaying = 0,
    SELVideoPlayerStatusForcePause,
    SELVideoPlayerStatusBuffering,
    SELVideoPlayerStatusUnknown,
};

typedef NS_ENUM(NSUInteger, SELVideoPlayerRepeatMode) {
    SELVideoPlayerRepeatModeOn = 0,
    SELVideoPlayerRepeatModeOnce,
    SELVideoPlayerRepeatModeOff,
};

@interface SELVideoPlayer : NSObject

@property (nonatomic) id<SELVideoPlayerDelegate> delegate;
@property (nonatomic) id<SELVideoPlayerDataSource> datasource;
@property (nonatomic) NSUInteger itemsCount;
@property (nonatomic) BOOL disableLogs;
@property (nonatomic, strong, readonly) NSArray *playerItems;
@property (nonatomic, readonly) BOOL isInEmptySound;
@property (nonatomic) BOOL popAlertWhenError;

+ (SELVideoPlayer *)sharedInstance;

- (void)registerHandlerReadyToPlay:(ReadyToPlay)readyToPlay DEPRECATED_MSG_ATTRIBUTE("use SELVideoPlayerDelegate instead");
- (void)registerHandlerFailed:(Failed)failed DEPRECATED_MSG_ATTRIBUTE("use SELVideoPlayerDelegate instead");


- (void)setupSourceGetter:(SourceSyncGetter)itemBlock ItemsCount:(NSUInteger) count DEPRECATED_MSG_ATTRIBUTE("use SELVideoPlayerDataSource instead.");
- (void)asyncSetupSourceGetter:(SourceAsyncGetter)asyncBlock ItemsCount:(NSUInteger)count DEPRECATED_MSG_ATTRIBUTE("use SELVideoPlayerDataSource instead.");
- (void)setItemsCount:(NSUInteger)count DEPRECATED_MSG_ATTRIBUTE("use SELVideoPlayerDataSource instead.");

/*!
 This method is necessary if you setting up AsyncGetter.
 After you your AVPlayerItem initialized should call this method on your asyncBlock.
 Should not call this method directly if you using setupSourceGetter:ItemsCount.
 @method setupPlayerItemWithUrl:index:
 */
- (void)setupPlayerItemWithUrl:(NSURL *)url index:(NSUInteger)index;
- (void)fetchAndPlayPlayerItem: (NSUInteger )startAt;
- (void)removeAllItems;
- (void)removeQueuesAtPlayer;
/*!
 Be sure you update SELVideoPlayerNumberOfItems or itemsCount when you remove items
 */
- (void)removeItemAtIndex:(NSUInteger)index;
- (void)moveItemFromIndex:(NSUInteger)from toIndex:(NSUInteger)to;
- (void)play;
- (void)pause;
- (void)pausePlayerForcibly:(BOOL)forcibly;
- (void)playPrevious;
- (void)playNext;
- (void)seekToTime:(double) CMTime;
- (void)seekToTime:(double) CMTime withCompletionBlock:(void (^)(BOOL finished))completionBlock;

@property (nonatomic, strong) AVQueuePlayer *videoPlayer;

- (void)setPlayerRepeatMode:(SELVideoPlayerRepeatMode)mode;
- (SELVideoPlayerRepeatMode)getPlayerRepeatMode;

- (BOOL)isPlaying;
- (AVPlayerItem *)getCurrentItem;
- (SELVideoPlayerStatus)getSELVideoPlayerStatus;

- (void)addDelegate:(id<SELVideoPlayerDelegate>)delegate DEPRECATED_MSG_ATTRIBUTE("set delegate property instead");
- (void)removeDelegate:(id<SELVideoPlayerDelegate>)delegate DEPRECATED_MSG_ATTRIBUTE("Use delegate property instead");;

- (float)getPlayingItemCurrentTime;
- (float)getPlayingItemDurationTime;
- (id)addPeriodicTimeObserverForInterval:(CMTime)interval
                                   queue:(dispatch_queue_t)queue
                              usingBlock:(void (^)(CMTime time))block;

/*
 * Disable memory cache, player will run SourceItemGetter everytime even the media has been played.
 * Default is YES
 */
- (void)enableMemoryCached:(BOOL) isMemoryCached;
- (BOOL)isMemoryCached;

/*
 * Indicating Playeritem's play index
 */
- (NSNumber *)getHysteriaIndex:(AVPlayerItem *)item;

- (void)deprecatePlayer;

@end