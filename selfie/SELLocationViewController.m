//
//  SELLocationViewController.m
//  #life
//
//  Created by Griffin Anderson on 2/9/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import "SELLocationViewController.h"

@interface SELLocationViewController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *header;
@property (weak, nonatomic) IBOutlet UITextField *search;
@property SELLocationTableViewController *locationTableViewController;
@end

@implementation SELLocationViewController

@synthesize color;
@synthesize selecting;
@synthesize locationTableViewController;
@synthesize search;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    locationTableViewController = [[SELLocationTableViewController alloc] init];
    //locationViewController.delegate = self;
    locationTableViewController.color = color;
    locationTableViewController.selecting = selecting;
    locationTableViewController.search = search;
    locationTableViewController.view.frame = CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
    [self.containerView addSubview:locationTableViewController.view];
    [self addChildViewController:locationTableViewController];
    [locationTableViewController didMoveToParentViewController:self];
    
    [self.search setDelegate:self];
    [self.search addTarget:self action:@selector(textFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 1.0f);
    topBorder.backgroundColor = [UIColor colorWithWhite:1.0f alpha:.15f].CGColor;
    [self.header.layer addSublayer:topBorder];
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.header.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(4.0, 4.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.header.bounds;
    maskLayer.path = maskPath.CGPath;
    self.header.layer.mask = maskLayer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - TextField

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    [self locQuery:self.search.text];
    
    [self.search resignFirstResponder];
}

- (void)textFieldDidChange:(id)sender{
    
    [self locQuery:self.search.text];
}

-(void)dismissKeyboard {
    [self.search resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void) locQuery:(NSString *)query{
    if ((query.length % 2) == 0 || query.length == 1 || query.length == 4) {
    for (UIViewController* vc in self.childViewControllers) {
        if ([vc isKindOfClass:[SELLocationTableViewController class]]) {
            [(SELLocationTableViewController *) vc searchForLocation:query];
        }
    }
    }
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder
                    createEventWithCategory:@"UX"
                    action:@"searched school"
                    label:query
                    value:nil] build]];
}

- (void) unlockSearch{
    self.search.userInteractionEnabled = YES;
    self.search.placeholder = @"Search for a school";
    [self.search becomeFirstResponder];
}

- (void) lockSearch{
    self.search.text = @"";
    self.search.userInteractionEnabled = NO;
    self.search.placeholder = @"Choose a school";
}

- (void) changedLocation{

    @try {
    
        UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (topController.presentedViewController) {
            topController = topController.presentedViewController;
        }
        [(SELPageViewController*)(topController) updateLocation];
    }
    @catch (NSException *exception) {
        
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
