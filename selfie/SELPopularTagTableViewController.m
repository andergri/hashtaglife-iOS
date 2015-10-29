//
//  SELPopularTagTableViewController.m
//  #life
//
//  Created by Griffin Anderson on 10/21/15.
//  Copyright © 2015 Griffin Anderson. All rights reserved.
//

#import "SELPopularTagTableViewController.h"

@interface SELPopularTagTableViewController ()

@property NSMutableArray *popularTags;

@end

@implementation SELPopularTagTableViewController

@synthesize color;
@synthesize popularTags;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    popularTags = [[NSMutableArray alloc] init];
    
    // y = 140
    self.tableView.frame = CGRectMake(0, 350, self.tableView.frame.size.width, 120);
    [self.tableView setDelegate:self];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"HashtagTableViewCell"];
    self.tableView.dataSource = self;
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.tableView setSeparatorColor:[UIColor colorWithWhite:.9 alpha:1]];
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(0,0,0,0)];
    [self.tableView setAllowsSelection:YES];
    if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    [self.tableView setSeparatorColor:[UIColor colorWithWhite:.95 alpha:1]];
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 1.0f);
    topBorder.backgroundColor = [UIColor colorWithWhite:1.0 alpha:.15f].CGColor;
    [self.tableView.layer addSublayer:topBorder];
    
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.tableView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(4.0, 4.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.tableView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.tableView.layer.mask = maskLayer;
    
}

- (void) viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    [self getPopularTags];
}

- (void) getPopularTags{
    PFQuery *hashtagItem = [PFQuery queryWithClassName:@"Tag"];
    if ([[PFUser currentUser] objectForKey:@"location"]) {
        [hashtagItem whereKey:@"location" equalTo:[[PFUser currentUser] objectForKey:@"location"]];
    }
    [hashtagItem orderByAscending:@"following"];
    hashtagItem.limit = 5;
    [hashtagItem findObjectsInBackgroundWithBlock:^(NSArray *hashtagsResults, NSError *error) {
        if (!error) {
            NSLog(@"FL %lu #'s", (unsigned long)hashtagsResults.count);
            [popularTags removeAllObjects];
            for (PFObject * tag in hashtagsResults) {
                [popularTags addObject:tag[@"name"]];
            }
            [self.tableView reloadData];
        }else{
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return popularTags.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"HashtagTableViewCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"HashtagTableViewCell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor colorWithWhite:.4 alpha:1];
    [cell.textLabel.subviews.firstObject removeFromSuperview];
    cell.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
    UIColor *acolor = [color getPrimaryColor];

        cell.textLabel.text = @"my photos";
        cell.textLabel.font = [UIFont systemFontOfSize:27];
        cell.textLabel.textColor = acolor;
        [cell.textLabel insertSubview:[self followLabel:acolor] aboveSubview:cell.textLabel];
    
    return cell;
}


- (UIView *)followLabel:(UIColor *)acolor{
    UIImage *starImage = [[UIImage imageNamed:@"profile"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *starImageView = [[UIImageView alloc] initWithImage:starImage];
    starImageView.frame = CGRectMake(262.5, 23, starImage.size.width, starImage.size.height);
    starImageView.contentMode = UIViewContentModeCenter;
    [starImageView setTintColor:acolor];
    return starImageView;
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50.0f;
}

@end