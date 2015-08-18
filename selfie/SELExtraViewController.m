//
//  SELExtraViewController.m
//  #life
//
//  Created by Griffin Anderson on 2/25/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import "SELExtraViewController.h"
#import "SELMapViewController.h"


@interface SELExtraViewController ()

@property SELMapViewController *mapViewController;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation SELExtraViewController

@synthesize mapViewController;
@synthesize color;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    mapViewController = [[SELMapViewController alloc] init];
    //locationViewController.delegate = self;
    mapViewController.color = color;
    mapViewController.view.frame = CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
    [self.containerView addSubview:mapViewController.view];
    [self addChildViewController:mapViewController];
    [mapViewController didMoveToParentViewController:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
