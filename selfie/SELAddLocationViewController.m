//
//  SELAddLocationViewController.m
//  #life
//
//  Created by Griffin Anderson on 11/23/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import "SELAddLocationViewController.h"

@interface SELAddLocationViewController ()

@property (weak, nonatomic) IBOutlet UITextField *schoolText;
@property (weak, nonatomic) IBOutlet UITextField *schoolLocationText;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
- (IBAction)done:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *exitButton;
- (IBAction)exit:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *cover;


@end

@implementation SELAddLocationViewController

@synthesize color;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Top header border
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 1.0f);
    topBorder.backgroundColor = [UIColor colorWithWhite:1.0f alpha:.15f].CGColor;
    [self.schoolText.layer addSublayer:topBorder];
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.schoolText.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(4.0, 4.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.schoolText.bounds;
    maskLayer.path = maskPath.CGPath;
    self.schoolText.layer.mask = maskLayer;
    
    
    self.doneButton.titleLabel.textColor = [UIColor whiteColor];
    self.doneButton.backgroundColor = [[color getColorArray] objectAtIndex:0];
    
    self.schoolText.textColor = [UIColor whiteColor];
    self.schoolText.backgroundColor = [[color getColorArray] objectAtIndex:1];
    
    self.schoolLocationText.textColor = [UIColor whiteColor];
    self.schoolLocationText.backgroundColor = [[color getColorArray] objectAtIndex:2];
    
    self.exitButton.titleLabel.textColor = [UIColor whiteColor];
    self.exitButton.backgroundColor = [[color getColorArray] objectAtIndex:3];
    
    self.view.backgroundColor = [[color getColorArray] objectAtIndex:4];
    
    // Second Page
    self.cover.hidden = YES;
    //self.cover.layer.mask = maskLayer;
    self.cover.backgroundColor = [[color getColorArray] objectAtIndex:4];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self.schoolText becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)done:(id)sender {
    
    if (self.schoolText.text.length > 0 && self.schoolLocationText.text.length > 0) {
        
        self.doneButton.enabled = NO;
        self.cover.hidden = NO;
        [self submitNewLocation];
        
    }else{
    
    }
}

- (IBAction)exit:(id)sender {
    
    [self.schoolText resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (void) submitNewLocation{
    
    PFObject *location = [PFObject objectWithClassName:@"Location"];
    [location setObject:self.schoolText.text forKey:@"name"];
    [location setObject:self.schoolLocationText.text forKey:@"misc"];
    [location setObject:@NO forKey:@"active"];
    [location setObject:@1 forKey:@"students" ];
    [location setObject:@NO forKey:@"default"];
    [location saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        [self.schoolText resignFirstResponder];
    }];
}
@end
