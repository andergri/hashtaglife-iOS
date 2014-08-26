//
//  SELUserLikesObject.h
//  #life
//
//  Created by Griffin Anderson on 8/20/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SELColorPicker.h"

@interface SELUserLikesObject : NSObject

@property UIView *likeContainer;

- (void) initUserLikes:(UIView *)view below:(UIView *)belowView color:(SELColorPicker *)color;
- (void) getNumberUserLikes;

@end
