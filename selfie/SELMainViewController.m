//
//  SELMainViewController.m
//  selfie
//
//  Created by Griffin Anderson on 7/19/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import "SELMainViewController.h"
#import "SELHashtagTableViewController.h"

@interface SELMainViewController ()

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIView *footerView;

@property UILabel *headingLabel;
@property UITapGestureRecognizer *alerttpgr;
@property UITapGestureRecognizer *doublealerttpgr;

@end

@implementation SELMainViewController

@synthesize alerttpgr;
@synthesize color;
@synthesize CURRENTLOADING;
@synthesize headingLabel;
@synthesize doublealerttpgr;

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
    
    CURRENTLOADING = YES;
    
    // init color
    color = [(SELPageViewController*)self.parentViewController color];

    // hide naviagtion
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
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
    headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 44)];
    headingLabel.text = @"#";
    headingLabel.font = [UIFont systemFontOfSize:29];
    headingLabel.textColor = [UIColor colorWithWhite:0 alpha:.25];
    headingLabel.backgroundColor = [UIColor clearColor];
    headingLabel.textAlignment = NSTextAlignmentCenter;
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 22, 44)];
    [paddingView addSubview:headingLabel];
    self.textField.leftView = paddingView;
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    self.textField.layer.masksToBounds=YES;
    self.textField.bounds = CGRectInset(self.textField.frame, -11.0f, 0.0f);
    
    // Main init Methods
    [self.textField setDelegate:self];
    [self.textField addTarget:self action:@selector(textFieldDidChange:)
   forControlEvents:UIControlEventEditingChanged];
    
    // footer view
    [(SELPageViewController*)self.parentViewController setFooterBar:self.footerView disapear:YES];
    
    // Set Bar
    [(SELPageViewController*)self.parentViewController setPrimaryBar:self.view];
    
    // Camera Object
    [(SELPageViewController*)self.parentViewController setCamera:self.cameraButton];
    
    // Tap Gesture
    alerttpgr = [[UITapGestureRecognizer alloc]
                 initWithTarget:self action:@selector(alerthandleTap:)];
    alerttpgr.numberOfTouchesRequired = 1;
    alerttpgr.numberOfTapsRequired = 1;
    alerttpgr.delegate = self;
    alerttpgr.enabled = YES;
    [self.view addGestureRecognizer:alerttpgr];
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    @try {
        if (CURRENTLOADING) {
            CURRENTLOADING = NO;
            for (UIViewController* vc in self.childViewControllers) {
                if ([vc isKindOfClass:[SELHashtagTableViewController class]]) {
                    SELHashtagTableViewController* htc = (SELHashtagTableViewController *)vc;
                    [htc searchForHashtag:self.textField.text];
                }
            }
        }
    }
    @catch (NSException *exception) {
    }
    @finally {
    }

    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Home Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}


- (void)updateList{
    for (UIViewController* vc in self.childViewControllers) {
        if ([vc isKindOfClass:[SELHashtagTableViewController class]] && vc.view.window) {
            SELHashtagTableViewController* htc = (SELHashtagTableViewController *)vc;
            NSLog(@"update list");
            [htc searchForHashtag:self.textField.text];
        }
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
   
    if (self.textField.text.length > 0) {
        headingLabel.textColor = [UIColor whiteColor];
    }else{
        headingLabel.textColor = [UIColor colorWithWhite:0 alpha:.25];
    }
    
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
            NSLog(@"query A");
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

-(void)alerthandleTap:(UITapGestureRecognizer *)gestureRecognizer {
    
    @try {
        
    for (UIViewController* vc in self.childViewControllers) {
        if ([vc isKindOfClass:[SELHashtagTableViewController class]] && vc.view.window) {
            SELHashtagTableViewController* htc = (SELHashtagTableViewController *)vc;
            CGPoint p = [gestureRecognizer locationInView:htc.tableView];
            NSIndexPath *indexPath = [htc.tableView indexPathForRowAtPoint:p];
            UITableViewCell *cell = [htc.tableView cellForRowAtIndexPath:indexPath];
            NSIndexPath *tempLastTapped = htc.lastTapped;
            
            if (indexPath != nil) {
                    
                    // kill if point is at bottom screen
                    CGFloat distanceFromBottom = ([htc.tableView contentOffset].y + self.view.frame.size.height) - 150;
                    if(p.y > distanceFromBottom && p.x > 0){
                        return;
                    }
                    if(p.y < [htc.tableView contentOffset].y){
                        return;
                    }
                
                    [self dismissKeyboard];
                
                    NSString *hashtag;
                    if(self.textField.text.length == 0 && indexPath.section == 1) {
                        
                        if (indexPath.item == 0) {
                            NSLog(@"hit popular");
                            [(SELPageViewController*)self.parentViewController  showSelfies:0 hashtag:@"" color:cell.backgroundColor global:NO objectId:nil];
                            htc.lastTapped = 0;
                            [htc.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, tempLastTapped, nil] withRowAnimation:UITableViewRowAnimationNone];

                            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                            [tracker send:[[GAIDictionaryBuilder
                                            createEventWithCategory:@"UX"
                                            action:@"taped suggested"
                                            label:@"popular"
                                            value:nil] build]];
                            return;
                        }else if (indexPath.item == 1) {
                            [(SELPageViewController*)self.parentViewController showSelfies:1 hashtag:@"" color:cell.backgroundColor global:NO objectId:nil];
                            htc.lastTapped = 0;
                            [htc.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, tempLastTapped, nil] withRowAnimation:UITableViewRowAnimationNone];

                            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                            [tracker send:[[GAIDictionaryBuilder
                                            createEventWithCategory:@"UX"
                                            action:@"taped suggested"
                                            label:@"fresh"
                                            value:nil] build]];
                            return;
                        }else{
                            hashtag = [htc.hashtags objectAtIndex:(indexPath.item - 2)];
                        }
                    }else{
                        if(indexPath.section == 0){
                            hashtag = [htc.inbox objectAtIndex:indexPath.item];
                            [htc markInbox:hashtag];
                        }else{
                            hashtag = [htc.hashtags objectAtIndex:indexPath.item];
                        }
                    }
                
                    CGPoint eP = [gestureRecognizer locationInView:cell];
                    if([indexPath isEqual:htc.lastTapped] && eP.y > 65){
                        if (eP.x < 160 && ![htc.inbox containsObject:hashtag]) {
                            if ([htc.subscribed containsObject:hashtag]) {
                                [htc.subscribed removeObjectIdenticalTo:hashtag];
                                [(SELPageViewController*)self.parentViewController subscribeToAHashtag:hashtag subscribe:NO];
                            }else{
                                [htc.subscribed addObject:hashtag];
                                [(SELPageViewController*)self.parentViewController subscribeToAHashtag:hashtag subscribe:YES];
                            }
                            [htc.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, tempLastTapped, nil] withRowAnimation:UITableViewRowAnimationNone];
                        }else{
                            [(SELPageViewController*)self.parentViewController quickPostHashtag:hashtag];
                        }
                        NSLog(@"Bottom Cell tapped %f %f", eP.x, eP.y);
                        return;
                    }
                    htc.lastTapped = indexPath;
                    NSLog(@"index path %@", indexPath);
                
                    [(SELPageViewController*)self.parentViewController showSelfies:2 hashtag:hashtag color:cell.backgroundColor global:NO objectId:nil];
                    [htc.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, tempLastTapped, nil] withRowAnimation:UITableViewRowAnimationNone];

                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                    [tracker send:[[GAIDictionaryBuilder
                                createEventWithCategory:@"UX"
                                action:@"taped hashtag"
                                label:hashtag
                                value:nil] build]];
            }
        }
    }
    
}@catch (NSException *exception) {
    //[loadSelifes hidePopup];
}
@finally {
}
}

- (void)showCameraIcon:(BOOL)show {
    [(SELPageViewController*)self.parentViewController fadeBar:show];
}

@end
