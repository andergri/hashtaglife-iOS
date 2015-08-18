//
//  SELLocationTableViewController.h
//  #life
//
//  Created by Griffin Anderson on 11/22/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SELMainViewController.h"
#import "SELColorPicker.h"

@interface SELLocationTableViewController : UITableViewController

@property SELColorPicker *color;
@property BOOL selecting;
@property UITextField *search;
- (void) searchForLocation:(NSString *)query;

@end
