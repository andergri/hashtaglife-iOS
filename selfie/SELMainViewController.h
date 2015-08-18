//
//  SELMainViewController.h
//  selfie
//
//  Created by Griffin Anderson on 7/19/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SELColorPicker.h"
#import "SELPageViewController.h"
#import "SELSelifeViewController.h"

@interface SELMainViewController : UIViewController <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property SELColorPicker *color;
@property BOOL CURRENTLOADING;
-(void)dismissKeyboard;
- (void)showCameraIcon:(BOOL)show;
- (void)updateList;

@end

