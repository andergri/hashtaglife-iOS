//
//  SELVotingOverlayViewController.m
//  #life
//
//  Created by Griffin Anderson on 7/9/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import "SELVotingOverlayViewController.h"
#import "SELVotingListTableViewController.h"

#define headerHeight 40.0
#define kExposedHeight 140.0

@interface SELVotingOverlayViewController ()

@property SELVotingListTableViewController *votingTableVC;

@end

@implementation SELVotingOverlayViewController

@synthesize color;
@synthesize votingTableVC;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.frame = CGRectMake(0, headerHeight, self.view.frame.size.width, self.view.frame.size.height - headerHeight - kExposedHeight + 2);
    self.view.backgroundColor = [UIColor blackColor];
    self.view.hidden = YES;
    
    votingTableVC = [[SELVotingListTableViewController alloc] init];
    votingTableVC.color = color;
    [self.view setUserInteractionEnabled:YES];
    [votingTableVC.view setUserInteractionEnabled:YES];
    votingTableVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 2.0);
    [self.view addSubview:votingTableVC.view];
    [self addChildViewController:votingTableVC];
    [votingTableVC didMoveToParentViewController:self];
    self.view.hidden = YES;
}

- (void)setSelfie:(PFObject *)selfie{
    if([((PFUser*)selfie[@"from"]).objectId isEqualToString:[PFUser currentUser].objectId]){
        //self.view.hidden = NO;
        [votingTableVC setSelfie:selfie];
    }else{
        self.view.hidden = YES;
    }
}

- (void) scrollTableView{

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:5 inSection:0];
    [votingTableVC.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
