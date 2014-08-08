//
//  SELMainViewController.m
//  selfie
//
//  Created by Griffin Anderson on 7/19/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import "SELMainViewController.h"
#import "SELHashtagTableViewController.h"
#import "SELCameraOverlayView.h"
#import "SELEditImage.h"
#import "SELUserViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface SELMainViewController ()

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIView *blackOutView;
- (IBAction)openCamera:(id)sender;

@property NSMutableArray *aselfies;
@property NSMutableArray *aselfiesImages;
@property NSInteger selfiesCounter;
@property SELPostViewController *postViewController;
@property UIImagePickerController *imagePicker;
@property UITapGestureRecognizer *tpgr;
@property UITapGestureRecognizer *alerttpgr;
@property UIImageView *heartImageView;
@property UIButton *heartButton;
@property UIImageView *flagImageView;
@property UIButton *flagButton;
@property UILabel *heartCountLabel;
@property UIImageView *heartCountImageView;
@property UIView *likeContainer;

@end

@implementation SELMainViewController

@synthesize aselfies;
@synthesize aselfiesImages;
@synthesize selfiesCounter;
@synthesize postViewController;
@synthesize imagePicker;
@synthesize tpgr;
@synthesize alerttpgr;
@synthesize heartImageView;
@synthesize heartButton;
@synthesize flagImageView;
@synthesize flagButton;
@synthesize heartCountLabel;
@synthesize heartCountImageView;
@synthesize color;
@synthesize likeContainer;

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
    
    // init color
    color = [[SELColorPicker alloc] init];
    [color initColor];
    
    // init
    aselfies = [[NSMutableArray alloc] init];
    aselfiesImages = [[NSMutableArray alloc] init];
    selfiesCounter = 0;
    postViewController = [[SELPostViewController alloc] init];
    postViewController.delegate = self;
    postViewController.view.frame = self.view.frame;
    
    self.navigationController.navigationBar.hidden = YES;
    
    // Top header border
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.headerView.frame.size.width, 1.0f);
    topBorder.backgroundColor = [UIColor colorWithWhite:1.0f alpha:.15f].CGColor;
    [self.headerView.layer addSublayer:topBorder];
    self.headerView.backgroundColor = [color getPrimaryColor];
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.headerView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(4.0, 4.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.headerView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.headerView.layer.mask = maskLayer;
    
    //Textfield Styling
    [self.textField setDelegate:self];
    [self.textField addTarget:self action:@selector(textFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
    UILabel *headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 44)];
    headingLabel.text = @"#";
    headingLabel.font = [UIFont systemFontOfSize:29];
    headingLabel.textColor = [UIColor whiteColor];
    headingLabel.backgroundColor = [UIColor clearColor];
    headingLabel.textAlignment = NSTextAlignmentCenter;
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, 44)];
    [paddingView addSubview:headingLabel];
    self.textField.leftView = paddingView;
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    self.textField.layer.masksToBounds=YES;
    self.textField.bounds = CGRectInset(self.textField.frame, -22.0f, 0.0f);
    
    // Likes
    likeContainer = [[UIView alloc] initWithFrame:CGRectMake(250, self.view.frame.size.height - 70, 54, 54)];
    likeContainer.layer.cornerRadius = roundf(likeContainer.frame.size.width/2.0);
    likeContainer.layer.masksToBounds = YES;
    likeContainer.backgroundColor = [color getPrimaryColor];
    likeContainer.layer.borderWidth = 1.2;
    likeContainer.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.view addSubview:likeContainer];
    [self.view insertSubview:likeContainer belowSubview:self.popupView];
    PFUser *user = [PFUser currentUser];
    if (user) {
        [self countLikes];
    }else{
        [self showLikeCount:0];
    }
    
    //insertSubview:belowSubview:
    
    // Camera Button
    self.cameraButton.layer.cornerRadius = roundf(self.cameraButton.frame.size.width/2.0);
    self.cameraButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.cameraButton.layer.borderWidth = 2.0f;
    self.cameraButton.backgroundColor = [color getPrimaryColor];
    
    //Camera Button UI
    UIImage *cameraImage = [[UIImage imageNamed:@"camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *cameraImageView = [[UIImageView alloc] initWithImage:cameraImage];
    cameraImageView.frame = CGRectMake(20, 20, cameraImage.size.width, cameraImage.size.height);
    cameraImageView.contentMode = UIViewContentModeCenter;
    [cameraImageView setTintColor:[UIColor colorWithWhite:1. alpha:1]];
    [self.cameraButton addSubview:cameraImageView];
    
    // Long Press
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.15;
    lpgr.delegate = self;
    [self.view addGestureRecognizer:lpgr];
    
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
    
    
    //Heart Button
    heartButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 74, 0, 70, 70)];
    UIImage *backImage = [[UIImage imageNamed:@"open-heart"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [backImage setAccessibilityIdentifier:@"open"];
    heartImageView = [[UIImageView alloc] initWithImage:backImage];
    heartImageView.frame = CGRectMake(15, 15, backImage.size.width, backImage.size.height);
    heartImageView.contentMode = UIViewContentModeCenter;
    [heartImageView setTintColor:[UIColor colorWithWhite:1 alpha:1]];
    [heartButton addSubview:heartImageView];
    heartButton.enabled = YES;
    [self.imageView addSubview:heartButton];
    
    //Flag Button
    flagButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 70,(self.view.frame.size.height - 70), 70, 70)];
    UIImage *flagImage = [[UIImage imageNamed:@"open-flag"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [flagImage setAccessibilityIdentifier:@"open-flag"];
    flagImageView = [[UIImageView alloc] initWithImage:flagImage];
    flagImageView.frame = CGRectMake(15, 15, flagImage.size.width, flagImage.size.height);
    flagImageView.contentMode = UIViewContentModeCenter;
    [flagImageView setTintColor:[UIColor colorWithWhite:1 alpha:1]];
    [flagButton addSubview:flagImageView];
    flagButton.enabled = YES;
    [self.imageView addSubview:flagButton];
    
    // heart count label on popup
    heartCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 43, 42)];
    heartCountLabel.textColor = [color getPrimaryColor];
    heartCountLabel.font = [UIFont systemFontOfSize:15];
    heartCountLabel.textAlignment = NSTextAlignmentCenter;
    
    UIImage *likeImage = [[UIImage imageNamed:@"full-heart"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    heartCountImageView = [[UIImageView alloc] initWithImage:likeImage];
    heartCountImageView.frame = CGRectMake(self.view.frame.size.width - 60, 9, likeImage.size.width, likeImage.size.height);
    heartCountImageView.contentMode = UIViewContentModeCenter;
    [heartCountImageView setTintColor:[UIColor whiteColor]];
    [heartCountImageView addSubview:heartCountLabel];
    heartCountImageView.hidden = YES;
    [self.imageView addSubview:heartCountImageView];
    
    /**
    CAGradientLayer *gradientWhite = [CAGradientLayer layer];
    gradientWhite.frame = self.footerView.bounds;
    gradientWhite.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:255 green:255 blue:255 alpha:0].CGColor, [UIColor colorWithRed:255 green:255 blue:255 alpha:.4].CGColor, nil];
    [self.footerView.layer insertSublayer:gradientWhite atIndex:0];
     **/
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
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
}

#pragma mark - Table pressed

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    @try {
    
    for (UIViewController* vc in self.childViewControllers) {
        if ([vc isKindOfClass:[SELHashtagTableViewController class]]) {
            SELHashtagTableViewController* htc = (SELHashtagTableViewController *)vc;
            CGPoint p = [gestureRecognizer locationInView:htc.tableView];
            NSIndexPath *indexPath = [htc.tableView indexPathForRowAtPoint:p];
            UITableViewCell *cell = [htc.tableView cellForRowAtIndexPath:indexPath];
            
            if (indexPath != nil) {
                
                if(gestureRecognizer.state == 1){
            
                    self.imageView.image = nil;
                    [self dismissKeyboard];
                    self.popupView.hidden = NO;
                    [self resetHeart];
                    NSString *hashtag = [htc.hashtags objectAtIndex:indexPath.item];
                    [self loadHashtag:hashtag color:cell.backgroundColor];
                    for (UIViewController* vc in self.childViewControllers) {
                        if ([vc isKindOfClass:[SELHashtagTableViewController class]]) {
                            ((SELHashtagTableViewController *) vc).tableView.scrollEnabled = NO;
                        }
                    }
                    
                }else if(gestureRecognizer.state != 1 && gestureRecognizer.state != 2){
                    
                    self.popupView.hidden = YES;
                    tpgr.enabled = NO;
                    alerttpgr.enabled = YES;
                    heartButton.hidden = YES;
                    flagButton.hidden = YES;
                    for (UIViewController* vc in self.childViewControllers) {
                        if ([vc isKindOfClass:[SELHashtagTableViewController class]]) {
                            ((SELHashtagTableViewController *) vc).tableView.scrollEnabled = YES;
                        }
                    }
                }else{
                }
            }
        }
    }
        
    }
    @catch (NSException *exception) {
        self.popupView.hidden = YES;
        tpgr.enabled = NO;
        alerttpgr.enabled = YES;
        heartButton.hidden = YES;
        flagButton.hidden = YES;
        for (UIViewController* vc in self.childViewControllers) {
            if ([vc isKindOfClass:[SELHashtagTableViewController class]]) {
                ((SELHashtagTableViewController *) vc).tableView.scrollEnabled = YES;
            }
        }
    }
    @finally {
        
    }
}

-(void)handleTap:(UITapGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    if ((self.view.frame.size.width - 80) < point.x && 80 > point.y) {
        [self tapHeart];
    } else if((self.view.frame.size.width - 80) < point.x && (self.view.frame.size.height - 80) < point.y){
        [self tapFlag];
    }else{
        [self resetFlag];
        [self resetHeart];
        [self loadNextImage];
    }
}

-(void)alerthandleTap:(UITapGestureRecognizer *)gestureRecognizer {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Tip!"
                                                      message:@"Press & Hold to view hashtag."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    
    [message show];
    gestureRecognizer.enabled = NO;
    gestureRecognizer.numberOfTapsRequired = 5;
    gestureRecognizer.numberOfTouchesRequired = 30;
}

#pragma mark - Show Selfies

// load a hashtag
- (void) loadHashtag:(NSString *)hashtag color:(UIColor *)acolor{
    
    self.popupView.backgroundColor = acolor;
    
    PFQuery *queryHashtag = [PFQuery queryWithClassName:@"Selfie"];
    [queryHashtag orderByDescending:@"createdAt"];
    [queryHashtag whereKey:@"hashtags" equalTo:hashtag];
    [queryHashtag whereKey:@"flags" lessThanOrEqualTo:@3];
    [queryHashtag findObjectsInBackgroundWithBlock:^(NSArray *selfies, NSError *error) {
        if (!error) {
            NSLog(@"Successfully got %lu selfies for %@.", (unsigned long)selfies.count, hashtag);
            [aselfies removeAllObjects];
            aselfies = (NSMutableArray *)selfies;
            [self loadImages];
        }else{
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [self allLoaded];
        }
    }];
}

// load images
- (void) loadImages{
    [aselfiesImages removeAllObjects];
    for (PFObject *selfie in aselfies) {
        PFFile *imageFile = selfie[@"image"];
        [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                if([UIImage imageWithData:imageData]){
                    [aselfiesImages addObject:[UIImage imageWithData:imageData]];
                    
                    if (selfie == aselfies.lastObject) {
                        [self allLoaded];
                    }
                }
            }
        }];
    }
    if (aselfies.count == 0) {
        [self allLoaded];
    }
}

// signal image is loaded
- (void) allLoaded {
    
    NSLog(@"loaded");
    tpgr.enabled = YES;
    alerttpgr.enabled = NO;
    heartButton.hidden = NO;
    flagButton.hidden = NO;
    selfiesCounter = 0;
    [self loadNextImage];
}

// gets next image
- (void) loadNextImage {
    
    @try {
    
        NSLog(@"lni %ld %lu", (long)selfiesCounter, (unsigned long)aselfiesImages.count);
        
    if (selfiesCounter < aselfiesImages.count) {
        [self addVisit];
    
        PFUser * tempUser = [aselfies objectAtIndex:selfiesCounter][@"from"];
        
        if ([tempUser.objectId isEqualToString:[PFUser currentUser].objectId]) {
            heartButton.hidden = YES;
            flagButton.hidden = YES;
            heartCountImageView.hidden = NO;
            heartCountLabel.text = [NSString stringWithFormat:@"%@", [aselfies objectAtIndex:selfiesCounter][@"likes"]];
        }else{
            heartButton.hidden = NO;
            flagButton.hidden = NO;
            heartCountImageView.hidden = YES;
        }
        
        UIImage * image = [aselfiesImages objectAtIndex:selfiesCounter];
        self.imageView.image = image;
        selfiesCounter++;
    }else{
        self.popupView.hidden = YES;
        tpgr.enabled = NO;
        alerttpgr.enabled = YES;
        heartButton.hidden = YES;
        flagButton.hidden = YES;
        for (UIViewController* vc in self.childViewControllers) {
            if ([vc isKindOfClass:[SELHashtagTableViewController class]]) {
                ((SELHashtagTableViewController *) vc).tableView.scrollEnabled = YES;
            }
        }
    }
        
    }
    @catch (NSException *exception) {
        self.popupView.hidden = YES;
        tpgr.enabled = NO;
        alerttpgr.enabled = YES;
        heartButton.hidden = YES;
        flagButton.hidden = YES;
        for (UIViewController* vc in self.childViewControllers) {
            if ([vc isKindOfClass:[SELHashtagTableViewController class]]) {
                ((SELHashtagTableViewController *) vc).tableView.scrollEnabled = YES;
            }
        }
    }
    @finally {
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Camera

- (void)showCamera{
    
    imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setDelegate:self];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    imagePicker.showsCameraControls = NO;
    imagePicker.navigationBarHidden = YES;
    imagePicker.toolbarHidden = YES;
    imagePicker.allowsEditing = YES;
    imagePicker.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    CGSize screenBounds = [UIScreen mainScreen].bounds.size;
    CGFloat cameraAspectRatio = 4.0f/3.0f;
    CGFloat camViewHeight = screenBounds.width * cameraAspectRatio;
    CGFloat scale = screenBounds.height / camViewHeight;
    imagePicker.cameraViewTransform = CGAffineTransformMakeTranslation(0, (screenBounds.height - camViewHeight) / 2.0);
    imagePicker.cameraViewTransform = CGAffineTransformScale(imagePicker.cameraViewTransform, scale, scale);
    
    //CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    //float cameraAspectRatio = 4.0 / 3.0f;
    //float imageWidth = floorf(screenSize.width * cameraAspectRatio);
    //float scale = ceilf((screenSize.height / imageWidth) * 10.0) / 10.0;
    //imagePicker.cameraViewTransform = CGAffineTransformMakeScale(scale, scale);
    
    
    
    SELCameraOverlayView *overlay = [[SELCameraOverlayView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) color:color];
    overlay.pickerRefrenece = imagePicker;
    overlay.frame = imagePicker.cameraOverlayView.frame;
    overlay.color = color;
   
    [imagePicker.view addSubview:overlay];
    //imagePicker.cameraOverlayView = overlay;

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
}

- (IBAction)openCamera:(id)sender {
 
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self presentViewController:imagePicker animated:NO completion:^{
        }];
    }
}

- (void)openCamera {
    NSLog(@"go to camera");
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self presentViewController:imagePicker animated:NO completion:^{
        }];
    }
}

// Heart
- (void)tapHeart{
    
    NSLog(@"Heart");
    
    if ([[heartImageView.image accessibilityIdentifier] isEqualToString:@"open"]) {
        UIImage *backImage = [[UIImage imageNamed:@"full-heart"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [backImage setAccessibilityIdentifier:@"full"];
        heartImageView.image = backImage;
        [heartImageView setTintColor:[UIColor redColor]];
        [heartImageView setTintColor:[UIColor colorWithWhite:1 alpha:1]];
        [self addLike:YES];
    }else if([[heartImageView.image accessibilityIdentifier] isEqualToString:@"full"]) {
        UIImage *backImage = [[UIImage imageNamed:@"open-heart"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [backImage setAccessibilityIdentifier:@"open"];
        heartImageView.image = backImage;
        [heartImageView setTintColor:[UIColor colorWithWhite:1 alpha:1]];
        [self addLike:NO];
    }else{
        NSLog(@"none");
    }
}


// Heart
- (void)resetHeart{
    
    UIImage *backImage = [[UIImage imageNamed:@"open-heart"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [backImage setAccessibilityIdentifier:@"open"];
    heartImageView.image = backImage;
    [heartImageView setTintColor:[UIColor colorWithWhite:1 alpha:1]];
}

- (void)addLike:(BOOL)increment{
    
    
    @try {
        PFObject * selfie = [aselfies objectAtIndex:(selfiesCounter - 1)];
        if (increment) {
            [selfie incrementKey:@"likes"];
        }else{
            //[sel incrementKey:@"likes"];
        }
        [selfie saveEventually];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}


// Heart
- (void)tapFlag{
    
    NSLog(@"Flag");
    
    if ([[flagImageView.image accessibilityIdentifier] isEqualToString:@"open-flag"]) {
        UIImage *backImage = [[UIImage imageNamed:@"full-flag"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [backImage setAccessibilityIdentifier:@"full-flag"];
        flagImageView.image = backImage;
        [flagImageView setTintColor:[UIColor redColor]];
        [flagImageView setTintColor:[UIColor colorWithWhite:1 alpha:1]];
        [self addFlag:YES];
    }else if([[flagImageView.image accessibilityIdentifier] isEqualToString:@"full-flag"]) {
        UIImage *backImage = [[UIImage imageNamed:@"open-flag"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [backImage setAccessibilityIdentifier:@"open-flag"];
        flagImageView.image = backImage;
        [flagImageView setTintColor:[UIColor colorWithWhite:1 alpha:1]];
        [self addFlag:NO];
    }else{
        NSLog(@"none");
    }
}


// Flag
- (void)resetFlag{
    
    UIImage *backImage = [[UIImage imageNamed:@"open-flag"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [backImage setAccessibilityIdentifier:@"open-flag"];
    flagImageView.image = backImage;
    [flagImageView setTintColor:[UIColor colorWithWhite:1 alpha:1]];
}

- (void)addFlag:(BOOL)increment{
    
    @try {
        PFObject * selfie = [aselfies objectAtIndex:(selfiesCounter - 1)];
        if (increment) {
            [selfie incrementKey:@"flags"];
        }else{
            //[sel incrementKey:@"flags"];
        }
        [selfie saveEventually];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}



- (void)addVisit{
    @try {
        PFObject * selfie = [aselfies objectAtIndex:selfiesCounter];
        [selfie incrementKey:@"visits"];
        [selfie saveEventually];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}
- (void)countLikes{
    PFQuery *query = [PFQuery queryWithClassName:@"Selfie"];
    [query whereKey:@"from" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if (!error) {
            // The count request succeeded. Log the count
            int acount = 0;
            for (PFObject *obj in results) {
                acount += [obj[@"likes"] intValue];
            }
            [self showLikeCount:acount];
        } else {
            // The request failed
        }
    }];
}

// Like Count
- (void) showLikeCount:(int) count{
    
    UILabel *likes = [[UILabel alloc] initWithFrame:CGRectMake(-4, -5, 50, 50)];
    likes.layer.cornerRadius = roundf(likes.frame.size.width/2.0);
    likes.layer.masksToBounds = YES;
    likes.text = [NSString stringWithFormat:@"%d", count];
    likes.textColor = [color getPrimaryColor];
    likes.font = [UIFont systemFontOfSize:15];
    likes.textAlignment = NSTextAlignmentCenter;
    
    UIImage *likeImage = [[UIImage imageNamed:@"full-heart"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *likeImageView = [[UIImageView alloc] initWithImage:likeImage];
    likeImageView.frame = CGRectMake(6, 9, likeImage.size.width, likeImage.size.height);
    likeImageView.contentMode = UIViewContentModeCenter;
    [likeImageView setTintColor:[UIColor whiteColor]];
    [likeImageView addSubview:likes];
    [likeContainer addSubview:likeImageView];
    // Long Press
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(pressHeartCount:)];
    lpgr.minimumPressDuration = 0.15;
    lpgr.delegate = self;
    [self.likeContainer addGestureRecognizer:lpgr];
}

// View what images got likes
- (void)pressHeartCount:(UILongPressGestureRecognizer *)gestureRecognizer{
    if(gestureRecognizer.state == 1){
        
        self.imageView.image = nil;
        [self dismissKeyboard];
        self.popupView.hidden = NO;
        
        self.popupView.backgroundColor = [color getPrimaryColor];
        
        PFQuery *queryHashtag = [PFQuery queryWithClassName:@"Selfie"];
        [queryHashtag orderByDescending:@"createdAt"];
        [queryHashtag whereKey:@"from" equalTo:[PFUser currentUser]];
        [queryHashtag findObjectsInBackgroundWithBlock:^(NSArray *selfies, NSError *error) {
            if (!error) {
                NSLog(@"Successfully got selfies for self.");
                [aselfies removeAllObjects];
                aselfies = (NSMutableArray *)selfies;
                [self loadImages];
            }else{
                NSLog(@"Error: %@ %@", error, [error userInfo]);
                [self allLoaded];
            }
        }];

       
    }else if(gestureRecognizer.state != 1 && gestureRecognizer.state != 2){
        
        self.popupView.hidden = YES;
        
    }else{
    }
}

@end
