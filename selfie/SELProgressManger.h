//
//  SELProgressManger.h
//  #life
//
//  Created by Griffin Anderson on 5/26/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SELProgressMangerDelegate <NSObject>

- (void)pingForProgress;
- (void)finishedLoading;

@end

@interface SELProgressManger : NSObject

@property UIProgressView *progressView;
@property (nonatomic) id<SELProgressMangerDelegate> delegate;

- (SELProgressManger*)init:(UIProgressView*)progressView;
- (void)start:(NSMutableArray*)selfies;
- (void)stop;
- (void)update:(NSInteger)progress;
- (void) loaded;

@end
