//
//  SELPremissionViewController.m
//  #life
//
//  Created by Griffin Anderson on 8/19/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import "SELPremissionViewController.h"

@interface SELPremissionViewController ()
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIButton *audioButton;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
- (IBAction)audioAction:(id)sender;
- (IBAction)videoAction:(id)sender;

@end

@implementation SELPremissionViewController

@synthesize color;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.hidden = YES;
    [self.backgroundView.layer setCornerRadius:5.0f];
    self.backgroundView.center = self.view.center;
    
    [self addFakeOverlay];
    [self checkForPremissions];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.view setNeedsDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) checkForPremissions{
    
    AVAuthorizationStatus audioAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    AVAuthorizationStatus videoAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(videoAuthorizationStatus == AVAuthorizationStatusAuthorized &&
       audioAuthorizationStatus == AVAuthorizationStatusAuthorized){
        //[(SELPageViewController *)self.parentViewController  getCameraOrPremissionViewController];
    }
    [self setPremssionValue:self.audioButton status:audioAuthorizationStatus title:@"Microphone"];
    [self setPremssionValue:self.videoButton status:videoAuthorizationStatus title:@"Camera"];
}

- (void) setPremssionValue:(UIButton *)statusButton status:(AVAuthorizationStatus)status title:(NSString*)title{
    [statusButton.layer setBorderColor:color.getPrimaryColor.CGColor];
    [statusButton.layer setBorderWidth:2.0f];
    [statusButton.layer setCornerRadius:5.0f];
    
    switch(status) {
       
        case AVAuthorizationStatusNotDetermined:
            [statusButton setTitle:[@"Allow " stringByAppendingString:title] forState:UIControlStateNormal];
            [statusButton setTitleColor:color.getPrimaryColor forState:UIControlStateNormal];
            statusButton.backgroundColor = [UIColor whiteColor];
            [statusButton setSelected:NO];
            [statusButton setEnabled:YES];
            break;
        case AVAuthorizationStatusRestricted:
            [statusButton setTitle:[@"Enable " stringByAppendingString:title] forState:UIControlStateSelected];
            [statusButton setTitleColor:color.getPrimaryColor forState:UIControlStateSelected];
            statusButton.backgroundColor = [UIColor whiteColor];
            [statusButton setSelected:NO];
            [statusButton setEnabled:NO];
            break;
        case AVAuthorizationStatusDenied:
            [statusButton setTitle:[@"Enable " stringByAppendingString:title] forState:UIControlStateSelected];
            [statusButton setTitleColor:color.getPrimaryColor forState:UIControlStateSelected];
            statusButton.backgroundColor = [UIColor whiteColor];
            [statusButton setSelected:YES];
            [statusButton setEnabled:YES];
            break;
        case AVAuthorizationStatusAuthorized:
            [statusButton setTitle:[@"Allowed " stringByAppendingString:title] forState:UIControlStateDisabled];
            [statusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
            statusButton.backgroundColor = color.getPrimaryColor;
            [statusButton setSelected:NO];
            [statusButton setEnabled:NO];
            break;
        default:
            break;
    }
    [self.view setNeedsDisplay];
}

- (void) clickedAction:(UIButton *)sender{
    if (sender.isSelected && sender.enabled) {
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }else if (sender.enabled) {
        switch (sender.tag) {
            case 0:
                [self askForPremission:AVMediaTypeAudio];
                break;
            case 1:
                [self askForPremission:AVMediaTypeVideo];
                break;
            default:
                break;
        }
    }
}

- (void) askForPremission:(NSString *)type{

    [AVCaptureDevice requestAccessForMediaType:type completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self checkForPremissions];
        });
    }];
}

- (IBAction)audioAction:(id)sender {
    [self clickedAction:sender];
}

- (IBAction)videoAction:(id)sender {
    [self clickedAction:sender];
}

- (void) shakePremssions{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = 0.6;
    animation.values = @[ @(-15), @(15), @(-15), @(15), @(-10), @(10), @(-5), @(5), @(0) ];
    [self.backgroundView.layer addAnimation:animation forKey:@"shake"];
}

- (void) addFakeOverlay{

    // Capture View border
    UIButton *_captureView = [[UIButton alloc] initWithFrame:CGRectMake(120, self.view.frame.size.height - 85, 80, 80)];
    _captureView.layer.cornerRadius = roundf(_captureView.frame.size.width/2.0);
    _captureView.layer.borderColor = [UIColor whiteColor].CGColor;
    _captureView.layer.borderWidth = 4.0f;
    [self.view addSubview:_captureView];
    
    // Capture button
    UIButton *_captureButton = [[UIButton alloc] initWithFrame:CGRectMake(128, self.view.frame.size.height - 77, 64, 64)];
    _captureButton.layer.cornerRadius = roundf(_captureButton.frame.size.width/2.0);
    _captureButton.backgroundColor = [UIColor whiteColor];
    _captureButton.userInteractionEnabled = YES;
    [_captureButton addTarget:self action:@selector(shakePremssions) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_captureButton];

    // flash button
    UIButton *_flashButton = [[UIButton alloc] init];
    UIImage *flashImage = [[UIImage imageNamed:@"off-flash"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_flashButton setImage:flashImage forState:UIControlStateNormal];
    [_flashButton setImage:[[UIImage imageNamed:@"on-flash"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    CGRect flashFrame = _flashButton.frame;
    _flashButton.imageView.contentScaleFactor = 2.5;
    [_flashButton setTintColor:[UIColor whiteColor]];
    flashFrame.origin = CGPointMake(20.0f, 15.0f);
    flashFrame.size = flashImage.size;
    _flashButton.frame = flashFrame;
    [self.view addSubview:_flashButton];
    
    // flip button
    UIButton *_flipButton = [[UIButton alloc] init];
    UIImage *flipImage = [[UIImage imageNamed:@"switch-camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_flipButton setImage:flipImage forState:UIControlStateNormal];
    _flipButton.contentScaleFactor = 2.5;
    [_flipButton setTintColor:[UIColor whiteColor]];
    CGRect flipFrame = _flipButton.frame;
    flipFrame.origin = CGPointMake(CGRectGetWidth(self.view.frame) - 60.0f, 15.0f);
    flipFrame.size = flipImage.size;
    _flipButton.frame = flipFrame;
    [self.view addSubview:_flipButton];
}

- (void) setBar{
    NSLog(@"parente vc %@", [self.parentViewController class]);
    
    // Set Bar
    [(SELPageViewController*)self.parentViewController setCameraBar:self.view];
}

@end