//
//  SELLocationViewController.h
//  #life
//
//  Created by Griffin Anderson on 2/9/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SELLocationTableViewController.h"

@interface SELLocationViewController : UIViewController <UITextFieldDelegate>

@property SELColorPicker *color;
@property BOOL selecting;

- (void) unlockSearch;
- (void) lockSearch;
- (void) changedLocation;

@end
