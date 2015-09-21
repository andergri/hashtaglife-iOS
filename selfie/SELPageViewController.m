//
//  SELPageViewController.m
//  #life
//
//  Created by Griffin Anderson on 3/21/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import "SELPageViewController.h"

@interface SELPageViewController ()

@property SELOnStartViewController *onStartViewController;
@property SELSelifeViewController *selfieViewController;
@property SELBarViewController *barViewController;
@property SELMainViewController *mainViewController;
@property SELSecondaryViewController *secondaryViewController;

@property UIViewController *captureOrPremssionViewController;
@property SELCaptureViewController *captureViewController;
@property SELPremissionViewController *premssionViewController;
@property SELRollViewController *rollViewController;

@end

@implementation SELPageViewController

@synthesize color;
@synthesize onStartViewController;
@synthesize selfieViewController;
@synthesize barViewController;
@synthesize captureViewController;
@synthesize mainViewController;
@synthesize secondaryViewController;
@synthesize premssionViewController;
@synthesize captureOrPremssionViewController;
@synthesize rollViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = self;
    
    // Color Theme
    color = [[SELColorPicker alloc] init];
    [color initColor];
    
    onStartViewController = [[SELOnStartViewController alloc] init];
    [self.view addSubview:onStartViewController.view];
    [self addChildViewController:onStartViewController];
    [onStartViewController didMoveToParentViewController:self];
    
    // Selfie Controller
    selfieViewController = [[SELSelifeViewController alloc] initWithColor:color];
    selfieViewController.view.frame = self.view.frame;
    [self.view addSubview:selfieViewController.view];
    [self addChildViewController:selfieViewController];
    [selfieViewController didMoveToParentViewController:self];
    
    
    // Roll Controller
    rollViewController = [[SELRollViewController alloc] init];
    rollViewController.color = color;
    [self.view addSubview:rollViewController.view];
    [self addChildViewController:rollViewController];
    [rollViewController didMoveToParentViewController:self];
    
    
    // Capture Controller
    [self checkCameraOrPremssionViewController];
    
    // Main & Secondary Controller
    mainViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Main"];
    secondaryViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Secondary"];
    
    [self setViewControllers:@[mainViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
    
    // Bar & Photo Controller
    [self isInitlized];
    
    // Push Notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(presentMyViewOnPushNotification:)
                                                 name:@"HAS_PUSH_NOTIFICATION"
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [onStartViewController runOnStart:color];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Swipe View Controllers

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    if ([viewController isKindOfClass:[SELMainViewController class]])
        return secondaryViewController;
    
    if ([viewController isKindOfClass:[SELSecondaryViewController class]])
        return nil;
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    if ([viewController isKindOfClass:[SELMainViewController class]])
        return nil;
    
    if ([viewController isKindOfClass:[SELSecondaryViewController class]])
        return mainViewController;
    
    return nil;
}

- (void) switchToPrimaryClicked{
    
    UIViewController *vc = [self.viewControllers lastObject];
    if ([vc isKindOfClass:[SELSecondaryViewController class]]) {
        [self setViewControllers:@[mainViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }else{
        [self setViewControllers:@[mainViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    }
}
- (void) switchToSecondaryClicked{
    [self setViewControllers:@[secondaryViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
}

#pragma mark - Helper Methods

- (void) isInitlized{
    if (!barViewController) {
        barViewController = [[SELBarViewController alloc] init];
        barViewController.delegate = self;
        barViewController.color = color;
    }
}

#pragma mark - Public Methods

- (void) setFooterBar:(UIView *)view disapear:(BOOL)dispear{
    [self isInitlized];
    [barViewController createBarFooter:view disapear:dispear];
}
- (void) fadeBar:(BOOL)fade{
    [self isInitlized];
    [barViewController fadeBar:fade];
}
- (void) setPrimaryBar:(UIView *)view{
    [self isInitlized];
    [barViewController createBarOptionPrimary:view];
}
- (void) setSeondaryBar:(UIView *)view{
    [self isInitlized];
    [barViewController createBarOptionSecondary:view];
}
- (void) setCameraBar:(UIView *)view{
    NSLog(@"set Camera Bar");
    [self isInitlized];
    [barViewController createBarOptionCamera:view];
}
- (void) setCamera:(UIView *)view{
    [self isInitlized];
    //[barViewController createCameraButton:view];
}
- (void) showSelfies:(NSUInteger)type hashtag:(NSString *)hashtag color:(UIColor*)acolor global:(BOOL)global objectId:(NSString*)objectId {
    if(acolor == nil)
        acolor = [color getPrimaryColor];
    [self isInitlized];
    [selfieViewController showSelfies:type hashtag:hashtag color:acolor location:global objectId:objectId];
}

#pragma mark - Bar Delegeate Methods

- (void) cameraClicked{
    [self isInitlized];
    [self setViewControllers:@[captureOrPremssionViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
}
- (void) rollClicked{
    [self isInitlized];
    [rollViewController openRoll];
}
- (void) gameClicked{
    SELGameViewController *gameVC = [[SELGameViewController alloc] init];
    gameVC.acolor = color;
    
    [self presentViewController:gameVC animated:NO completion:^{
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder
                        createEventWithCategory:@"UX"
                        action:@"game score"
                        label:@""
                        value:nil] build]];
    }];
}

- (void) exitClicked{
    
    [self setViewControllers:@[mainViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
    if (rollViewController)
        rollViewController.view.hidden = YES;
}

#pragma mark - Change Location

- (void) changeLocation{
    // Remove users location
    [[PFUser currentUser] removeObjectForKey:@"location"];
    [[PFUser currentUser] saveInBackground];
    // Open location
    SELLocationViewController *location = [[SELLocationViewController alloc] init];
    location.color = color;
    location.selecting = YES;
    [self presentViewController:location animated:YES completion:^{
        NSLog(@"location popupdone");
    }];
}

- (void) updateLocation{
    for (UIViewController* vc in self.childViewControllers) {
        if ([vc isKindOfClass:[SELMainViewController class]] && vc.view.window) {
            SELMainViewController* htc = (SELMainViewController *)vc;
            [htc updateList];
        }
    }
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self switchToPrimaryClicked];
    });
}

- (void) lockSideSwipe:(BOOL)lock{
    if (lock) {
        self.dataSource = nil;
    }else{
        self.dataSource = self;
    }
}

#pragma mark - Other

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - push notificaiton

-(void)presentMyViewOnPushNotification:(NSNotification *)notification {
    NSDictionary *dict = [notification userInfo];
    NSString *selfieId = [dict objectForKey:@"selfieId"];
    NSLog(@"Push Selfie %@", selfieId);
    
    @try {
        if (selfieId) {
            [self switchToSecondaryClicked];
            [self showSelfies:4 hashtag:nil color:nil global:NO objectId:selfieId];
        }
    }@catch (NSException *exception) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error"
                                                          message:[exception reason]
                                                         delegate:self
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
        [message show];
    }
}

#pragma mark - PremssionsSettingsViewController

- (void) checkCameraOrPremssionViewController{
    
    if ([onStartViewController checkForPremissions]) {
        if (captureViewController == nil) {
            captureViewController = [[SELCaptureViewController alloc] init];
            captureViewController.color = color;
        }
        captureOrPremssionViewController = captureViewController;
    }else{
        if (premssionViewController == nil) {
            premssionViewController = [[SELPremissionViewController alloc] init];
            premssionViewController.color = color;
        }
        captureOrPremssionViewController = premssionViewController;
    }
    //[self setViewControllers:@[captureOrPremssionViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
    
}

@end
