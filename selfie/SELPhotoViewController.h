//
//  SELPhotoViewController.h
//  #life
//
//  Created by Griffin Anderson on 3/22/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SELPageViewController.h"
#import "SELColorPicker.h"
#import "SELPostViewController.h"
#import "SELImagePickerViewController.h"

@interface SELPhotoViewController : UIViewController<UIImagePickerControllerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, SELPostViewControllerDelegate>

@property SELImagePickerViewController *cameraPicker;
@property SELImagePickerViewController *photoPicker;
@property SELColorPicker *color;
@property UIView *screenView;
- (void)openRoll;
- (void)openCamera;
- (void)reopenCamera;
- (void)addCamera;

@end