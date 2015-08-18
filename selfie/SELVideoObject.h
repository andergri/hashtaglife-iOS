//
//  SELVideoObject.h
//  #life
//
//  Created by Griffin Anderson on 5/27/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SELVideoObject : NSObject

- (SELVideoObject*) createVideo:(PFObject *)aselfie;

- (BOOL) isVideoLoaded;
- (BOOL) hasVideo;
- (NSURL*) videoURL;

@property PFObject* selfie;

@end
