//
//  SELCaptureViewController.h
//  #life
//
//  Created by Griffin Anderson on 5/19/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBJFocusView.h"
#import "PBJVision.h"
#import "PBJVisionUtilities.h"
#import "SELColorPicker.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <GLKit/GLKit.h>
#import "SELPostViewController.h"
#import "SELPageViewController.h"

@interface PBJVision (SecretBetaFeatures)
- (void)captureVideoFrameAsPhoto;
@end

@interface SELCaptureViewController : UIViewController <SELPostViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property SELColorPicker *color;
- (void)openRoll;

@end
