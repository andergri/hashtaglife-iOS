//
//  SELOnStartViewController.h
//  #life
//
//  Created by Griffin Anderson on 3/22/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SELColorPicker.h"

@interface SELOnStartViewController : UIViewController

- (void) runOnStart:(SELColorPicker*)color;
- (BOOL) checkForPremissions;

@end
