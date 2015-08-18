//
//  SELPhotoViewController.m
//  #life
//
//  Created by Griffin Anderson on 3/22/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import "SELPhotoViewController.h"
#import "SELEditImage.h"
#import "SELCameraOverlayView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "SELImagePickerViewController.h"


@interface SELPhotoViewController ()


@property UIImagePickerController *rollPicker;
@property SELPostViewController *postViewController;

@end



@implementation SELPhotoViewController

@synthesize color;
@synthesize screenView;
@synthesize cameraPicker;
@synthesize rollPicker;
@synthesize postViewController;


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Undo for camera button clicked (Fix: 1)
    //self.view.hidden = YES;
    
    // init postVC
    postViewController = [[SELPostViewController alloc] init];
    postViewController.delegate = self;
    
    // Post View Controller
    
    BOOL doesContainPost = [self.view.subviews containsObject:postViewController.view];
    
    if (!doesContainPost) {
        
        postViewController.view.frame = self.view.frame;
        
        [self.view addSubview:postViewController.view];
        
        [self addChildViewController:postViewController];
        
        [postViewController didMoveToParentViewController:self];
        
    }
    
    postViewController.view.hidden = YES;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self performSelector:@selector(addCamera) withObject:nil afterDelay:0];
    }
    
}

- (void) viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    //Camera View Controller
    NSLog(@"photo view did appear yes");
}

- (void) viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    
    //Camera View Controller
    NSLog(@"photo view did disappear yes");
}



- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    
}



#pragma mark - public commands



// OPEN ROLL

- (void)openRoll{
    
    
    [(SELPageViewController*)self.parentViewController lockSideSwipe:NO];
    self.view.hidden = NO;
    
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
         
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        
        return;
        
    }
    
    
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString *)kUTTypeImage]) {
        
        rollPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        
        
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
               
               && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString *)kUTTypeImage]) {
        
        rollPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        
        
        
    } else {
        
        return;
        
    }
    
    if(rollPicker){
        
        [self presentViewController:rollPicker animated:NO completion:^{
            
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            
            [tracker send:[[GAIDictionaryBuilder
                            
                            createEventWithCategory:@"UX"
                            
                            action:@"posting"
                            
                            label:@"roll camera"
                            
                            value:nil] build]];
            
        }];
        
    }
    
}

// OPEN CAMERA

- (void)openCamera{
    
    
    [(SELPageViewController*)self.parentViewController lockSideSwipe:NO];
    self.view.hidden = NO;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        cameraPicker.view.hidden = NO;
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder
                        
                        createEventWithCategory:@"UX"
                        
                        action:@"posting"
                        
                        label:@"open camera"
                        
                        value:nil] build]];
        
    }
    
}



// REOPEN CAMERA

- (void)reopenCamera{
    
    self.view.hidden = NO;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        cameraPicker.view.hidden = NO;
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder
                        
                        createEventWithCategory:@"UX"
                        
                        action:@"posting"
                        
                        label:@"reopen camera"
                        
                        value:nil] build]];
        
    }
    
}



#pragma mark - Camera View Controllers



// Intial Command

- (void)addCamera{
    
    NSLog(@"addCamera");
    
    BOOL doesContainCamera = [self.view.subviews containsObject:cameraPicker.view];
    
    if (!doesContainCamera) {
        
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]){

            // Setup Camera
            cameraPicker = [[SELImagePickerViewController alloc] init];
            cameraPicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, (NSString *)kUTTypeMovie, nil];
            cameraPicker.view.tag = 0;
            cameraPicker.view.frame = screenView.frame;
            cameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            cameraPicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
            cameraPicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            cameraPicker.modalPresentationStyle = UIModalPresentationFullScreen;
            cameraPicker.showsCameraControls = NO;
            cameraPicker.navigationBarHidden = YES;
            cameraPicker.toolbarHidden = YES;
            cameraPicker.allowsEditing = NO;
            cameraPicker.hidesBottomBarWhenPushed = YES;
            cameraPicker.videoQuality = UIImagePickerControllerQualityTypeIFrame1280x720;
            cameraPicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;

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
            
            // Screen size
            CGSize screenSize = [[UIScreen mainScreen] bounds].size;
            if (screenSize.height == 480) {
                cameraPicker.cameraViewTransform = CGAffineTransformMakeScale(1, 1);
            }else{
                CGFloat cameraAspectRatio = 1280.0f/720.0f;
                CGFloat camViewHeight = screenSize.width * cameraAspectRatio;
                CGFloat scale = screenSize.height / camViewHeight;
                cameraPicker.cameraViewTransform = CGAffineTransformMakeTranslation(0, (screenSize.height - camViewHeight) / 2.0);
                cameraPicker.cameraViewTransform = CGAffineTransformScale(cameraPicker.cameraViewTransform, scale, scale);
            }

            // overlay
            SELCameraOverlayView *aoverlay = [[SELCameraOverlayView alloc] initWithFrame:CGRectMake(0, 0, screenView.frame.size.width, screenView.frame.size.height) color:color];
            aoverlay.pickerRefrenece = cameraPicker;
            aoverlay.bpickerRefrenece = rollPicker;
            aoverlay.frame = cameraPicker.cameraOverlayView.frame;
            aoverlay.color = color;
         
            
            [cameraPicker.view addSubview:aoverlay];
            cameraPicker.cameraOverlayView = aoverlay;
            if ([cameraPicker respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
                [cameraPicker setEdgesForExtendedLayout:UIRectEdgeNone];
            }
  
            [cameraPicker setDelegate:self];
            [rollPicker setDelegate:self];
            
            
            [self addChildViewController:cameraPicker];
            [self.view addSubview:cameraPicker.view];
            [cameraPicker didMoveToParentViewController:self];
            
            // Undo for camera button clicked (Fix: 1)
            //cameraPicker.view.hidden = YES;

            // Set Bar
            [(SELPageViewController*)self.parentViewController setCameraBar:cameraPicker.view];
            
        }
    }
}

- (void)addCamera1{
    
    NSLog(@"addCamera1");
    [self addChildViewController:cameraPicker];
    [self.view addSubview:cameraPicker.view];
    [cameraPicker didMoveToParentViewController:self];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSLog(@"finished");
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    /** Image **/
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {

        UIImage *image = info[UIImagePickerControllerOriginalImage];
        UIImage *editImage = [SELEditImage scaleAndRotateImage:image size:self.view.frame.size];

        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera && picker.cameraDevice == UIImagePickerControllerCameraDeviceFront ){

            UIImage* flippedImage = [UIImage imageWithCGImage:editImage.CGImage
                                                        scale:editImage.scale
                                                  orientation:UIImageOrientationUpMirrored];
            editImage = flippedImage;
            
        }
        
        self.navigationController.navigationBar.hidden = YES;
        
        // Set Bar
        if (picker.view.tag == 0) {
            
            postViewController.color = color;
            [postViewController addColor:color];
            postViewController.image = editImage;
            [postViewController.hashtags removeAllObjects];
            [postViewController showPost];
            postViewController.view.hidden = NO;
            picker.view.hidden = YES;
            
        }else if (picker.view.tag == 1){
            
            [rollPicker dismissViewControllerAnimated:NO completion:^{
                
                postViewController.color = color;
                [postViewController addColor:color];
                postViewController.image = editImage;
                [postViewController.hashtags removeAllObjects];
                [postViewController showPost];
                postViewController.view.hidden = NO;
                cameraPicker.view.hidden = YES;
            }];
            
        }else{}
        
        [(SELPageViewController*)self.parentViewController lockSideSwipe:YES];
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder
                        createEventWithCategory:@"UX"
                        action:@"posting"
                        label:@"selected a image"
                        value:nil] build]];

        
    /** Video **/
    } else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];

        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera && picker.cameraDevice == UIImagePickerControllerCameraDeviceFront ){
        }

        
        // Set Bar
        if (picker.view.tag == 0) {
            
            postViewController.color = color;
            [postViewController addColor:color];
            postViewController.videoURL = videoURL;
            postViewController.image = nil;
            [postViewController.hashtags removeAllObjects];
            [postViewController showPost];
            postViewController.view.hidden = NO;
            picker.view.hidden = YES;
            [postViewController showVideo];
            
        }
        [(SELPageViewController*)self.parentViewController lockSideSwipe:YES];
        //cameraPicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder
                        createEventWithCategory:@"UX"
                        action:@"posting"
                        label:@"selected a video"
                        value:nil] build]];
        
    }
}



- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    
    
    
    [(SELPageViewController*)self.parentViewController lockSideSwipe:NO];
    
    if (picker.view.tag == 0) {
        
        picker.view.hidden = YES;
        
    }else if (picker.view.tag == 1){
        
        [rollPicker dismissViewControllerAnimated:NO completion:^{
            
            cameraPicker.view.hidden = NO;
            
            self.view.hidden = NO;
            
        }];
        
    }else{}
    
    
    
    //[picker dismissViewControllerAnimated:NO completion:nil];
    
    [rollPicker dismissViewControllerAnimated:NO completion:^{
        
        self.view.hidden = YES;
        
    }];
    
    self.view.hidden = YES;
    
    //[cameraControl imagePicker].view.hidden = YES;
    
    //picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    NSLog(@"canceld image");
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder
                    
                    createEventWithCategory:@"UX"
                    
                    action:@"posting"
                    
                    label:@"canceled camera"
                    
                    value:nil] build]];
    
    
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

