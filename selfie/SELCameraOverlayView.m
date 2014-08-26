//
//  SELCameraOverlayView.m
//  selfie
//
//  Created by Griffin Anderson on 7/23/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import "SELCameraOverlayView.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface SELCameraOverlayView ()

@property UIButton *flashButton;
@property UIImage *flashImage;
@property UIImageView *flashImageView;
@property BOOL flash;

@end

@implementation SELCameraOverlayView

@synthesize pickerRefrenece;
@synthesize color;
@synthesize flashButton;
@synthesize flashImage;
@synthesize flashImageView;
@synthesize flash;


- (instancetype)initWithFrame:(CGRect)frame color:(SELColorPicker*)color {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        flash = NO;
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        
        //Capture View
        UIView *captureView = [[UIButton alloc] initWithFrame:CGRectMake(120, self.frame.size.height - 100, 80, 80)];
        captureView.layer.cornerRadius = roundf(captureView.frame.size.width/2.0);
        captureView.layer.borderColor = [UIColor whiteColor].CGColor;
        captureView.layer.borderWidth = 4.0f;
        [self addSubview:captureView];
        
        
        //Flash Camera
        flashButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 55, 55)];
        [self addSubview:flashButton];
        [flashButton addTarget:self action:@selector(flashState) forControlEvents:UIControlEventTouchUpInside];
        self.pickerRefrenece.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        
        //Switch Camera Images
        flashImage = [[UIImage imageNamed:@"off-flash"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        flashImageView = [[UIImageView alloc] initWithImage:flashImage];
        flashImageView.frame = CGRectMake(15, 7, flashImage.size.width, flashImage.size.height);
        flashImageView.contentMode = UIViewContentModeCenter;
        [flashImageView setTintColor:[UIColor whiteColor]];
        [flashButton addSubview:flashImageView];
        
        //Switch Camera
        UIButton *switchButton = [[UIButton alloc] initWithFrame:CGRectMake(260, 0, 55, 55)];
        [self addSubview:switchButton];
        [switchButton addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
        
        //Switch Camera Images
        UIImage *switchImage = [[UIImage imageNamed:@"switch-camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImageView *switchImageView = [[UIImageView alloc] initWithImage:switchImage];
        switchImageView.frame = CGRectMake(7, 7, switchImage.size.width, switchImage.size.height);
        switchImageView.contentMode = UIViewContentModeCenter;
        [switchImageView setTintColor:[UIColor whiteColor]];
        [switchButton addSubview:switchImageView];
        
        
        //Capture Button
        UIButton *captureButton = [[UIButton alloc] initWithFrame:CGRectMake(128, self.frame.size.height - 92, 64, 64)];
        captureButton.layer.cornerRadius = roundf(captureButton.frame.size.width/2.0);
        captureButton.backgroundColor = [UIColor whiteColor];
        [self addSubview:captureButton];
        [captureButton addTarget:self action:@selector(takeSelfie) forControlEvents:UIControlEventTouchUpInside];
        
        //Exit Button
        UIButton *exitButton = [[UIButton alloc] initWithFrame:CGRectMake(25, self.frame.size.height - 84, 50, 50)];
        exitButton.layer.cornerRadius = roundf(exitButton.frame.size.width/2.0);
        exitButton.backgroundColor = [UIColor whiteColor];
        [self addSubview:exitButton];
        [exitButton addTarget:self action:@selector(exitCamera) forControlEvents:UIControlEventTouchUpInside];
        
        //Back Button UI
        UIImage *backImage = [[UIImage imageNamed:@"exit"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImageView *backImageView = [[UIImageView alloc] initWithImage:backImage];
        backImageView.frame = CGRectMake(9, 9, backImage.size.width, backImage.size.height);
        backImageView.contentMode = UIViewContentModeCenter;
        [backImageView setTintColor:[color getPrimaryColor]];
        [exitButton addSubview:backImageView];
        
        //Choose image Button
        UIButton *chooseButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 70, self.frame.size.height - 84, 50, 50)];
        chooseButton.layer.cornerRadius = roundf(chooseButton.frame.size.width/2.0);
        chooseButton.backgroundColor = [UIColor whiteColor];
        [self addSubview:chooseButton];
        [chooseButton addTarget:self action:@selector(chooseImage) forControlEvents:UIControlEventTouchUpInside];
        
        //Choose image Button UI
        UIImage *chooseImage = [[UIImage imageNamed:@"image"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImageView *chooseImageView = [[UIImageView alloc] initWithImage:chooseImage];
        chooseImageView.frame = CGRectMake(10.5, 10.5, chooseImage.size.width, chooseImage.size.height);
        chooseImageView.contentMode = UIViewContentModeCenter;
        [chooseImageView setTintColor:[color getPrimaryColor]];
        [chooseButton addSubview:chooseImageView];

    }
    return self;
}

- (void) flashState{
    if([UIImagePickerController isFlashAvailableForCameraDevice:self.pickerRefrenece.cameraDevice]) {

        flash = !flash;
        
        if (flash) {
            self.pickerRefrenece.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
            flashImage = [[UIImage imageNamed:@"on-flash"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }else{
            self.pickerRefrenece.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
            flashImage = [[UIImage imageNamed:@"off-flash"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        flashImageView.image = flashImage;
    }
}

- (void) flashAvailable{
    if([UIImagePickerController isFlashAvailableForCameraDevice:self.pickerRefrenece.cameraDevice]) {
        flashButton.hidden = NO;
    } else{
        flashButton.hidden = YES;
    }
}

- (void) switchCamera{
    [UIView transitionWithView:self.pickerRefrenece.view
                      duration:1.0
                       options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        if ( self.pickerRefrenece.cameraDevice == UIImagePickerControllerCameraDeviceRear )
                            self.pickerRefrenece.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                        else
                            self.pickerRefrenece.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                    } completion:^(BOOL finished) {
                        [self flashAvailable];
                    }];
}
- (void) takeSelfie {
    [self.pickerRefrenece takePicture];
}

- (void) exitCamera {
    [self.pickerRefrenece dismissViewControllerAnimated:NO completion:nil];
}

- (void) chooseImage {
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        return;
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString *)kUTTypeImage]) {
        
        self.pickerRefrenece.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.pickerRefrenece.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
               && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString *)kUTTypeImage]) {
        
        self.pickerRefrenece.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        self.pickerRefrenece.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else {
        return;
    }
}

@end
