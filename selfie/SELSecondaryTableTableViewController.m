//
//  SELSecondaryTableTableViewController.m
//  #life
//
//  Created by Griffin Anderson on 3/22/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import "SELSecondaryTableTableViewController.h"

@interface SELSecondaryTableTableViewController ()

@property NSString *schoolName;
//@property (nonatomic, strong) NSMutableArray *hashtags;

@end

@implementation SELSecondaryTableTableViewController

@synthesize color;
@synthesize schoolName;
//@synthesize hashtags;

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
    
    //hashtags = [[NSMutableArray alloc] init];
    // y = 140
    self.tableView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 261.5);
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
    
    //[self getFeaturedHashtags];
    
    // Set School Name
    /**
    [[[PFUser currentUser] objectForKey:@"location" ] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object) {
            if ([object objectForKey:@"name"]) {
                schoolName= [object objectForKey:@"name"];
            }else{
                schoolName = @"My School";
            }
        }else{
            schoolName = @"My School";
        }
    }];**/
}

- (void) viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    /**@try {
        [hashtags objectAtIndex:0];
    }
    @catch (NSException *exception) {
        [self getFeaturedHashtags];
    }**/
    
    // School Name
    /**
    [[[PFUser currentUser] objectForKey:@"location"] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if ([[[PFUser currentUser] objectForKey:@"location"] objectForKey:@"name"]) {
            schoolName= [[[PFUser currentUser] objectForKey:@"location"] objectForKey:@"name"];
            [self.tableView reloadData];
        }else{
            schoolName = @"My School";
            [self.tableView reloadData];
        }
    }];**/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }else if(section == 1){
        return 3;
    }
    return 0;
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
    /**
    if (indexPath.section == 1) {
        
        NSMutableAttributedString *attributedString;
        cell.textLabel.textColor = acolor;
        @try {
            attributedString = [[NSMutableAttributedString alloc] initWithString:[@"#" stringByAppendingString:[hashtags objectAtIndex:indexPath.item]]];
            
        }
        @catch (NSException *exception) {
            cell.textLabel.textColor = [UIColor whiteColor];
            attributedString = [[NSMutableAttributedString alloc] initWithString:@"#life"];
        }
        [attributedString addAttribute:NSKernAttributeName
                                 value:@(2.0)
                                 range:NSMakeRange(0, 1)];
        cell.textLabel.attributedText = attributedString;
        cell.imageView.image = nil;
        cell.textLabel.font = [UIFont systemFontOfSize:27];
        [cell.textLabel insertSubview:[self globeLabel:acolor] aboveSubview:cell.textLabel];
    }else
    **/
    if(indexPath.section == 0){
        cell.textLabel.text = @"my photos";
        cell.textLabel.font = [UIFont systemFontOfSize:27];
        cell.textLabel.textColor = acolor;
        [cell.textLabel insertSubview:[self profileLabel:acolor] aboveSubview:cell.textLabel];
    }else if(indexPath.section == 1){
        if (indexPath.item == 0) {
            cell.imageView.transform = CGAffineTransformMakeScale(.62, .62);
            cell.textLabel.text = @" Share #life";
            [self shareGraphic:acolor  imageView:cell.imageView];
        }else if (indexPath.item == 1) {
            cell.imageView.transform = CGAffineTransformMakeScale(.68, .68);
            cell.textLabel.text = @" Safety Information";
            [self sheildGraphic:acolor  imageView:cell.imageView];
        }else if (indexPath.item == 2) {
            cell.imageView.transform = CGAffineTransformMakeScale(.8, .8);
            cell.textLabel.text = @"Change Location";
            [self planeGraphic:acolor  imageView:cell.imageView];
        }
    }
    
    return cell;
}


- (void)shareGraphic:(UIColor *)acolor imageView:(UIImageView*)imageView{
    UIImage *starImage = [[UIImage imageNamed:@"share"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    imageView.image = starImage;
    imageView.contentMode = UIViewContentModeRight;
    [imageView setTintColor:acolor];
}

- (void)sheildGraphic:(UIColor *)acolor imageView:(UIImageView*)imageView{
    UIImage *starImage = [[UIImage imageNamed:@"sheild"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    imageView.image = starImage;
    imageView.contentMode = UIViewContentModeRight;
    [imageView setTintColor:acolor];
}

- (void)planeGraphic:(UIColor *)acolor imageView:(UIImageView*)imageView{
    UIImage *starImage = [[UIImage imageNamed:@"plane"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    imageView.image = starImage;
    imageView.contentMode = UIViewContentModeRight;
    [imageView setTintColor:acolor];
}

- (void)globeGraphic:(UIColor *)acolor imageView:(UIImageView*)imageView{
    UIImage *starImage = [[UIImage imageNamed:@"globe"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    imageView.image = starImage;
    imageView.contentMode = UIViewContentModeCenter;
    [imageView setTintColor:acolor];
}

- (void)locationGraphic:(UIColor *)acolor imageView:(UIImageView*)imageView{
    UIImage *starImage = [[UIImage imageNamed:@"location"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    imageView.image = starImage;
    imageView.contentMode = UIViewContentModeCenter;
    [imageView setTintColor:acolor];
}


- (UIView *)globeLabel:(UIColor *)acolor{
    UIImage *starImage = [[UIImage imageNamed:@"globe"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *starImageView = [[UIImageView alloc] initWithImage:starImage];
    starImageView.frame = CGRectMake(262.5, 23, starImage.size.width, starImage.size.height);
    starImageView.contentMode = UIViewContentModeCenter;
    starImageView.transform = CGAffineTransformMakeScale(.85, .85);
    [starImageView setTintColor:acolor];
    return starImageView;
}

- (UIView *)profileLabel:(UIColor *)acolor{
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
     if (section == 0)
         return 0.0f;
     if (section == 1)
         return 10.0f;
     //if (section == 2)
     //    return 35.0f;
    return 0.0f;
 }
 
 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
 
     if (section == 0)
         return @"";
     if (section == 1)
         return @"Settings";
     //if (section == 2)
     //    return @"Settings";
     return @"";
 }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return 72.0f;
    }else if(indexPath.section == 1){
        return 60.0f;
    //}else if(indexPath.section == 2){
    //    return 60.0f;
    }
    return 0.0f;
}


 - (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
     
     if (section == 1 || section == 2) {
         
         
         UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, tableView.tableHeaderView.frame.size.height)];
         headerLabel.tag = section;
         headerLabel.backgroundColor = [UIColor colorWithWhite:.98 alpha:1];;
         //headerLabel.text = @"    Settings";
         headerLabel.textColor = [UIColor colorWithWhite:.8 alpha:1];
         headerLabel.font = [UIFont boldSystemFontOfSize:15];
         headerLabel.textAlignment = NSTextAlignmentLeft;
         
         //UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 34, 320, 1)];
         //line.backgroundColor = [UIColor colorWithWhite:.8 alpha:.4f];
         //[headerLabel addSubview:line];
         
         if (section == 2) {
          //   headerLabel.text = @"    Settings";
         }
         
         return headerLabel;
     }else{
         return nil;
     }
 }

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 0) {
        [(SELPageViewController*)(self.parentViewController.parentViewController) showSelfies:3 hashtag:@"" color:cell.textLabel.textColor global:YES objectId:nil];
    /**}else if(indexPath.section == 1){
        //show photos
        [(SELPageViewController*)(self.parentViewController.parentViewController) showSelfies:2 hashtag:[hashtags objectAtIndex:indexPath.item] color:cell.textLabel.textColor global:YES objectId:nil];
     **/
    }else if(indexPath.section == 1){
        //change location
        if (indexPath.item == 0) {
            [self shareTapped];
        }else if(indexPath.item == 1){
            [self safetyTapped];
        }else if(indexPath.item == 2){
            [(SELPageViewController*)(self.parentViewController.parentViewController) changeLocation];
        }else{}
    }
    return;
}

// CheckMark
- (void) cleanCheckmark:(int)row{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 0) {
        if(indexPath.item == 0 || indexPath.item == 1){
            cell.accessoryView = nil;
        }
    }
}

- (void) setCheckmark:(UITableViewCell*)cell{
    
    UIImage *starImage = [[UIImage imageNamed:@"checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *starImageView = [[UIImageView alloc] initWithImage:starImage];
    starImageView.frame = CGRectMake(0, 0, starImage.size.width, starImage.size.height);
    starImageView.contentMode = UIViewContentModeCenter;
    [starImageView setTintColor:[[color getColorArray] objectAtIndex:0]];
    cell.accessoryView = starImageView;
    cell.accessoryView.contentScaleFactor = 2.5;
}

/**
- (void) getFeaturedHashtags{

    PFQuery *ahashtagItem = [PFQuery queryWithClassName:@"Trending"];
    [ahashtagItem whereKey:@"active" equalTo:@YES];
    [ahashtagItem orderByDescending:@"trending"];
    [ahashtagItem addDescendingOrder:@"name"];
    ahashtagItem.limit = 24;
    [ahashtagItem findObjectsInBackgroundWithBlock:^(NSArray *hashtagsResults, NSError *error) {
        if (!error) {
            NSLog(@"FH %lu #'s", (unsigned long)hashtagsResults.count);
            for (PFObject * tag in hashtagsResults) {
                if (![hashtags containsObject:tag[@"name"]]) {
                    [hashtags addObject:tag[@"name"]];
                }
            }
            [self.tableView reloadData];
        }
    }];
}

**/

/**
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
**/

- (void) safetyTapped{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.hashtaglifeapp.com/community"]];
}

- (void) shareTapped{
    NSString *_postText = [NSString stringWithFormat:@"Check out #life app on the app store @ https://itunes.apple.com/us/app/life-hashtag-your-life/id904884186"];
    NSArray *activityItems = nil;
    activityItems = @[_postText];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:^{
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder
                        createEventWithCategory:@"UX"
                        action:@"taped share b"
                        label:@""
                        value:nil] build]];
    }];
}
@end
