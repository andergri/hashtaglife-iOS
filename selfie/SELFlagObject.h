//
//  SELFlagObject.h
//  #life
//
//  Created by Griffin Anderson on 8/20/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SELFlagObject : NSObject

- (void) initFlag:(UIView *)view;
- (void) hideFlag;
- (void) showFlag;
- (void) tapFlag:(PFObject *) selfie;
- (void) resetFlag;

@end
