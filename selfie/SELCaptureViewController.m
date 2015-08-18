//
//  SELCaptureViewController.m
//  #life
//
//  Created by Griffin Anderson on 5/19/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import "SELCaptureViewController.h"
#import "SELEditImage.h"
#import "SELCurveTextView.h"

@interface ExtendedHitButton : UIButton

+ (instancetype)extendedHitButton;

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event;

@end

@implementation ExtendedHitButton

+ (instancetype)extendedHitButton
{
    return (ExtendedHitButton *)[ExtendedHitButton buttonWithType:UIButtonTypeCustom];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect relativeFrame = self.bounds;
    UIEdgeInsets hitTestEdgeInsets = UIEdgeInsetsMake(-35, -35, -35, -35);
    CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, hitTestEdgeInsets);
    return CGRectContainsPoint(hitFrame, point);
}

@end

@interface SELCaptureViewController () <
UIGestureRecognizerDelegate,
PBJVisionDelegate,
UIAlertViewDelegate>
{
    
    UIView *_captureView;
    UIView *_captureButton;
    CAShapeLayer *_captureViewLayer;
    
    UIButton *_flipButton;
    UIButton *_flashButton;
    UIButton *_focusButton;
    UIButton *_frameRateButton;
    
    UIView *_previewView;
    AVCaptureVideoPreviewLayer *_previewLayer;
    PBJFocusView *_focusView;
    GLKViewController *_effectsViewController;
    
    SELCurveTextView *_instructionLabel;
    UILongPressGestureRecognizer *_longPressGestureRecognizer;
    UITapGestureRecognizer *_focusTapGestureRecognizer;
    UITapGestureRecognizer *_photoTapGestureRecognizer;
    
    UIImagePickerController *rollPicker;
    
    BOOL _recording;
    
    ALAssetsLibrary *_assetLibrary;
    __block NSDictionary *_currentVideo;
    __block NSDictionary *_currentPhoto;
    
    SELPostViewController *_postViewController;
}
    @property UIImagePickerController *rollPicker;

@end

@implementation SELCaptureViewController

@synthesize color;
@synthesize rollPicker;

#pragma mark - UIViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - init

- (void)dealloc
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    _longPressGestureRecognizer.delegate = nil;
    _focusTapGestureRecognizer.delegate = nil;
    _photoTapGestureRecognizer.delegate = nil;
}

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _assetLibrary = [[ALAssetsLibrary alloc] init];
    
    // preview and AV layer
    _previewView = [[UIView alloc] initWithFrame:CGRectZero];
    _previewView.backgroundColor = [UIColor blackColor];
    CGRect previewFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    _previewView.frame = previewFrame;
    _previewLayer = [[PBJVision sharedInstance] previewLayer];
    _previewLayer.frame = _previewView.bounds;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_previewView.layer addSublayer:_previewLayer];
    
    // instruction label
    _instructionLabel = [[SELCurveTextView alloc] initWithFrame:CGRectMake(0, 5, 80, 80)                                                                     font:[UIFont fontWithName:@"HelveticaNeue-Medium" size:10.0f]
                                                           text:@"  hold for video"
                                                         radius:48
                                                        arcSize:78
                                                          color:[UIColor colorWithWhite:1 alpha:.8]];
    _instructionLabel.backgroundColor = [UIColor clearColor];
    CGPoint labelCenter = _previewView.center;
    labelCenter.y += ((CGRectGetHeight(_previewView.frame) * 0.5f) - 64.0f);
    _instructionLabel.center = labelCenter;
    [_previewView addSubview:_instructionLabel];
    
    // Capture View border
    _captureView = [[UIButton alloc] initWithFrame:CGRectMake(120, self.view.frame.size.height - 85, 80, 80)];
    _captureView.layer.cornerRadius = roundf(_captureView.frame.size.width/2.0);
    _captureView.layer.borderColor = [UIColor whiteColor].CGColor;
    _captureView.layer.borderWidth = 4.0f;
    [_previewView addSubview:_captureView];
    
    // Capture button
    _captureButton = [[UIView alloc] initWithFrame:CGRectMake(128, self.view.frame.size.height - 77, 64, 64)];
    _captureButton.layer.cornerRadius = roundf(_captureButton.frame.size.width/2.0);
    _captureButton.backgroundColor = [UIColor whiteColor];
    _captureButton.userInteractionEnabled = YES;
    [_previewView addSubview:_captureButton];
    
    // onion skin
    _effectsViewController = [[GLKViewController alloc] init];
    _effectsViewController.preferredFramesPerSecond = 60;
    GLKView *view = (GLKView *)_effectsViewController.view;
    CGRect viewFrame = _previewView.bounds;
    view.frame = viewFrame;
    view.context = [[PBJVision sharedInstance] context];
    view.contentScaleFactor = [[UIScreen mainScreen] scale];
    view.alpha = 0.5f;
    view.hidden = YES;
    [[PBJVision sharedInstance] setPresentationFrame:_previewView.frame];
    [_previewView addSubview:_effectsViewController.view];
    
    // focus view
    _focusView = [[PBJFocusView alloc] initWithFrame:CGRectZero];
    
    // touch to record
    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handleLongPressGestureRecognizer:)];
    _longPressGestureRecognizer.delegate = self;
    _longPressGestureRecognizer.minimumPressDuration = 0.3;
    _longPressGestureRecognizer.allowableMovement = 10.0f;
    [_captureButton addGestureRecognizer:_longPressGestureRecognizer];
    
    // tap to focus
    _focusTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleFocusTapGesterRecognizer:)];
    _focusTapGestureRecognizer.delegate = self;
    _focusTapGestureRecognizer.numberOfTapsRequired = 1;
    _focusTapGestureRecognizer.enabled = NO;
    [_previewView addGestureRecognizer:_focusTapGestureRecognizer];
    
    // touch to photo
    _photoTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTapPressGestureRecognizer:)];
    _photoTapGestureRecognizer.delegate = self;
    _photoTapGestureRecognizer.numberOfTapsRequired = 1;
    _focusTapGestureRecognizer.enabled = YES;
    [_captureButton addGestureRecognizer:_photoTapGestureRecognizer];
    
    // flash button
    _flashButton = [ExtendedHitButton extendedHitButton];
    UIImage *flashImage = [[UIImage imageNamed:@"off-flash"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_flashButton setImage:flashImage forState:UIControlStateNormal];
    [_flashButton setImage:[[UIImage imageNamed:@"on-flash"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    CGRect flashFrame = _flashButton.frame;
    _flashButton.imageView.contentScaleFactor = 2.5;
    [_flashButton setTintColor:[UIColor whiteColor]];
    flashFrame.origin = CGPointMake(20.0f, 15.0f);
    flashFrame.size = flashImage.size;
    _flashButton.frame = flashFrame;
    [_flashButton addTarget:self action:@selector(_handleFlashButton:) forControlEvents:UIControlEventTouchUpInside];
    [_previewView addSubview:_flashButton];
    
    // flip button
    _flipButton = [ExtendedHitButton extendedHitButton];
    UIImage *flipImage = [[UIImage imageNamed:@"switch-camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_flipButton setImage:flipImage forState:UIControlStateNormal];
    _flipButton.contentScaleFactor = 2.5;
    [_flipButton setTintColor:[UIColor whiteColor]];
    CGRect flipFrame = _flipButton.frame;
    flipFrame.origin = CGPointMake(CGRectGetWidth(self.view.frame) - 60.0f, 15.0f);
    flipFrame.size = flipImage.size;
    _flipButton.frame = flipFrame;
    [_flipButton addTarget:self action:@selector(_handleFlipButton:) forControlEvents:UIControlEventTouchUpInside];
    [_previewView addSubview:_flipButton];
    
    // focus mode button
    _focusButton = [ExtendedHitButton extendedHitButton];
    CGRect focusFrame = _focusButton.frame;
    focusFrame.origin = CGPointMake((CGRectGetWidth(self.view.bounds) * 0.5f) - (focusFrame.size.width * 0.5f), 16.0f);
    _focusButton.frame = focusFrame;
    [_focusButton addTarget:self action:@selector(_handleFocusButton:) forControlEvents:UIControlEventTouchUpInside];
    [_previewView addSubview:_focusButton];
    
    if ([[PBJVision sharedInstance] supportsVideoFrameRate:120]) {
        // set faster frame rate
    }
    
    // Setup roll picker
    [self setup];
    
    // Set Bar
    [(SELPageViewController*)self.parentViewController setCameraBar:_previewView];
    
    // Post View Controller
    _postViewController = [[SELPostViewController alloc] init];
    _postViewController.delegate = self;
    BOOL doesContainPost = [self.view.subviews containsObject:_postViewController.view];
    if (!doesContainPost) {
        _postViewController.view.frame = self.view.frame;
        [_previewView addSubview:_postViewController.view];
        [self addChildViewController:_postViewController];
        [_postViewController didMoveToParentViewController:self];
    }
    _postViewController.view.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self _resetCapture];
    [[PBJVision sharedInstance] startPreview];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[PBJVision sharedInstance] freezePreview];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - private start/stop helper methods

- (void)_startCapture
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _instructionLabel.alpha = 0;
        _instructionLabel.transform = CGAffineTransformMakeTranslation(0, 8.0f);
    } completion:^(BOOL finished) {
    }];
    [[PBJVision sharedInstance] startVideoCapture];
}

- (void)_pauseCapture
{
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _instructionLabel.alpha = 1;
        _instructionLabel.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
    }];
    
    [[PBJVision sharedInstance] pauseVideoCapture];
}

- (void)_resumeCapture
{
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _instructionLabel.alpha = 0;
        _instructionLabel.transform = CGAffineTransformMakeTranslation(0, 8.0f);
    } completion:^(BOOL finished) {
    }];
    
    [[PBJVision sharedInstance] resumeVideoCapture];
    _effectsViewController.view.hidden = YES;
}

- (void)_endCapture
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[PBJVision sharedInstance] endVideoCapture];
    _effectsViewController.view.hidden = YES;
}

- (void)_resetCapture {
    
    [self resetDrawing];
    
    _longPressGestureRecognizer.enabled = YES;
    
    PBJVision *vision = [PBJVision sharedInstance];
    vision.delegate = self;
    
    if ([vision isCameraDeviceAvailable:PBJCameraDeviceBack]) {
        vision.cameraDevice = PBJCameraDeviceBack;
        _flipButton.hidden = NO;
    } else {
        vision.cameraDevice = PBJCameraDeviceFront;
        _flipButton.hidden = YES;
    }
    
    vision.cameraMode = PBJCameraModeVideo;
    //vision.cameraMode = PBJCameraModePhoto; // PHOTO: uncomment to test photo capture
    vision.cameraOrientation = PBJCameraOrientationPortrait;
    vision.focusMode = PBJFocusModeContinuousAutoFocus;
    vision.outputFormat = PBJOutputFormatPreset;
    vision.videoRenderingEnabled = YES;

    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone){
        if ([[UIScreen mainScreen] bounds].size.height == 568.0f){
           vision.additionalCompressionProperties = @{AVVideoProfileLevelKey : AVVideoProfileLevelH264HighAutoLevel};
        }else{
            vision.additionalCompressionProperties = @{AVVideoProfileLevelKey : AVVideoProfileLevelH264MainAutoLevel};
        }
    }
    vision.videoBitRate = (PBJVideoBitRate640x480 / 2.2);
    vision.captureSessionPreset = AVCaptureSessionPreset1280x720;
    vision.defaultVideoThumbnails = YES;
    vision.maximumCaptureDuration = CMTimeMakeWithSeconds(7.8, 600); // ~ 5 seconds
}

#pragma mark - UIButton

- (void)_handleFlipButton:(UIButton *)button {
    
    PBJVision *vision = [PBJVision sharedInstance];
    [UIView transitionWithView:_previewView
                      duration:1.0
                       options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        vision.cameraDevice = vision.cameraDevice == PBJCameraDeviceBack ? PBJCameraDeviceFront : PBJCameraDeviceBack;
                    } completion:^(BOOL finished) {
                    }];
}

- (void)_handleFlashButton:(UIButton *)button {
    
    _flashButton.selected = !_flashButton.selected;
}

- (void)_handleFocusButton:(UIButton *)button
{
    _focusButton.selected = !_focusButton.selected;
    
    if (_focusButton.selected) {
        _focusTapGestureRecognizer.enabled = YES;
        
    } else {
        if (_focusView && [_focusView superview]) {
            [_focusView stopAnimation];
        }
        _focusTapGestureRecognizer.enabled = NO;
    }
    
    [UIView animateWithDuration:0.15f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _instructionLabel.alpha = 0;
    } completion:^(BOOL finished) {
        _instructionLabel.text = _focusButton.selected ? NSLocalizedString(@"Touch to focus", @"Touch to focus") :
        NSLocalizedString(@"Touch and hold to record", @"Touch and hold to record");
        [UIView animateWithDuration:0.15f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _instructionLabel.alpha = 1;
        } completion:^(BOOL finished1) {
        }];
    }];
}

- (void)_handleFrameRateChangeButton:(UIButton *)button
{
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self _resetCapture];
}

#pragma mark - UIGestureRecognizer

- (void)_handleLongPressGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    
    PBJVision *vision = [PBJVision sharedInstance];
    vision.maximumCaptureDuration = CMTimeMakeWithSeconds(7.8, 600);
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:{
            if (!_recording){
                vision.flashMode = (_flashButton.selected == YES) ? PBJFlashModeOn : PBJFlashModeOff;
                [self drawCircleColor];
                [self _startCapture];
            }else
                [self _resumeCapture];
            break;
        }
        case UIGestureRecognizerStateEnded:{
            if (_recording){
                vision.flashMode = PBJFlashModeOff;
                [self _endCapture];
                [self resetDrawing];
                [self changeCenterCircleColor];
            }
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:{
            vision.flashMode = PBJFlashModeOff;
            [self _pauseCapture];
            [self resetDrawing];
            [self changeCenterCircleColor];
            break;
        }
        default:
            break;
    }
}


- (void)_handleTapPressGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer{
    
    [self changeCenterCircleColor];
    
    PBJVision *vision = [PBJVision sharedInstance];
    vision.maximumCaptureDuration = CMTimeMakeWithSeconds(.0001, 600);
    //[vision captureVideoFrameAsPhoto];
    if (vision.cameraDevice == PBJCameraDeviceBack){
        vision.flashMode = (_flashButton.selected == YES) ? PBJFlashModeOn : PBJFlashModeOff;
        vision.flashMode = PBJFlashModeOff;
        [self _startCapture];
        vision.flashMode = (_flashButton.selected == YES) ? PBJFlashModeOn : PBJFlashModeOff;
        vision.flashMode = PBJFlashModeOff;
        return;
    }else if(_flashButton.selected == YES){
        
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
                                 [self _startCapture];
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
        [self _startCapture];
    }
}

- (void)_handleFocusTapGesterRecognizer:(UIGestureRecognizer *)gestureRecognizer{

    CGPoint tapPoint = [gestureRecognizer locationInView:_previewView];
    
    // auto focus is occuring, display focus view
    CGPoint point = tapPoint;
    
    CGRect focusFrame = _focusView.frame;
#if defined(__LP64__) && __LP64__
    focusFrame.origin.x = rint(point.x - (focusFrame.size.width * 0.5));
    focusFrame.origin.y = rint(point.y - (focusFrame.size.height * 0.5));
#else
    focusFrame.origin.x = rintf(point.x - (focusFrame.size.width * 0.5f));
    focusFrame.origin.y = rintf(point.y - (focusFrame.size.height * 0.5f));
#endif
    [_focusView setFrame:focusFrame];
    
    [_previewView addSubview:_focusView];
    [_focusView startAnimation];
    
    CGPoint adjustPoint = [PBJVisionUtilities convertToPointOfInterestFromViewCoordinates:tapPoint inFrame:_previewView.frame];
    [[PBJVision sharedInstance] focusExposeAndAdjustWhiteBalanceAtAdjustedPoint:adjustPoint];
}

#pragma mark - PBJVisionDelegate

// session

- (void)visionSessionWillStart:(PBJVision *)vision
{
}

- (void)visionSessionDidStart:(PBJVision *)vision
{
    if (![_previewView superview]) {
        [self.view addSubview:_previewView];
    }
}

- (void)visionSessionDidStop:(PBJVision *)vision
{
    [_previewView removeFromSuperview];
}

- (void)visionSessionWasInterrupted:(PBJVision *)vision{
}
- (void)visionSessionInterruptionEnded:(PBJVision *)vision{
    [self.view setNeedsDisplay];
}

// preview

- (void)visionSessionDidStartPreview:(PBJVision *)vision
{
    
}

- (void)visionSessionDidStopPreview:(PBJVision *)vision
{
}

// device

- (void)visionCameraDeviceWillChange:(PBJVision *)vision
{
}

- (void)visionCameraDeviceDidChange:(PBJVision *)vision
{
}

// mode

- (void)visionCameraModeWillChange:(PBJVision *)vision
{
}

- (void)visionCameraModeDidChange:(PBJVision *)vision
{
}

// format

- (void)visionOutputFormatWillChange:(PBJVision *)vision
{
}

- (void)visionOutputFormatDidChange:(PBJVision *)vision
{
}

- (void)vision:(PBJVision *)vision didChangeCleanAperture:(CGRect)cleanAperture
{
}

// focus / exposure

- (void)visionWillStartFocus:(PBJVision *)vision
{
}

- (void)visionDidStopFocus:(PBJVision *)vision
{
    if (_focusView && [_focusView superview]) {
        [_focusView stopAnimation];
    }
}

- (void)visionWillChangeExposure:(PBJVision *)vision
{
}

- (void)visionDidChangeExposure:(PBJVision *)vision
{
    if (_focusView && [_focusView superview]) {
        [_focusView stopAnimation];
    }
}

// flash

- (void)visionDidChangeFlashMode:(PBJVision *)vision
{
    NSLog(@"Flash mode did change");
}

// photo

- (void)visionWillCapturePhoto:(PBJVision *)vision
{
}

- (void)visionDidCapturePhoto:(PBJVision *)vision
{
}

- (void)vision:(PBJVision *)vision capturedPhoto:(NSDictionary *)photoDict error:(NSError *)error {
    if (error) {
        // handle error properly
        return;
    }
    _currentPhoto = photoDict;
    // save to library
    UIImage *image = _currentPhoto[PBJVisionPhotoImageKey];
    NSLog(@"got image %@", image);
    UIImage *editImage = [SELEditImage scaleAndRotateImage:image size:self.view.frame.size];
    [self sendPhoto:editImage videoURL:nil];
    
    _currentPhoto = nil;
}

// video capture

- (void)visionDidStartVideoCapture:(PBJVision *)vision {
    _recording = YES;
}

- (void)visionDidPauseVideoCapture:(PBJVision *)vision {
}

- (void)visionDidResumeVideoCapture:(PBJVision *)vision {
}

- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error {
    _recording = NO;
    [self resetDrawing];
    
    if (error && [error.domain isEqual:PBJVisionErrorDomain] && error.code == PBJVisionErrorCancelled) {
        NSLog(@"recording session cancelled");
        return;
    } else if (error) {
        NSLog(@"encounted an error in video capture (%@)", error);
        return;
    }
    
    _currentVideo = videoDict;
    
    NSLog(@"captured video %@", [_currentVideo  objectForKey:PBJVisionVideoCapturedDurationKey]);
    
    if((CGFloat)[[_currentVideo  objectForKey:PBJVisionVideoCapturedDurationKey] floatValue] < .6){
        UIImage *image = [[_currentVideo  objectForKey:PBJVisionVideoThumbnailArrayKey] objectAtIndex:0];
        UIImage *editImage = [SELEditImage scaleAndRotateImage:image size:self.view.frame.size];
        [self sendPhoto:editImage videoURL:nil];
    }else{
        UIImage *image = [[_currentVideo  objectForKey:PBJVisionVideoThumbnailArrayKey] objectAtIndex:0];
        UIImage *editImage = [SELEditImage scaleAndRotateImage:image size:self.view.frame.size];
        NSString *videoPath = [_currentVideo  objectForKey:PBJVisionVideoPathKey];
        
        //
        NSData *assetData = [NSData dataWithContentsOfFile:videoPath];
        NSLog(@"File size is : %.2f MB",(float)assetData.length/1024.0f/1024.0f);
        //
        
        [self sendPhoto:editImage videoURL:videoPath];
    }
    
    /**[_assetLibrary writeVideoAtPathToSavedPhotosAlbum:[NSURL URLWithString:videoPath] completionBlock:^(NSURL *assetURL, NSError *error1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Video Saved!" message: @"Saved to the camera roll."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }];**/
}

// progress

- (void)vision:(PBJVision *)vision didCaptureVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    //    NSLog(@"captured audio (%f) seconds", vision.capturedAudioSeconds);
}

- (void)vision:(PBJVision *)vision didCaptureAudioSample:(CMSampleBufferRef)sampleBuffer {
    //    NSLog(@"captured video (%f) seconds", vision.capturedVideoSeconds);
}

/** Image Picker **/

- (void) setup{
    
    @try {
        
    
        // Setup Roll
        rollPicker = [[UIImagePickerController alloc] init];
        rollPicker.view.tag = 1;
        rollPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        rollPicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        rollPicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        rollPicker.modalPresentationStyle = UIModalPresentationFullScreen;
        rollPicker.showsCameraControls = NO;
        rollPicker.navigationBarHidden = YES;
        rollPicker.toolbarHidden = YES;
        rollPicker.allowsEditing = NO;
        rollPicker.hidesBottomBarWhenPushed = YES;
        rollPicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        rollPicker.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        rollPicker.view.tintColor = [UIColor blackColor];
        [rollPicker setDelegate:self];
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}


- (void)openRoll{
    
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        
        return;
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString *)kUTTypeImage]) {
        
        rollPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
               
               && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString *)kUTTypeImage]) {
        
        rollPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }else{
        return;
    }

    NSLog(@"open roll present %@", rollPicker);
    if(rollPicker){
        [self presentViewController:rollPicker animated:NO completion:^{
            
            NSLog(@"open roll present");
            
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder
                            createEventWithCategory:@"UX"
                            action:@"posting"
                            label:@"roll camera"
                            value:nil] build]];
        }];
    }
    NSLog(@"open roll");
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    /** Image **/
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        
        self.navigationController.navigationBar.hidden = YES;
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        UIImage *editImage = [SELEditImage scaleAndRotateImage:image size:self.view.frame.size];
        
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera && picker.cameraDevice == UIImagePickerControllerCameraDeviceFront ){
            UIImage* flippedImage = [UIImage imageWithCGImage:editImage.CGImage
                                                        scale:editImage.scale
                                                  orientation:UIImageOrientationUpMirrored];
            editImage = flippedImage;
        }
        [self sendPhoto:editImage videoURL:nil];
        if (picker.view.tag == 1){
            [rollPicker dismissViewControllerAnimated:NO completion:^{
            }];
        }
    }
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    
    [(SELPageViewController*)self.parentViewController lockSideSwipe:NO];
    
    if (picker.view.tag == 1){
        [rollPicker dismissViewControllerAnimated:NO completion:^{
        }];
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder
                    createEventWithCategory:@"UX"
                    action:@"posting"
                    label:@"canceled picker"
                    value:nil] build]];
}

/** Drawing Methods **/

- (void)changeCenterCircleColor{

    _captureButton.backgroundColor = [color getPrimaryColor];
    [UIView animateWithDuration:0.8f
                          delay:0.2f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         _captureButton.backgroundColor = [UIColor whiteColor];
                     } completion:^(BOOL finished){
                         if (finished) {
                             _captureButton.backgroundColor = [UIColor whiteColor];
                         }
                     }];
}

// Drawing circle around capture
- (void)drawCircleColor {
    
    _captureButton.backgroundColor = [color getPrimaryColor];
    int distance = 8;
    [UIView transitionWithView:_previewView
                      duration:0.4
                       options:UIViewAnimationOptionAllowAnimatedContent
                    animations:^{
                        _captureButton.frame = CGRectMake(_captureButton.frame.origin.x - (distance / 2), _captureButton.frame.origin.y - (distance / 2), _captureButton.frame.size.width + distance, _captureButton.frame.size.width + distance);
                        _captureButton.layer.cornerRadius = roundf(_captureButton.frame.size.width/2.0);
                    } completion:^(BOOL finished) {
                    }];
    
    int radius = 38;
    _captureViewLayer = [CAShapeLayer layer];
    _captureViewLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius) cornerRadius:radius].CGPath;
    _captureViewLayer.position = CGPointMake(CGRectGetMidX(_captureView.frame)-radius,
                                            CGRectGetMidY(_captureView.frame)-radius);
    
    _captureViewLayer.fillColor = [UIColor clearColor].CGColor;
    _captureViewLayer.strokeColor = ((UIColor*)[[color getColorArray] objectAtIndex:0]).CGColor;
    _captureViewLayer.lineWidth = 4.2;
    
    [_previewView.layer addSublayer:_captureViewLayer];
    // Configure animation
    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    drawAnimation.duration            = 8.0;
    drawAnimation.repeatCount         = 1.0;
    drawAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    drawAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [_captureViewLayer addAnimation:drawAnimation forKey:@"drawCircleAnimation"];
}

- (void) resetDrawing{

    [_captureViewLayer removeFromSuperlayer];
    _captureButton.backgroundColor = [UIColor whiteColor];
    int distance = 8;
    if (_captureButton.frame.size.width == 64)
        distance = 0;
    _captureButton.frame = CGRectMake(_captureButton.frame.origin.x + (distance / 2), _captureButton.frame.origin.y + (distance / 2), _captureButton.frame.size.width - distance, _captureButton.frame.size.width - distance);
    _captureButton.layer.cornerRadius = roundf(_captureButton.frame.size.width/2.0);
}

/** Send Methods **/
- (void) sendPhoto:(UIImage *)aimage videoURL:(NSString*)videoUrl{
    
    [(SELPageViewController*)self.parentViewController lockSideSwipe:YES];
    _postViewController.image = nil;
    _postViewController.videoURL = nil;
    
    if(videoUrl != nil){
        _postViewController.videoURL = videoUrl;
        _postViewController.image = aimage;
    }else{
        _postViewController.image = aimage;
        _postViewController.videoURL = nil;
    }
    
    _postViewController.color = color;
    [_postViewController addColor:color];
    [_postViewController.hashtags removeAllObjects];
    _postViewController.view.hidden = NO;
    [_postViewController showPost];
    if(videoUrl != nil){
        [_postViewController showVideo];
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder
                    createEventWithCategory:@"UX"
                    action:@"posting"
                    label:@"sent a photo"
                    value:nil] build]];
}

@end
