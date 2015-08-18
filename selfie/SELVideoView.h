//
//  SELVideoView.h
//  #life
//
//  Created by Griffin Anderson on 5/24/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVQueuePlayer;
@class AVPlayerLayer;

@interface SELVideoView : UIView

@property (nonatomic) AVQueuePlayer *player;
@property (nonatomic, readonly) AVPlayerLayer *playerLayer;

// defaults to AVLayerVideoGravityResizeAspect
@property (nonatomic, readwrite) NSString *videoFillMode;

@end
