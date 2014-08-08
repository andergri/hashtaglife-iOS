//
//  SELUserViewController.h
//  selfie
//
//  Created by Griffin Anderson on 7/25/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SELColorPicker.h"

@interface SELUserViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate>

- (id)init;
@property SELColorPicker *color;

@end
