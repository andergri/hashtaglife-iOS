//
//  SELVideoObject.m
//  #life
//
//  Created by Griffin Anderson on 5/27/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import "SELVideoObject.h"

@interface SELVideoObject ()

@property BOOL isVideo;
@property BOOL isLoaded;
@property (nonatomic)  NSURL *videoURL;

@end

@implementation SELVideoObject

@synthesize selfie;
@synthesize isLoaded;
@synthesize isVideo;
@synthesize videoURL;

- (SELVideoObject*) createVideo:(PFObject *)aselfie{
    
    isVideo = NO;
    isLoaded = NO;
    videoURL = nil;
    selfie = aselfie;
    
    PFFile *videoFile = selfie[@"video"];
    if (videoFile) {
        isVideo = YES;
        videoURL = [NSURL URLWithString:videoFile.url];
    }
    isLoaded = YES;
    return self;
}

- (BOOL) isVideoLoaded{
    return isLoaded;
}
- (BOOL) hasVideo{
    return isVideo;
}
- (NSURL*) videoURL{
    return videoURL;
}

@end
