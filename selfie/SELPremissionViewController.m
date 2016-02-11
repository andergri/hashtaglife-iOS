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
@property (weak, nonatomic) IBOutlet UIButton *notificationButton;
@property (weak, nonatomic) IBOutlet UIButton *audioButton;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
- (IBAction)audioAction:(id)sender;
- (IBAction)videoAction:(id)sender;
- (IBAction)notificationAction:(id)sender;

@end

@implementation SELPremissionViewController

@synthesize color;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.frame = self.parentViewController.view.frame;
    [self.backgroundView.layer setCornerRadius:5.0f];
    self.backgroundView.center = self.view.center;
    self.backgroundView.hidden = YES;
    
    [self addFakeOverlay];
    
    // Push Notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotificationPremission:)
                                                 name:@"Register_PUSH_NOTIFICATION"
                                               object:nil];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self checkForPremissions];
    [self.view setNeedsDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) askForNotDeterminedPremission{
    AVAuthorizationStatus audioAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    AVAuthorizationStatus videoAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    // middle
    if (audioAuthorizationStatus == AVAuthorizationStatusNotDetermined){
        if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self checkForPremissions];
                    });
                }
            }];
        }
    }
    
    if (videoAuthorizationStatus == AVAuthorizationStatusNotDetermined){
        if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self checkForPremissions];
                    });
                }
            }];
        }
    }
    
}


// Check for premissions
- (void) checkForPremissions{
    
    [self askForNotDeterminedPremission];
    
    AVAuthorizationStatus audioAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    AVAuthorizationStatus videoAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(videoAuthorizationStatus == AVAuthorizationStatusAuthorized &&
       audioAuthorizationStatus == AVAuthorizationStatusAuthorized){
        [(SELPageViewController *)self.parentViewController checkCameraOrPremssionViewController:YES];
    }
    self.backgroundView.hidden = NO;
    if(videoAuthorizationStatus == AVAuthorizationStatusNotDetermined ||
       audioAuthorizationStatus == AVAuthorizationStatusNotDetermined){
        self.backgroundView.hidden = YES;
    }
    [self checkNotification:self.notificationButton title:@"Notifications"];
    [self setPremssionValue:self.audioButton status:audioAuthorizationStatus title:@"Microphone"];
    [self setPremssionValue:self.videoButton status:videoAuthorizationStatus title:@"Camera"];
}

// check premission notification
- (void) checkNotification:(UIButton *)statusButton title:(NSString*)title{

    BOOL remoteNotificationsEnabled = false, noneEnabled,alertsEnabled, badgesEnabled, soundsEnabled;
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // iOS8+
        remoteNotificationsEnabled = [UIApplication sharedApplication].isRegisteredForRemoteNotifications;
        
        UIUserNotificationSettings *userNotificationSettings = [UIApplication sharedApplication].currentUserNotificationSettings;
        
        noneEnabled = userNotificationSettings.types == UIUserNotificationTypeNone;
        alertsEnabled = userNotificationSettings.types & UIUserNotificationTypeAlert;
        badgesEnabled = userNotificationSettings.types & UIUserNotificationTypeBadge;
        soundsEnabled = userNotificationSettings.types & UIUserNotificationTypeSound;
        
    } else {
        // iOS7 and below
        UIRemoteNotificationType enabledRemoteNotificationTypes = [UIApplication sharedApplication].enabledRemoteNotificationTypes;
        
        noneEnabled = enabledRemoteNotificationTypes == UIRemoteNotificationTypeNone;
        alertsEnabled = enabledRemoteNotificationTypes & UIRemoteNotificationTypeAlert;
        badgesEnabled = enabledRemoteNotificationTypes & UIRemoteNotificationTypeBadge;
        soundsEnabled = enabledRemoteNotificationTypes & UIRemoteNotificationTypeSound;
    }
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        NSLog(@"Remote notifications enabled: %@", remoteNotificationsEnabled ? @"YES" : @"NO");
    }
    
    NSLog(@"Notification type status:");
    NSLog(@"  None: %@", noneEnabled ? @"enabled" : @"disabled");
    NSLog(@"  Alerts: %@", alertsEnabled ? @"enabled" : @"disabled");
    NSLog(@"  Badges: %@", badgesEnabled ? @"enabled" : @"disabled");
    NSLog(@"  Sounds: %@", soundsEnabled ? @"enabled" : @"disabled");

    
    [statusButton.layer setBorderColor:color.getPrimaryColor.CGColor];
    [statusButton.layer setBorderWidth:2.0f];
    [statusButton.layer setCornerRadius:5.0f];

    if (!remoteNotificationsEnabled) {
        [statusButton setTitle:[@"Allow " stringByAppendingString:title] forState:UIControlStateNormal];
        [statusButton setTitleColor:color.getPrimaryColor forState:UIControlStateNormal];
        statusButton.backgroundColor = [UIColor whiteColor];
        [statusButton setSelected:NO];
        [statusButton setEnabled:YES];
    }else if(noneEnabled){
        [statusButton setTitle:[@"Enable " stringByAppendingString:title] forState:UIControlStateSelected];
        [statusButton setTitleColor:color.getPrimaryColor forState:UIControlStateSelected];
        statusButton.backgroundColor = [UIColor whiteColor];
        [statusButton setSelected:YES];
        [statusButton setEnabled:YES];
    }else{
        [statusButton setTitle:[@"Allowed " stringByAppendingString:title] forState:UIControlStateDisabled];
        [statusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        statusButton.backgroundColor = color.getPrimaryColor;
        [statusButton setSelected:NO];
        [statusButton setEnabled:NO];
        statusButton.hidden = YES;
    }
}

// set premission value
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
            statusButton.hidden = YES;
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
                [self askForNotificationPremission];
                break;
            case 1:
                [self askForPremission:AVMediaTypeVideo];
                break;
            case 2:
                [self askForPremission:AVMediaTypeAudio];
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

- (void) askForNotificationPremission {
    NSLog(@"Asked for notificatin ");
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"AskedForNotificationPermission"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)receivedNotificationPremission:(NSNotification *)notification {
    
    NSDictionary *dict = [notification userInfo];
    BOOL result = [dict objectForKey:@"accept"];
    NSLog(@"receivedNotification %d", result);
    
    [self checkForPremissions];
}

- (IBAction)audioAction:(id)sender {
    [self clickedAction:sender];
}

- (IBAction)videoAction:(id)sender {
    [self clickedAction:sender];
}

- (IBAction)notificationAction:(id)sender {
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
    
    [(SELPageViewController*)self.parentViewController setCameraBar:self.view];
}

@end
