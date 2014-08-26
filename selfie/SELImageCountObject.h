//
//  SELImageCountObject.h
//  #life
//
//  Created by Griffin Anderson on 8/20/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SELImageCountObject : NSObject


- (void) initImageTally: (UIView *)view;
- (void) countImageTally:(PFObject *) selfie;
- (void) hideTally;
- (void) showTally;

@end
