//
//  SELGameViewController.h
//  #life
//
//  Created by Griffin Anderson on 11/19/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SELColorPicker.h"

@interface SELGameViewController : UIViewController <UIGestureRecognizerDelegate>

@property SELColorPicker *acolor;
@property (weak, nonatomic) IBOutlet UILabel *counttotal;

@end
