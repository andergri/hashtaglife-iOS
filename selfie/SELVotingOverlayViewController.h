//
//  SELVotingOverlayViewController.h
//  #life
//
//  Created by Griffin Anderson on 7/9/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SELColorPicker.h"

@interface SELVotingOverlayViewController : UIViewController

@property SELColorPicker *color;
- (void) setSelfie:(PFObject *)selfie;
- (void) scrollTableView;

@end
