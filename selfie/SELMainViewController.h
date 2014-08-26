//
//  SELMainViewController.h
//  selfie
//
//  Created by Griffin Anderson on 7/19/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SELPostViewController.h"
#import "SELColorPicker.h"

@interface SELMainViewController : UIViewController <UITextFieldDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SELPostViewControllerDelegate>

@property SELColorPicker *color;
-(void)dismissKeyboard;
- (void)countLikes;
- (void)showShare:(NSArray *)activityItems;

@end
