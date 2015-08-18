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
#import <AssetsLibrary/AssetsLibrary.h>

@interface SELCameraOverlayView ()

@property UIButton *flashButton;
@property UIView *captureButton;
@property UIImage *flashImage;
@property UIImageView *flashImageView;
@property UIImageView *chooseImageView;
@property BOOL flash;
@property UIView *captureView;
@property CAShapeLayer *captureViewLayer;

@end

@implementation SELCameraOverlayView

@synthesize pickerRefrenece;
@synthesize color;
@synthesize flashButton;
@synthesize captureButton;
@synthesize flashImage;
@synthesize flashImageView;
@synthesize flash;
@synthesize chooseImageView;
@synthesize captureView;
@synthesize captureViewLayer;


- (instancetype)initWithFrame:(CGRect)frame color:(SELColorPicker*)acolor {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        NSLog(@"hit camera overlay view");
        
        flash = NO;
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        color = acolor;
        
        //Capture View
        captureView = [[UIButton alloc] initWithFrame:CGRectMake(120, self.frame.size.height - 85, 80, 80)];
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
        flashImageView.contentScaleFactor = 2.5;
        [flashImageView setTintColor:[UIColor whiteColor]];
        [flashButton addSubview:flashImageView];
        
        //Switch Camera
        UIButton *switchButton = [[UIButton alloc] initWithFrame:CGRectMake(260, 0, 55, 55)];
        [self addSubview:switchButton];
        [switchButton addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
        
        //Switch Camera Images
        UIImage *switchImage = [[UIImage imageNamed:@"switch-camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImageView *switchImageView = [[UIImageView alloc] initWithImage:switchImage];
        switchImageView.frame = CGRectMake(15, 7, switchImage.size.width, switchImage.size.height);
        switchImageView.contentMode = UIViewContentModeCenter;
        switchImageView.contentScaleFactor = 2.5;
        [switchImageView setTintColor:[UIColor whiteColor]];
        [switchButton addSubview:switchImageView];
        
        
        //Capture Button
        captureButton = [[UIView alloc] initWithFrame:CGRectMake(128, self.frame.size.height - 77, 64, 64)];
        captureButton.layer.cornerRadius = roundf(captureButton.frame.size.width/2.0);
        captureButton.backgroundColor = [UIColor whiteColor];
        captureButton.userInteractionEnabled = YES;
        [self addSubview:captureButton];
        UITapGestureRecognizer *tapPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takeSelfie)];
        [self.captureButton addGestureRecognizer:tapPress];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(takeVideo:)];
        longPress.minimumPressDuration = 0.3;
        [self.captureButton addGestureRecognizer:longPress];
        
        //[captureButton addTarget:self action:@selector(takeSelfie) forControlEvents:UIControlEventTouchUpInside];
        
        //Exit Button
        /**
        UIButton *exitButton = [[UIButton alloc] initWithFrame:CGRectMake(25, self.frame.size.height - 84, 50, 50)];
        exitButton.layer.cornerRadius = roundf(exitButton.frame.size.width/2.0);
        exitButton.backgroundColor = [UIColor whiteColor];
        [self addSubview:exitButton];
        [exitButton addTarget:self action:@selector(exitCamera) forControlEvents:UIControlEventTouchUpInside];
         **/
        
        //Back Button UI
        /**
        UIImage *backImage = [[UIImage imageNamed:@"exit"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImageView *backImageView = [[UIImageView alloc] initWithImage:backImage];
        backImageView.frame = CGRectMake(9, 9, backImage.size.width, backImage.size.height);
        backImageView.contentMode = UIViewContentModeCenter;
        [backImageView setTintColor:[color getPrimaryColor]];
        [exitButton addSubview:backImageView];
        **/
        /**
        //Choose image Button
        UIButton *chooseButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 70, self.frame.size.height - 84, 50, 50)];
        chooseButton.layer.cornerRadius = roundf(chooseButton.frame.size.width/2.0);
        chooseButton.backgroundColor = [UIColor whiteColor];
        [self addSubview:chooseButton];
        [chooseButton addTarget:self action:@selector(chooseImage) forControlEvents:UIControlEventTouchUpInside];
        
        //Choose image Button UI
        UIImage *chooseImage = [[UIImage imageNamed:@"image"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        chooseImageView = [[UIImageView alloc] initWithImage:chooseImage];
        chooseImageView.frame = CGRectMake(10.5, 10.5, chooseImage.size.width, chooseImage.size.height);
        chooseImageView.contentMode = UIViewContentModeCenter;
        [chooseImageView setTintColor:[color getPrimaryColor]];
        [chooseButton addSubview:chooseImageView];

        [self getLastImage];
         **/
        
        [self startHint];
    }
    return self;
}

- (void) flashState{
    //if([UIImagePickerController isFlashAvailableForCameraDevice:self.pickerRefrenece.cameraDevice]) {

        flash = !flash;
        
        if (flash) {
            self.pickerRefrenece.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
            flashImage = [[UIImage imageNamed:@"on-flash"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }else{
            self.pickerRefrenece.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
            flashImage = [[UIImage imageNamed:@"off-flash"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        flashImageView.image = flashImage;
        flashImageView.contentScaleFactor = 2.5;
    //}
}

- (void) flashAvailable{
    flashButton.hidden = NO;
    
    /**if([UIImagePickerController isFlashAvailableForCameraDevice:self.pickerRefrenece.cameraDevice]) {
        flashButton.hidden = NO;
    } else{
        flashButton.hidden = YES;
    }
     **/
}

- (void) switchCamera{
    
    [UIView transitionWithView:self.pickerRefrenece.view
                      duration:1.0
                       options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        if ( self.pickerRefrenece.cameraDevice == UIImagePickerControllerCameraDeviceRear ) {
                            
                            self.pickerRefrenece.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                        
                        } else {
                            
                            self.pickerRefrenece.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                        }
                    } completion:^(BOOL finished) {
                        [self flashAvailable];
                    }];
}
- (void) takeSelfie {
    
    captureButton.backgroundColor = [color getPrimaryColor];
    [UIView animateWithDuration:0.8f
                          delay:0.2f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         captureButton.backgroundColor = [UIColor whiteColor];
                     } completion:^(BOOL finished){
                         if (finished) {
                            captureButton.backgroundColor = [UIColor whiteColor];
                         }
    }];
    
    
    if (self.pickerRefrenece.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
        
        if (flash) {
            
                CGFloat oldBrightness = [UIScreen mainScreen].brightness;
                UIWindow *window = [UIApplication sharedApplication].keyWindow;
                UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, window.frame.size.width, window.frame.size.height)];
            
            
            
                [UIView animateWithDuration:.5f
                                      delay:0.0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:^{
                     
                     [window addSubview:view];
                     [[UIScreen mainScreen] setBrightness:1.0];
                     view.backgroundColor = [UIColor whiteColor];
                     view.alpha = 1.0f;
                 
                 } completion:^(BOOL finished){
                     
                     if (finished) {
                         
                         //[self.pickerRefrenece takePicture];
                         pickerRefrenece.videoMaximumDuration = .001;
                         [pickerRefrenece startVideoCapture];
                         [pickerRefrenece stopVideoCapture];
                         [UIView beginAnimations:nil context:nil];
                         [UIView setAnimationBeginsFromCurrentState:YES];
                         [UIView setAnimationCurve:UIViewAnimationCurveLinear];
                         [UIView setAnimationDuration:1.0f];
                         view.alpha = 0.0;
                         [view removeFromSuperview];
                         [[UIScreen mainScreen]setBrightness:oldBrightness];
                         [UIView commitAnimations];
                     }
                 }];
            
        }else{
            pickerRefrenece.videoMaximumDuration = .001;
            [pickerRefrenece startVideoCapture];
            [pickerRefrenece stopVideoCapture];
            //[self.pickerRefrenece takePicture];
        }
    }else{
        pickerRefrenece.videoMaximumDuration = .001;
        [pickerRefrenece startVideoCapture];
        [pickerRefrenece stopVideoCapture];
        //[self.pickerRefrenece takePicture];
    }
}


- (void) takeVideo:(UILongPressGestureRecognizer *)gestureRecognizer  {
    
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        [self drawCircle];
        captureButton.backgroundColor = [color getPrimaryColor];
        [pickerRefrenece startVideoCapture];
    } else {
        if (gestureRecognizer.state == UIGestureRecognizerStateCancelled
            || gestureRecognizer.state == UIGestureRecognizerStateFailed
            || gestureRecognizer.state == UIGestureRecognizerStateEnded) {

            [pickerRefrenece stopVideoCapture];
            [captureViewLayer removeFromSuperlayer];
            captureButton.backgroundColor = [UIColor whiteColor];
            int distance = 8;
            captureButton.frame = CGRectMake(captureButton.frame.origin.x + (distance / 2), captureButton.frame.origin.y + (distance / 2), captureButton.frame.size.width - distance, captureButton.frame.size.width - distance);
            captureButton.layer.cornerRadius = roundf(captureButton.frame.size.width/2.0);
                NSLog(@"end video");
        }
    }
}



- (void) exitCamera {
    self.pickerRefrenece.view.hidden = YES;
    self.pickerRefrenece.parentViewController.view.hidden = YES;
    //[self.pickerRefrenece dismissViewControllerAnimated:NO completion:nil];
}

- (void) chooseImage {
    
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        return;
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString *)kUTTypeImage]) {
        
        self.bpickerRefrenece.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
               && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString *)kUTTypeImage]) {
        
        self.bpickerRefrenece.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        
    } else {
        return;
    }
    [self.pickerRefrenece presentViewController:self.bpickerRefrenece animated:NO completion:nil];
}


// camera roll image

- (void) getLastImage{
    
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    NSLog(@"status %ld", (long)(long)status);
    if (status != ALAuthorizationStatusAuthorized) {
    }else{
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                     usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                         if (nil != group) {
                                             // be sure to filter the group so you only get photos
                                             [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                                             
                                             
                                             [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:group.numberOfAssets - 1]
                                                                     options:0
                                                                  usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                                                      if (nil != result) {
                                                                          ALAssetRepresentation *repr = [result defaultRepresentation];
                                                                          // this is the most recent saved photo
                                                                          UIImage *img = [UIImage imageWithCGImage:[repr fullResolutionImage]];
                                                                          // we only need the first (most recent) photo -- stop the enumeration
                                                                          *stop = YES;
                                                                          [self setImageViewForImage:img];
                                                                          
                                                                      }
                                                                  }];
                                         }
                                         
                                         *stop = NO;
                                     } failureBlock:^(NSError *error) {
                                         NSLog(@"error: %@", error);
                                     }];
    }
    
}

- (void) setImageViewForImage:(UIImage *) img{
    
    chooseImageView.image = img;
    chooseImageView.contentMode = UIViewContentModeScaleAspectFill;
    chooseImageView.clipsToBounds = YES;
    chooseImageView.frame = CGRectMake(2, 2, 46, 46);
    chooseImageView.layer.cornerRadius = roundf(chooseImageView.frame.size.width/2.0);
    
}

- (void)drawCircle {
    
    int distance = 8;
    [UIView transitionWithView:self
                      duration:0.4
                       options:UIViewAnimationOptionAllowAnimatedContent
                    animations:^{
                        captureButton.frame = CGRectMake(captureButton.frame.origin.x - (distance / 2), captureButton.frame.origin.y - (distance / 2), captureButton.frame.size.width + distance, captureButton.frame.size.width + distance);
                        captureButton.layer.cornerRadius = roundf(captureButton.frame.size.width/2.0);
                    } completion:^(BOOL finished) {
                    }];
    
    int radius = 38;
    captureViewLayer = [CAShapeLayer layer];
    captureViewLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius) cornerRadius:radius].CGPath;
    captureViewLayer.position = CGPointMake(CGRectGetMidX(self.captureView.frame)-radius,
                                  CGRectGetMidY(self.captureView.frame)-radius);
    
    captureViewLayer.fillColor = [UIColor clearColor].CGColor;
    captureViewLayer.strokeColor = ((UIColor*)[[color getColorArray] objectAtIndex:0]).CGColor;
    captureViewLayer.lineWidth = 4.2;
    
    [self.layer addSublayer:captureViewLayer];
    
    // Configure animation
    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    drawAnimation.duration            = 10.0;
    drawAnimation.repeatCount         = 1.0;
    drawAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    drawAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [captureViewLayer addAnimation:drawAnimation forKey:@"drawCircleAnimation"];
}


// Hint TEXT
- (void) startHint{

    NSLog(@"start Hint");
    UILabel *hint = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    hint.text = @"Hold for Video";
    hint.font = [UIFont systemFontOfSize:13];
    hint.textColor = [UIColor whiteColor];
    hint.alpha = 0.0;
    [self addSubview:hint];
    
    [UIView animateWithDuration:1.0 delay:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        hint.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            hint.alpha = 1.0;
        } completion:^(BOOL finished) {
            hint.alpha = 0.0;
            NSLog(@"end Hint");
        }];
    }];
}


@end
