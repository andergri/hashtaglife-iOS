//
//  SELVideoView.m
//  #life
//
//  Created by Griffin Anderson on 5/24/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import "SELVideoView.h"
#import <AVFoundation/AVFoundation.h>

@implementation SELVideoView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

#pragma mark - getters/setters

- (void)setPlayer:(AVQueuePlayer *)player
{
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

- (AVQueuePlayer *)player
{
    return (AVQueuePlayer *)[(AVPlayerLayer *)[self layer] player];
}

- (AVPlayerLayer *)playerLayer
{
    return (AVPlayerLayer *)self.layer;
}

- (void)setVideoFillMode:(NSString *)videoFillMode
{
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)[self layer];
    playerLayer.videoGravity = videoFillMode;
}

- (NSString *)videoFillMode
{
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)[self layer];
    return playerLayer.videoGravity;
}

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.playerLayer.backgroundColor = [[UIColor blackColor] CGColor];
    }
    return self;
}

@end