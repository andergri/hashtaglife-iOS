//
//  SELPushNotificationViewController.m
//  #life
//
//  Created by Griffin Anderson on 10/5/15.
//  Copyright © 2015 Griffin Anderson. All rights reserved.
//

#import "SELPushNotificationViewController.h"
#import "FLAnimatedImage.h"

@interface SELPushNotificationViewController ()

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIButton *notificationButton1;
- (IBAction)notificationAction:(id)sender;
- (IBAction)exitNotifications:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *subHeader;
@property (weak, nonatomic) IBOutlet UIView *gif;

@end

@implementation SELPushNotificationViewController

@synthesize color;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.backgroundView.layer setCornerRadius:5.0f];
    self.backgroundView.center = self.view.center;
    //self.view.backgroundColor = [color getPrimaryColor];
    
    //GIF
    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://38.media.tumblr.com/1461d4e52d3b4ec1f21a308897c20ef4/tumblr_mtp1c3Hrw01qhub34o5_r2_400.gif"]]];
    NSLog(@"gif image %@", image);
    FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
    imageView.animatedImage = image;
    imageView.frame = CGRectMake(0, 0, self.gif.frame.size.width, self.gif.frame.size.height);
    [self.gif addSubview:imageView];
    [self.gif.layer setCornerRadius:4.0f];
    self.subHeader.textColor = [color getPrimaryColor];
    
    // Push Notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotificationPremission:)
                                                 name:@"Register_PUSH_NOTIFICATION"
                                               object:nil];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self setNotificaitons];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL) shouldAskForNotifications{
    return [self checkNotification:self.notificationButton1 title:@"Notifications"];
}

- (void) setNotificaitons{
    [self checkNotification:self.notificationButton1 title:@"Notifications"];
    self.subHeader.text = @"You just followed a hashtag, we will notify you every time there is a new post.";
    
    [self.view setNeedsDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// check premission notification
- (BOOL) checkNotification:(UIButton *)statusButton title:(NSString*)title{
    
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
        //Allow 
        [statusButton setTitle:[@"Allow " stringByAppendingString:title] forState:UIControlStateNormal];
        [statusButton setTitleColor:color.getPrimaryColor forState:UIControlStateNormal];
        statusButton.backgroundColor = [UIColor whiteColor];
        [statusButton setSelected:NO];
        [statusButton setEnabled:YES];
        return YES;
    }else if(noneEnabled){
        //Enable
        [statusButton setTitle:[@"Enable " stringByAppendingString:title] forState:UIControlStateSelected];
        [statusButton setTitleColor:color.getPrimaryColor forState:UIControlStateSelected];
        statusButton.backgroundColor = [UIColor whiteColor];
        [statusButton setSelected:YES];
        [statusButton setEnabled:YES];
        NSInteger randomNumber = arc4random() % 3;
        if (randomNumber < 1) {
            return YES;
        }
        return NO;
    }else{
        //Allowed
        [statusButton setTitle:[@"Allowed " stringByAppendingString:title] forState:UIControlStateDisabled];
        [statusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        statusButton.backgroundColor = color.getPrimaryColor;
        [statusButton setSelected:NO];
        [statusButton setEnabled:NO];
        
        if([PFInstallation currentInstallation]){
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            if (currentInstallation.deviceToken == nil) {
                [self askForNotificationPremission];
            }
        }
        return NO;
    }
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
            default:
                break;
        }
    }
}

- (void) askForNotificationPremission {
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
    
    [self setNotificaitons];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (IBAction)notificationAction:(id)sender {
    [self clickedAction:sender];
}

- (IBAction)exitNotifications:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void) shakePremssions{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = 0.6;
    animation.values = @[ @(-15), @(15), @(-15), @(15), @(-10), @(10), @(-5), @(5), @(0) ];
    [self.backgroundView.layer addAnimation:animation forKey:@"shake"];
}

@end
