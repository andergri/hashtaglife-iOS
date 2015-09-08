//
//  SELRollViewController.m
//  #life
//
//  Created by Griffin Anderson on 9/5/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import "SELRollViewController.h"
#import "SELEditImage.h"

@interface SELRollViewController ()<
UIGestureRecognizerDelegate,
PBJVisionDelegate,
UIAlertViewDelegate> {
    SELPostViewController *_postViewController;
    UIImagePickerController *rollPicker;
}
@property UIImagePickerController *rollPicker;
@property UIButton *errorbutton;


@end

@implementation SELRollViewController

@synthesize rollPicker;
@synthesize color;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup roll picker
    [self setup];
    
    self.view.backgroundColor = [UIColor greenColor];
    
    
    // Post View Controller
    _postViewController = [[SELPostViewController alloc] init];
    _postViewController.delegate = self;
    BOOL doesContainPost = [self.view.subviews containsObject:_postViewController.view];
    if (!doesContainPost) {
        _postViewController.view.frame = self.view.frame;
        [self addChildViewController:_postViewController];
        [_postViewController didMoveToParentViewController:self];
    }
    _postViewController.view.hidden = YES;
    
    self.view.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    
    self.view.hidden = NO;
    
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
            self.view.hidden = YES;
        }];
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder
                    createEventWithCategory:@"UX"
                    action:@"posting"
                    label:@"canceled picker"
                    value:nil] build]];
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
