//
//  SELProgressManger.m
//  #life
//
//  Created by Griffin Anderson on 5/26/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import "SELProgressManger.h"

#define startValue 0.05

@interface SELProgressManger ()

@property BOOL loadedAllContnet;
@property float currentProgress;
@property float scaleValue;
@property NSInteger totalToLoad;
@property NSInteger currentLoaded;

@end

@implementation SELProgressManger

@synthesize delegate;
@synthesize currentProgress;
@synthesize loadedAllContnet;
@synthesize scaleValue;
@synthesize totalToLoad;
@synthesize currentLoaded;

#pragma - Public methdods

- (SELProgressManger*)init:(UIProgressView*)progressView{
    self.progressView = progressView;
    return self;
}
- (void)start:(NSMutableArray*)selfies{
    [self resetProgress];
    currentProgress = startValue;
    scaleValue = 0.90 / selfies.count;
    totalToLoad = selfies.count;
    [self startProgress];
    [self checkProgress];
}
- (void)stop{

    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(checkProgress)
                                               object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(startProgress)
                                               object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(finishProgress)
                                               object:nil];
    [self resetProgress];
}
- (void)update:(NSInteger)progress{
    currentProgress = (scaleValue * (float)progress) + startValue;
    self.progressView.progress = currentProgress;
    currentLoaded  = progress;
}

- (void) loaded{
    loadedAllContnet = YES;
    [self finishProgress];
    [self stop];
    [self.delegate finishedLoading];
}

#pragma - Private methdods

- (void)resetProgress{
    currentProgress = 0.00;
    scaleValue = 0.00;
    self.progressView.progress = 0.0;
    totalToLoad = 0;
    currentLoaded = 0;
    loadedAllContnet = false;
}

- (void)startProgress{
    if (currentProgress < startValue) {
        currentProgress += 0.01;
        self.progressView.progress = currentProgress;
        
        [self performSelector:@selector(startProgress) withObject:nil afterDelay:1.0f];
    }
}

- (void)finishProgress{
    if (currentProgress < 1.00) {
        currentProgress += 0.01;
        self.progressView.progress = currentProgress;
        [self performSelector:@selector(finishProgress) withObject:nil afterDelay:0.2f];
    }
}

- (void)checkProgress{
    
    if ([self isAllLoaded]) {
        return;
    }
    [self.delegate pingForProgress];
    [self performSelector:@selector(checkProgress) withObject:nil afterDelay:.8f];
}


- (BOOL) isAllLoaded{

    if (currentLoaded == totalToLoad) {
        loadedAllContnet = YES;
        [self finishProgress];
        [self stop];
        [self.delegate finishedLoading];
        return YES;
    }
    return NO;
}

@end
