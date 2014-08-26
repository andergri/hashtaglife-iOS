//
//  SELCameraObject.m
//  #life
//
//  Created by Griffin Anderson on 8/20/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import "SELCameraObject.h"
#import "SELCameraOverlayView.h"

@interface SELCameraObject()

@property SELColorPicker *acolor;

@end

@implementation SELCameraObject

@synthesize imagePicker;
@synthesize acolor;

- (void) initCameraView:(UIView *)view color:(SELColorPicker *)color{
    
    acolor = color;
    
    view.layer.cornerRadius = roundf(view.frame.size.width/2.0);
    view.layer.borderColor = [UIColor whiteColor].CGColor;
    view.layer.borderWidth = 2.0f;
    view.backgroundColor = [color getPrimaryColor];
    
    //Camera Button UI
    UIImage *cameraImage = [[UIImage imageNamed:@"camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *cameraImageView = [[UIImageView alloc] initWithImage:cameraImage];
    cameraImageView.frame = CGRectMake(20, 20, cameraImage.size.width, cameraImage.size.height);
    cameraImageView.contentMode = UIViewContentModeCenter;
    [cameraImageView setTintColor:[UIColor colorWithWhite:1. alpha:1]];
    [view addSubview:cameraImageView];

}

- (void) initCamera:(UIView *)view{
    
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    imagePicker.showsCameraControls = NO;
    imagePicker.navigationBarHidden = YES;
    imagePicker.toolbarHidden = YES;
    imagePicker.allowsEditing = YES;
    imagePicker.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    imagePicker.hidesBottomBarWhenPushed = YES;
    
    CGSize screenBounds = [UIScreen mainScreen].bounds.size;
    CGFloat cameraAspectRatio = 4.0f/3.0f;
    CGFloat camViewHeight = screenBounds.width * cameraAspectRatio;
    CGFloat scale = screenBounds.height / camViewHeight;
    imagePicker.cameraViewTransform = CGAffineTransformMakeTranslation(0, (screenBounds.height - camViewHeight) / 2.0);
    imagePicker.cameraViewTransform = CGAffineTransformScale(imagePicker.cameraViewTransform, scale, scale);
    
    
    SELCameraOverlayView *overlay = [[SELCameraOverlayView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height) color:acolor];
    
    overlay.pickerRefrenece = imagePicker;
    overlay.frame = imagePicker.cameraOverlayView.frame;
    overlay.color = acolor;
    
    //[imagePicker.view addSubview:overlay];
    imagePicker.cameraOverlayView = overlay;
}

@end
