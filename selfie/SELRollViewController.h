//
//  SELRollViewController.h
//  #life
//
//  Created by Griffin Anderson on 9/5/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SELColorPicker.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <GLKit/GLKit.h>
#import "SELPostViewController.h"
#import "SELPageViewController.h"
#import "SELRollViewController.h"

@interface SELRollViewController : UIViewController <SELPostViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property SELColorPicker *color;
- (void)openRoll;

@end
