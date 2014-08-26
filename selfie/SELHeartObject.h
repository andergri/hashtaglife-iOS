//
//  SELHeartObject.h
//  #life
//
//  Created by Griffin Anderson on 8/20/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SELHeartObject : NSObject

- (void) initHeart:(UIView *)view;
- (void) hideHeart;
- (void) showHeart;
- (void) tapHeart:(PFObject *) selfie;
- (void) resetHeart;

@end
