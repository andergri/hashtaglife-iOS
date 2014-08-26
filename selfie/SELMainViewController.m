//
//  SELMainViewController.m
//  selfie
//
//  Created by Griffin Anderson on 7/19/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import "SELMainViewController.h"
#import "SELHashtagTableViewController.h"
#import "SELEditImage.h"
#import "SELUserViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "SELFlagObject.h"
#import "SELHeartObject.h"
#import "SELUserLikesObject.h"
#import "SELCameraObject.h"
#import "SELRandomObject.h"
#import "SELImageCountObject.h"
#import "SELLoadSelfiesObject.h"

@interface SELMainViewController ()

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *exitButton;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIView *blackOutView;
- (IBAction)openCamera:(id)sender;
- (IBAction)exitImage:(id)sender;

@property SELPostViewController *postViewController;
@property UITapGestureRecognizer *tpgr;
@property UITapGestureRecognizer *alerttpgr;

@property SELFlagObject  *flagButton;
@property SELHeartObject *heartButton;
@property SELUserLikesObject *userLikes;
@property SELCameraObject *cameraControl;
@property SELRandomObject *randomObj;
@property SELImageCountObject *imageCount;
@property SELLoadSelfiesObject *loadSelifes;

@end

@implementation SELMainViewController

@synthesize postViewController;
@synthesize tpgr;
@synthesize alerttpgr;


@synthesize color;
@synthesize flagButton;
@synthesize heartButton;
@synthesize userLikes;
@synthesize cameraControl;
@synthesize randomObj;
@synthesize imageCount;
@synthesize loadSelifes;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.imageView.frame = self.view.frame;
    
    // init color
    color = [[SELColorPicker alloc] init];
    [color initColor];
    
    // init postVC
    postViewController = [[SELPostViewController alloc] init];
    postViewController.delegate = self;
    
    // hide naviagtion
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    // Main init Methods under random obj
    randomObj = [[SELRandomObject alloc] init];
    [randomObj initMainView:self.headerView text:self.textField exit:self.exitButton color:color];
    [self.textField setDelegate:self];
    [self.textField addTarget:self action:@selector(textFieldDidChange:)
   forControlEvents:UIControlEventEditingChanged];
    
    // User Likes view
    userLikes = [[SELUserLikesObject alloc] init];
    [userLikes initUserLikes:self.view below:self.popupView color:color];
    [self countLikes];
    
    // Camera Button UI
    cameraControl = [[SELCameraObject alloc] init];
    [cameraControl initCameraView:self.cameraButton color:color];
    
    //Heart Button
    heartButton = [[SELHeartObject alloc] init];
    [heartButton initHeart:self.imageView];
    
    //Flag Button
    flagButton = [[SELFlagObject alloc] init];
    [flagButton initFlag:self.imageView];
    
    // heart count label on popup
    imageCount = [[SELImageCountObject alloc] init];
    [imageCount initImageTally:self.imageView];

    
    // Tap Gesture
    tpgr = [[UITapGestureRecognizer alloc]
            initWithTarget:self action:@selector(handleTap:)];
    tpgr.numberOfTouchesRequired = 1;
    tpgr.delegate = self;
    tpgr.enabled = NO;
    [self.view addGestureRecognizer:tpgr];
    
    
    // Tap Gesture
    alerttpgr = [[UITapGestureRecognizer alloc]
                 initWithTarget:self action:@selector(alerthandleTap:)];
    alerttpgr.numberOfTouchesRequired = 1;
    alerttpgr.numberOfTapsRequired = 1;
    alerttpgr.delegate = self;
    alerttpgr.enabled = YES;
    [self.view addGestureRecognizer:alerttpgr];
    
    // Main Selfies Loading
    loadSelifes = [[SELLoadSelfiesObject alloc] init];
    [loadSelifes initDefault:self.popupView imageView:self.imageView flag:flagButton heart:heartButton imagCount:imageCount tap:tpgr alertTap:alerttpgr vc:self];

}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    postViewController.view.frame = self.view.frame;
    
    NSLog(@"hight post %f", postViewController.view.frame.size.height);
    PFUser *user = [PFUser currentUser];
    if (!user) {
        SELUserViewController *userVC = [[SELUserViewController alloc] init];
        userVC.color = color;
        [self presentViewController:userVC animated:YES completion:nil];
    }
    
    //show camera...
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self performSelector:@selector(showCamera) withObject:nil afterDelay:0.3];
    }
        
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Home Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - TextField

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    [self hashtagQuery:self.textField.text];
    
    [self.textField resignFirstResponder];
}

- (void)textFieldDidChange:(id)sender{
   
    [self hashtagQuery:self.textField.text];
}

-(void)dismissKeyboard {
    [self.textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void) hashtagQuery:(NSString *)query{
    for (UIViewController* vc in self.childViewControllers) {
        if ([vc isKindOfClass:[SELHashtagTableViewController class]]) {
            [(SELHashtagTableViewController *) vc searchForHashtag:query];
        }
    }
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder
                    createEventWithCategory:@"UX"
                    action:@"searched hashtag"
                    label:query
                    value:nil] build]];
}

#pragma mark - Table pressed

-(void)handleTap:(UITapGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    if ((self.view.frame.size.width - 80) < point.x && 80 > point.y) {
        [loadSelifes tapHeart];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder
                        createEventWithCategory:@"UX"
                        action:@"selfie"
                        label:@"tap heart"
                        value:nil] build]];
    } else if(80 > point.x && ((self.view.frame.size.height - 80) < point.y)){
        [loadSelifes tapFlag];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder
                        createEventWithCategory:@"UX"
                        action:@"selfie"
                        label:@"tap flag"
                        value:nil] build]];
    }else{
        [loadSelifes loadNextImage];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder
                        createEventWithCategory:@"UX"
                        action:@"selfie"
                        label:@"next image"
                        value:nil] build]];
    }
}

-(void)alerthandleTap:(UITapGestureRecognizer *)gestureRecognizer {
    
    @try {
    
    for (UIViewController* vc in self.childViewControllers) {
        if ([vc isKindOfClass:[SELHashtagTableViewController class]]) {
            SELHashtagTableViewController* htc = (SELHashtagTableViewController *)vc;
            CGPoint p = [gestureRecognizer locationInView:htc.tableView];
            NSIndexPath *indexPath = [htc.tableView indexPathForRowAtPoint:p];
            UITableViewCell *cell = [htc.tableView cellForRowAtIndexPath:indexPath];
            
            if (indexPath != nil) {
                    
                    // kill if point is at bottom screen
                    CGFloat distanceFromBottom = ([htc.tableView contentOffset].y + self.view.frame.size.height) - 150;
                    if(p.y > distanceFromBottom && p.x > 120){
                        return;
                    }
                    if(p.y < [htc.tableView contentOffset].y){
                        return;
                    }
                
                    [self dismissKeyboard];
                    NSString *hashtag = [htc.hashtags objectAtIndex:indexPath.item];
                    [loadSelifes showPopup];
                    [loadSelifes loadHashtag:hashtag color:cell.backgroundColor];
                
                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                    [tracker send:[[GAIDictionaryBuilder
                                createEventWithCategory:@"UX"
                                action:@"taped hashtag"
                                label:hashtag
                                value:nil] build]];
            }
        }
    }
}
    @catch (NSException *exception) {
    [loadSelifes hidePopup];
}
@finally {
}
}

- (IBAction)exitImage:(id)sender{
    [loadSelifes hidePopup];
}

#pragma mark - Camera View Controllers

- (void)showCamera{
    
    [cameraControl initCamera:self.view];
    [[cameraControl imagePicker] setDelegate:self];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        NSLog(@"picked iamge %@", image);
        
        postViewController.color = color;
        [postViewController addColor:color];
         postViewController.image = [SELEditImage scaleAndRotateImage:image size:self.view.frame.size];
         [postViewController.hashtags removeAllObjects];
        
        self.blackOutView.hidden = NO;
        [picker dismissViewControllerAnimated:NO completion:^{
            
            [self presentViewController:postViewController animated:NO completion:^{
                self.blackOutView.hidden = YES;
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder
                                createEventWithCategory:@"UX"
                                action:@"posting"
                                label:@"selected a image"
                                value:nil] build]];
            }];
        }];
        
    } else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        // Code here to support video if enabled
    }
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    
    [picker dismissViewControllerAnimated:NO completion:NO];
    [postViewController dismissViewControllerAnimated:NO completion:nil];
    NSLog(@"canceld image");
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder
                    createEventWithCategory:@"UX"
                    action:@"posting"
                    label:@"canceled camera"
                    value:nil] build]];

}

// Show Camera Methods
- (IBAction)openCamera:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self presentViewController:[cameraControl imagePicker] animated:NO completion:^{
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder
                            createEventWithCategory:@"UX"
                            action:@"posting"
                            label:@"open camera"
                            value:nil] build]];
        }];
    }
}
- (void)openCamera {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self presentViewController:[cameraControl imagePicker] animated:NO completion:^{
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder
                            createEventWithCategory:@"UX"
                            action:@"posting"
                            label:@"reopen camera"
                            value:nil] build]];
        }];
    }
}

// END Camera ///////////////////////////////////////

// Social Share Open
- (void)showShare:(NSArray *)activityItems{
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:^{
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder
                        createEventWithCategory:@"UX"
                        action:@"taped share"
                        label:@""
                        value:nil] build]];
    }];
}

// Reset # of user likes
- (void)countLikes{
    [userLikes getNumberUserLikes];
   
    // Long Press
    UITapGestureRecognizer *lpgr = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(pressHeartCount:)];
    lpgr.numberOfTouchesRequired = 1;
    lpgr.numberOfTapsRequired = 1;
    lpgr.delegate = self;
    lpgr.enabled = YES;
    [[userLikes likeContainer] addGestureRecognizer:lpgr];
}

// View what images got likes
- (void)pressHeartCount:(UITapGestureRecognizer *)gestureRecognizer{
    
    [self dismissKeyboard];
    [loadSelifes showPopup];
    [loadSelifes loadUserPhotos:[color getPrimaryColor]];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder
                    createEventWithCategory:@"UX"
                    action:@"taped my hearts"
                    label:@""
                    value:nil] build]];
}

@end
