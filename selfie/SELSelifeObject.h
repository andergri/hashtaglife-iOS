//
//  SELSelifeObject.h
//  #life
//
//  Created by Griffin Anderson on 9/5/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface SELSelifeObject : NSObject

- (SELSelifeObject*) createSelife:(PFObject *)aselfie;
- (BOOL) isImageLoaded;
- (BOOL) isImageError;
- (float) imageProgress;

@property PFObject* selfie;
@property UIImage* image;

@end
