//
//  SELHeartObject.h
//  #life
//
//  Created by Griffin Anderson on 8/20/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SELColorPicker.h"

@interface SELHeartObject : NSObject

- (void) initHeart:(UIView *)view color:(SELColorPicker *)color;
- (void) setCount:(PFObject *) selfie;
- (void) hideHeart;
- (void) showHeart;
//- (void) tapHeart:(PFObject *) selfie;
- (void) tapUpvote:(PFObject *) selfie;
- (void) tapDownvote:(PFObject *) selfie;
- (void) resetHeart:(PFObject *) selfie;
- (BOOL) isHidden;

@end
