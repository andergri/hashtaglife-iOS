//
//  SELHashtagTableViewController.m
//  selfie
//
//  Created by Griffin Anderson on 7/19/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import "SELHashtagTableViewController.h"
#import "SELMainViewController.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface SELHashtagTableViewController ()

@property NSString* lastQuery;
@property NSMutableArray *trendingHashtags;

@end

@implementation SELHashtagTableViewController

@synthesize hashtags;
@synthesize objectsH;
@synthesize inbox;
@synthesize inboxSeen;
@synthesize lastQuery;
@synthesize trendingHashtags;
@synthesize subscribed;

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
    
    [self.tableView setDelegate:self];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"HashtagTableViewCell"];
    self.tableView.dataSource = self;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    //refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
    hashtags = [[NSMutableArray alloc] init];
    objectsH = [[NSMutableArray alloc] init];
    inbox = [[NSMutableArray alloc] init];
    inboxSeen = [[NSMutableArray alloc] init];
    subscribed = [[NSMutableArray alloc] init];
    trendingHashtags = [[NSMutableArray alloc] init];
    //[self popularHashtags];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(0,0,0,0)];
   
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self getSubscribedHashtagsList];
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
        if (lastQuery.length == 0) {
            return inbox.count;
        }
        return 0;
    }else{
        if (lastQuery.length == 0) {
            if(hashtags.count == 0) {
                return 0;
            }
            return hashtags.count + 2;
        }
        return hashtags.count;
    }
}

/** }else if (indexPath.item == 2) {
 attributedString = [[NSMutableAttributedString alloc] initWithString:@"my photos"]; **/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *colorArray = [[((SELMainViewController *) self.parentViewController) color] getColorArray];
    int i = indexPath.item % 10;
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"HashtagTableViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"HashtagTableViewCell"];
    }
    
    UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 270, 72.0f)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tagLabel.font = [UIFont systemFontOfSize:28];
    tagLabel.textColor = [UIColor whiteColor];
    for (UIView *subView in cell.subviews) {
        [subView removeFromSuperview];
    }
    cell.backgroundColor = [colorArray objectAtIndex:i];
    
    NSMutableAttributedString *attributedString;
    
    if (indexPath.section == 1) {
    
    if (lastQuery.length == 0) {
        if (indexPath.item == 0) {
            attributedString = [[NSMutableAttributedString alloc] initWithString:@"popular"];
            [cell insertSubview:[self starLabel] aboveSubview:cell.textLabel];
        }else if (indexPath.item == 1) {
            attributedString = [[NSMutableAttributedString alloc] initWithString:@"recent"];
            [cell insertSubview:[self clockLabel] aboveSubview:cell.textLabel];
        }else if(indexPath.item < 5){
            attributedString = [[NSMutableAttributedString alloc] initWithString:[@"#" stringByAppendingString:[hashtags objectAtIndex:indexPath.item - 2]]];
            [attributedString addAttribute:NSKernAttributeName value:@(1.5) range:NSMakeRange(0, 1)];
            [cell insertSubview:[self arrowLabel:[attributedString size].width color:[colorArray objectAtIndex:i]] aboveSubview:cell.textLabel];
            int followCount = [[[objectsH objectAtIndex:indexPath.item - 2] objectForKey:@"followers"] intValue];
            [cell insertSubview:[self joinGroupLabel:[hashtags objectAtIndex:indexPath.item - 2] color:[colorArray objectAtIndex:i] count:followCount] aboveSubview:cell.textLabel];
        }else if (indexPath.item == (hashtags.count + 2)) {
            attributedString = [[NSMutableAttributedString alloc] initWithString:@"     "];
        }else{
            attributedString = [[NSMutableAttributedString alloc] initWithString:[@"#" stringByAppendingString:[hashtags objectAtIndex:indexPath.item - 2]]];
            [attributedString addAttribute:NSKernAttributeName value:@(1.5) range:NSMakeRange(0, 1)];
            int followCount = [[[objectsH objectAtIndex:indexPath.item - 2] objectForKey:@"followers"] intValue];
            [cell insertSubview:[self joinGroupLabel:[hashtags objectAtIndex:indexPath.item - 2] color:[colorArray objectAtIndex:i] count:followCount] aboveSubview:cell.textLabel];
        }
        
    }else{
        attributedString = [[NSMutableAttributedString alloc] initWithString:[@"#" stringByAppendingString:[hashtags objectAtIndex:indexPath.item]]];
        [attributedString addAttribute:NSKernAttributeName value:@(1.5) range:NSMakeRange(0, 1)];
        int followCount = [[[objectsH objectAtIndex:indexPath.item] objectForKey:@"followers"] intValue];
        [cell insertSubview:[self joinGroupLabel:[hashtags objectAtIndex:indexPath.item] color:[colorArray objectAtIndex:i] count:followCount] aboveSubview:cell.textLabel];
    }

    // section 0
    }else{
        
        UIView *bg;
        //int followCount = [[[objectsH objectAtIndex:indexPath.item] objectForKey:@"followers"] intValue];
        //[cell insertSubview:[self joinGroupLabel:[inbox objectAtIndex:indexPath.item] color:[colorArray objectAtIndex:i] count:followCount] aboveSubview:cell.textLabel];
        bg = [self backgroundView:72 color:[colorArray objectAtIndex:i]];
        [cell insertSubview:bg atIndex:0];
        attributedString = [[NSMutableAttributedString alloc] initWithString:[@"#" stringByAppendingString:[inbox objectAtIndex:indexPath.item]]];
        [attributedString addAttribute:NSKernAttributeName value:@(1.5) range:NSMakeRange(0, 1)];
        if (![inboxSeen containsObject:[inbox objectAtIndex:indexPath.item]]) {
            [cell insertSubview:[self countLabel:1 color:[colorArray objectAtIndex:i]] aboveSubview:cell.textLabel];
        }
    }

    tagLabel.attributedText = attributedString;
    [cell addSubview:tagLabel];
    
    return cell;
}

- (UIView *)arrowLabel:(int)distance color:(UIColor*)color{
    UIView *arrowLabel = [[UIView alloc]init];
    arrowLabel.backgroundColor = [UIColor clearColor];
    NSLog(@"distance %d", distance);
    arrowLabel.frame = CGRectMake( (distance * 2.3) + 9, 19.5, 40, 40);
    arrowLabel.transform= CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-5));
    //self.view.frame.size.width - 79
    /**arrowLabel.text = [NSString stringWithUTF8String:"\u0362"];
    arrowLabel.textColor = [UIColor whiteColor];
    arrowLabel.font = [UIFont systemFontOfSize:31];
    arrowLabel.textAlignment = NSTextAlignmentCenter;
    arrowLabel.transform= CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(277.7));
    **/
    
    UIImage *trendingImage = [[UIImage imageNamed:@"trending"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *trendingImageView = [[UIImageView alloc] initWithImage:trendingImage];
    trendingImageView.frame = CGRectMake(0, 0, 40, 40);
    trendingImageView.transform = CGAffineTransformScale(trendingImageView.transform, 0.37, 0.37);
    trendingImageView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    trendingImageView.layer.cornerRadius = 20;
    //trendingImageView.layer.borderColor = [UIColor colorWithWhite:0 alpha:0].CGColor;
    //trendingImageView.layer.borderWidth = 2.0f;
    trendingImageView.contentMode = UIViewContentModeCenter;
    [trendingImageView setTintColor:color];
    
    if (distance < 100) {
        [arrowLabel addSubview:trendingImageView];
    }
    
    return arrowLabel;
}

- (UIView *)clockLabel{
    
    UIImage *clockImage = [[UIImage imageNamed:@"clock"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *clockImageView = [[UIImageView alloc] initWithImage:clockImage];
    clockImageView.frame = CGRectMake(272.5, 23, clockImage.size.width, clockImage.size.height);
    clockImageView.contentMode = UIViewContentModeCenter;
    [clockImageView setTintColor:[UIColor colorWithWhite:1. alpha:1]];
    return clockImageView;
}

- (UIView *)starLabel{
    UIImage *starImage = [[UIImage imageNamed:@"star"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *starImageView = [[UIImageView alloc] initWithImage:starImage];
    starImageView.frame = CGRectMake(275, 22, starImage.size.width, starImage.size.height);
    starImageView.contentMode = UIViewContentModeCenter;
    [starImageView setTintColor:[UIColor colorWithWhite:1. alpha:1]];
    return starImageView;
}

- (UIView *)profileLabel{
    UIImage *starImage = [[UIImage imageNamed:@"profile"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *starImageView = [[UIImageView alloc] initWithImage:starImage];
    starImageView.frame = CGRectMake(277.5, 23, starImage.size.width, starImage.size.height);
    starImageView.contentMode = UIViewContentModeCenter;
    [starImageView setTintColor:[UIColor colorWithWhite:1. alpha:1]];
    return starImageView;
}

- (UIView *)joinGroupLabel:(NSString*)hashtag color:(UIColor *)color count:(int)count{

    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 6, 320, 60)];
    
    /**
    UIImage *groupImage = [[UIImage imageNamed:@"group"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *groupImageView = [[UIImageView alloc] initWithImage:groupImage];
    groupImageView.frame = CGRectMake(25, 8, groupImage.size.width, groupImage.size.height);
    groupImageView.contentMode = UIViewContentModeCenter;
    [groupImageView setTintColor:[UIColor whiteColor]];
     [groupButton addSubview:groupImageView];
    **/
    
    UILabel *groupLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 18)];
    groupLabel.text = @"follow";
    groupLabel.textColor = [UIColor colorWithWhite:0 alpha:.3];
    groupLabel.font = [UIFont systemFontOfSize:12.0f];
    groupLabel.textAlignment = NSTextAlignmentCenter;
    UIButton *groupButton = [[UIButton alloc] initWithFrame:CGRectMake(264.5, 15, 50, 40)];
    [groupButton addSubview:groupLabel];
    
    //groupButton.backgroundColor = [UIColor redColor];
    //groupButton.layer.borderColor = [UIColor colorWithWhite:0 alpha:.3].CGColor;
    //groupButton.layer.borderWidth = .7f;
    //groupButton.layer.cornerRadius = 3.0f;

    UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 18, 50, 17)];
    countLabel.text = [NSString stringWithFormat:@"%d", count];
    countLabel.textAlignment = NSTextAlignmentCenter;
    countLabel.textColor = [UIColor colorWithWhite:0 alpha:.3];
    countLabel.font = [UIFont systemFontOfSize:9.0f];
    CALayer *upperBorder = [CALayer layer];
    upperBorder.backgroundColor = [[UIColor colorWithWhite:0 alpha:.3] CGColor];
    upperBorder.frame = CGRectMake(20, 0, 10, .5f);
    [countLabel.layer addSublayer:upperBorder];
     
    if ([subscribed containsObject:hashtag]) {

        groupLabel.text = @"following";
        groupLabel.textColor = [UIColor whiteColor];
        groupLabel.font = [UIFont systemFontOfSize:10.5f];
        countLabel.textColor = [UIColor whiteColor];
        countLabel.text = [NSString stringWithFormat:@"%d", count + 1];
        upperBorder.backgroundColor = [UIColor whiteColor].CGColor;
    }
    /**
    UIImage *exitImage = [[UIImage imageNamed:@"reply"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *exitImageView = [[UIImageView alloc] initWithImage:exitImage];
    exitImageView.frame = CGRectMake(10, 8, exitImage.size.width, exitImage.size.height);
    exitImageView.contentMode = UIViewContentModeCenter;
    exitImageView.transform = CGAffineTransformScale(exitImageView.transform, 0.7, 0.7);
    [exitImageView setTintColor:[UIColor whiteColor]];
    UILabel *exitLabel = [[UILabel alloc] initWithFrame:CGRectMake(38, 0, 80, 40)];
    exitLabel.text = @"Contribute";
    exitLabel.textColor = [UIColor whiteColor];
    exitLabel.font = [UIFont systemFontOfSize:14.0f];
    UIButton *exitButton = [[UIButton alloc] initWithFrame:CGRectMake(170, 10, 125, 40)];
    exitButton.backgroundColor = [UIColor clearColor];
    exitButton.layer.borderColor = [UIColor whiteColor].CGColor;
    exitButton.layer.borderWidth = 1.5f;
    exitButton.layer.cornerRadius = 5.0f;
    [exitButton addSubview:exitImageView];
    [exitButton addSubview:exitLabel];
    
    
    if ([inbox containsObject:hashtag]) {
        groupButton.hidden = YES;
        exitButton.frame = CGRectMake(10, 10, 280, 40);
        exitLabel.frame = CGRectMake(135, 0, 80, 40);
        exitImageView.frame = CGRectMake(107, 8, exitImage.size.width, exitImage.size.height);
        exitLabel.text = @"Reply";
    }
    **/
    groupButton.enabled = NO;
    //exitButton.enabled = NO;
    
    //countLabel.
    //countLabel.backgroundColor = [UIColor yellowColor];
    
    [container addSubview:groupButton];
    //[container addSubview:exitButton];
    [groupButton addSubview:countLabel];
    return container;
}

- (UIView *)countLabel:(int)count color:(UIColor*)color{

    UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    countLabel.text = [NSString stringWithFormat:@"%d", count];
    countLabel.textAlignment = NSTextAlignmentCenter;
    countLabel.textColor = color;
    countLabel.font = [UIFont systemFontOfSize:22];
    countLabel.backgroundColor = [UIColor clearColor];
    
    UIView *countView = [[UIView alloc] initWithFrame:CGRectMake(271, 20, 40, 40)];
    countView.backgroundColor = [UIColor whiteColor];
    countView.layer.cornerRadius = countView.frame.size.width / 2.0;
    [countView addSubview:countLabel];
    
    return countView;
}

- (UIView *)backgroundView:(int)height color:(UIColor*)color{
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, height)];
    bgView.backgroundColor = color;
    bgView.alpha = .75;
    bgView.clipsToBounds = YES;
    
    UIImageView *bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, height)];
    bgImage.contentMode = UIViewContentModeScaleAspectFill;
    bgImage.image = [UIImage imageNamed:@"pttrnbackground"];
    bgImage.clipsToBounds = true;
    [bgImage addSubview:bgView];
    bgImage.alpha = .92;
    bgImage.clipsToBounds = YES;
    
    return bgImage;
}

/**
- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (lastQuery.length > 0)
        return 0.0f;
    return 72.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    
    if (lastQuery.length == 0) {
        if (section == 0) {
            return @"";
        }else{
            return @"";
        }
    }else{
        return nil;
    }
}**/


/**
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (lastQuery.length > 0)
        return 0.0f;
    return 72.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (lastQuery.length == 0) {
        if (section == 0) {
            return @"";
        }else{
            return @"";
        }
    }else{
        return nil;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (hashtags.count > 0) {
        
        UILabel *headerLabel = [[UILabel alloc]init];
        headerLabel.tag = section;
        headerLabel.userInteractionEnabled = YES;
        NSArray *colorArray = [[((SELMainViewController *) self.parentViewController) color] getColorArray];
        if (section == 0) {
            headerLabel.backgroundColor = [colorArray objectAtIndex:0];
            headerLabel.text = @"#popular";
        }else{
            headerLabel.backgroundColor = [colorArray objectAtIndex:1];
            headerLabel.text = @"#fresh";
        }
        
        headerLabel.textColor = [UIColor whiteColor];
        headerLabel.font = [UIFont systemFontOfSize:28];
        headerLabel.textAlignment = NSTextAlignmentLeft;
        headerLabel.frame = CGRectMake(0, 0, tableView.tableHeaderView.frame.size.width, tableView.tableHeaderView.frame.size.height);
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(catchHeaderSubmission:)];
        tapGesture.cancelsTouchesInView = NO;
        tapGesture.view.tag = section;
        [headerLabel addGestureRecognizer:tapGesture];
        
        return headerLabel;
    }else{
        return nil;
    }
}
**/



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma - mark UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)activeScrollView{
    [(SELMainViewController *) self.parentViewController dismissKeyboard];
    [(SELMainViewController *) self.parentViewController showCameraIcon:NO];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
     [(SELMainViewController *) self.parentViewController showCameraIcon:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        [(SELMainViewController *) self.parentViewController showCameraIcon:YES];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint p = scrollView.contentOffset;
    CGFloat height;
    
    if (lastQuery.length == 0) {
        height = (float) 72.0;
    }else{
        height = (float) 0.0;
    }
    
    if (p.y <= height && p.y >= 0) {
        self.tableView.contentInset = UIEdgeInsetsMake(-p.y, 0, 0, 0);
    } else if (p.y >= height) {
        self.tableView.contentInset = UIEdgeInsetsMake(-height, 0, 0, 0);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72.0f;
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma - mark inbox

- (void) getInbox{

    if([PFUser currentUser]){
    
    PFQuery *queryInbox = [PFQuery queryWithClassName:@"Inbox"];
    [queryInbox whereKey:@"user"  equalTo:[PFUser currentUser]];
    [queryInbox whereKey:@"has_seen" equalTo:@NO];
    [queryInbox findObjectsInBackgroundWithBlock:^(NSArray *hashtagsResults, NSError *error) {
        
        if (!error) {
            NSLog(@"Inbox %lu #'s", (unsigned long)hashtagsResults.count);
            [inbox removeAllObjects];
            for (PFObject * tag in hashtagsResults) {
                if (![inbox containsObject:tag[@"hashtag"]]) {
                    [inbox addObject:tag[@"hashtag"]];
                }
            }
            [self.tableView reloadData];
        }else{
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    }
}

- (void) markInbox:(NSString *)hashtag{
    [inboxSeen addObject:hashtag];
    PFQuery *queryInbox = [PFQuery queryWithClassName:@"Inbox"];
    [queryInbox whereKey:@"user"  equalTo:[PFUser currentUser]];
    [queryInbox whereKey:@"has_seen" equalTo:@NO];
    [queryInbox whereKey:@"hashtag" equalTo:hashtag];
    [queryInbox findObjectsInBackgroundWithBlock:^(NSArray *hashtagsResults, NSError *error) {
        if (!error) {
            NSLog(@"Inbox Mark %lu #'s", (unsigned long)hashtagsResults.count);
            for (PFObject * inboxMark in hashtagsResults) {
                inboxMark[@"has_seen"] = @YES;
                [inboxMark saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                }];
            }
        }else{
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

}

#pragma - mark Parse Methods

- (void) searchForHashtag:(NSString *)query{
    [inboxSeen removeAllObjects];
    //query = [query lowercaseString];
    query = [query stringByReplacingOccurrencesOfString:@"#" withString:@""];
    query = [query stringByReplacingOccurrencesOfString:@" " withString:@""];
    lastQuery = query;
    [self scrollViewDidScroll:nil];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    NSLog(@"hashtag serach %@", query);
    if (query.length == 0) {
        [self getInbox];
        [self popularHashtags];
        return;
    }
    
    PFQuery *queryHashtag;
    [[[PFUser currentUser] objectForKey:@"location" ] fetchIfNeeded];
    if (([[PFUser currentUser] objectForKey:@"location"]) && ([[[[PFUser currentUser] objectForKey:@"location"] objectForKey:@"default"] boolValue])) {
        queryHashtag = [PFQuery queryWithClassName:@"Tag"];
        [queryHashtag whereKey:@"location" equalTo:[[PFUser currentUser] objectForKey:@"location"]];
    }else{
        queryHashtag = [PFQuery queryWithClassName:@"Hashtag"];
    }
    
    [queryHashtag whereKey:@"name"  containsString:query];
    [queryHashtag whereKey:@"count" greaterThan:@0];
    [queryHashtag orderByDescending:@"count"];
    [queryHashtag findObjectsInBackgroundWithBlock:^(NSArray *hashtagsResults, NSError *error) {
        if (!error) {
            NSLog(@"SR %lu #'s", (unsigned long)hashtagsResults.count);
            [hashtags removeAllObjects];
            [objectsH removeAllObjects];
            for (PFObject * tag in hashtagsResults) {
                [hashtags addObject:tag[@"name"]];
                [objectsH addObject:tag];
            }
            NSLog(@"count %lu", (unsigned long)hashtags.count);
            [self.tableView reloadData];
        }else{
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void) popularHashtags{
    
    PFQuery *hashtagItem;
    [[[PFUser currentUser] objectForKey:@"location" ] fetchIfNeeded];
    if (([[PFUser currentUser] objectForKey:@"location"]) && ([[[[PFUser currentUser] objectForKey:@"location"] objectForKey:@"default"] boolValue])) {
        hashtagItem = [PFQuery queryWithClassName:@"Tag"];
        [hashtagItem whereKey:@"location" equalTo:[[PFUser currentUser] objectForKey:@"location"]];
    }else{
        hashtagItem = [PFQuery queryWithClassName:@"Hashtag"];
    }
    [hashtagItem whereKey:@"count" greaterThan:@0];
    [hashtagItem whereKey:@"trending" greaterThan:@(-1)];
    [hashtagItem orderByDescending:@"trending"];
    hashtagItem.limit = 18;
    [hashtagItem findObjectsInBackgroundWithBlock:^(NSArray *hashtagsResults, NSError *error) {
        if (!error) {
            NSLog(@"SR %lu #'s", (unsigned long)hashtagsResults.count);
            [hashtags removeAllObjects];
            [objectsH removeAllObjects];
            for (PFObject * tag in hashtagsResults) {
                [hashtags addObject:tag[@"name"]];
                [objectsH addObject:tag];
            }
            [self.tableView reloadData];
        }else{
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    /**
    PFQuery *ahashtagItem = [PFQuery queryWithClassName:@"Trending"];
    [ahashtagItem whereKey:@"active" equalTo:@YES];
    [ahashtagItem orderByDescending:@"trending"];
    [ahashtagItem addDescendingOrder:@"name"];
    ahashtagItem.limit = 24;
    [ahashtagItem findObjectsInBackgroundWithBlock:^(NSArray *hashtagsResults, NSError *error) {
        if (!error) {
            NSLog(@"SR %lu #'s", (unsigned long)hashtagsResults.count);
            if(notPassedLocation && notPassedTrending){
                [hashtags removeAllObjects];
                notPassedTrending = NO;
            }
            for (PFObject * tag in hashtagsResults) {
                if (![hashtags containsObject:tag[@"name"]]) {
                    
            
            NSUInteger newIndex = [hashtags indexOfObject:tag[@"name"]
                                             inSortedRange:(NSRange){0, [hashtags count]}
                                                   options:NSBinarySearchingInsertionIndex
                                              usingComparator:^(id obj1, id obj2) {
                                                  BOOL isPunct1 = [[NSCharacterSet punctuationCharacterSet] characterIsMember:[(NSString*)obj1 characterAtIndex:0]];
                                                  BOOL isPunct2 = [[NSCharacterSet punctuationCharacterSet] characterIsMember:[(NSString*)obj2 characterAtIndex:0]];
                                                  if (isPunct1 && !isPunct2) {
                                                      return NSOrderedAscending;
                                                  } else if (!isPunct1 && isPunct2) {
                                                      return NSOrderedDescending;
                                                  }
                                                  return [(NSString*)obj1 compare:obj2 options:NSDiacriticInsensitiveSearch|NSCaseInsensitiveSearch];         

                                              }];
                    
            [hashtags insertObject:tag[@"name"] atIndex:newIndex];
                
                }
            }
            [trendingHashtags removeAllObjects];
            for (PFObject * tag in hashtagsResults) {
                if([hashtagsResults indexOfObject:tag] < 3){
                    [hashtags removeObjectIdenticalTo:tag[@"name"]];
                    [hashtags insertObject:tag[@"name"] atIndex:0];
                    [trendingHashtags addObject:tag[@"name"]];
                }
            }
            [self.tableView reloadData];
        }else{
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    **/
}

- (void) getSubscribedHashtagsList{

    if ([PFUser currentUser]) {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Subscribe"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [subscribed removeAllObjects];
            for (PFObject * tag in objects) {
                [subscribed addObject:tag[@"hashtag"]];
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    }
}

// Refresh
- (void)refresh:(id)sender {
    [(UIRefreshControl *)sender endRefreshing];
    [self searchForHashtag:lastQuery];
}
@end
