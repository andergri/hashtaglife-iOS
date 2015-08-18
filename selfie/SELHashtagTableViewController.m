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
@synthesize lastQuery;
@synthesize trendingHashtags;

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
    trendingHashtags = [[NSMutableArray alloc] init];
    //[self popularHashtags];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(0,0,0,0)];
   
}

- (void) viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
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
    if (lastQuery.length == 0) {
        if(hashtags.count == 0) {
            return 0;
        }
        return hashtags.count + 2;
    }
    return hashtags.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HashtagTableViewCell" forIndexPath:indexPath];
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"HashtagTableViewCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"HashtagTableViewCell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    //cell.textLabel.text = [@"#" stringByAppendingString:[hashtags objectAtIndex:indexPath.item]];
    
    NSMutableAttributedString *attributedString;
    
    if (lastQuery.length == 0) {
        if (indexPath.item == 0) {
            attributedString = [[NSMutableAttributedString alloc] initWithString:@"popular"];
        }else if (indexPath.item == 1) {
            attributedString = [[NSMutableAttributedString alloc] initWithString:@"recent"];
       /** }else if (indexPath.item == 2) {
            attributedString = [[NSMutableAttributedString alloc] initWithString:@"my photos"]; **/
        }else if (indexPath.item == (hashtags.count + 2)) {
            attributedString = [[NSMutableAttributedString alloc] initWithString:@"     "];
        }else{
            attributedString = [[NSMutableAttributedString alloc] initWithString:[@"#" stringByAppendingString:[hashtags objectAtIndex:indexPath.item - 2]]];
        }
        
    }else{
        attributedString = [[NSMutableAttributedString alloc] initWithString:[@"#" stringByAppendingString:[hashtags objectAtIndex:indexPath.item]]];
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:28];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    [cell.textLabel.subviews.firstObject removeFromSuperview];
    
    if(lastQuery.length == 0 && indexPath.item < 5){
        [attributedString addAttribute:NSKernAttributeName
                                 value:@(1.5)
                                 range:NSMakeRange(0, 1)];
        cell.textLabel.attributedText = attributedString;
        if (indexPath.item == 0) {
            [cell.textLabel insertSubview:[self starLabel] aboveSubview:cell.textLabel];
        }else if(indexPath.item == 1){
            [cell.textLabel insertSubview:[self clockLabel] aboveSubview:cell.textLabel];
       /** }else if(indexPath.item == 2){
            [cell.textLabel insertSubview:[self profileLabel] aboveSubview:cell.textLabel];**/
        }else{
            [cell.textLabel insertSubview:[self arrowLabel] aboveSubview:cell.textLabel];
        }
    }else{
        [attributedString addAttribute:NSKernAttributeName
                                 value:@(1.5)
                                 range:NSMakeRange(0, 1)];
        cell.textLabel.attributedText = attributedString;
    }
    
    NSArray *colorArray = [[((SELMainViewController *) self.parentViewController) color] getColorArray];
    int i = indexPath.item % 10;
    cell.backgroundColor = [colorArray objectAtIndex:i];
    
    return cell;
}

- (UIView *)arrowLabel{
    UIView *arrowLabel = [[UIView alloc]init];
    arrowLabel.backgroundColor = [UIColor clearColor];
    arrowLabel.frame = CGRectMake(self.view.frame.size.width - 94, 1, 120, 76);
    arrowLabel.transform= CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-10));
    
    /**arrowLabel.text = [NSString stringWithUTF8String:"\u0362"];
    arrowLabel.textColor = [UIColor whiteColor];
    arrowLabel.font = [UIFont systemFontOfSize:31];
    arrowLabel.textAlignment = NSTextAlignmentCenter;
    arrowLabel.transform= CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(277.7));
    **/
    
    UIImage *trendingImage = [[UIImage imageNamed:@"trending"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *trendingImageView = [[UIImageView alloc] initWithImage:trendingImage];
    trendingImageView.frame = CGRectMake(20, 20, trendingImage.size.width, trendingImage.size.height);
    trendingImageView.contentMode = UIViewContentModeCenter;
    [trendingImageView setTintColor:[UIColor colorWithWhite:1. alpha:1]];
    [arrowLabel addSubview:trendingImageView];
    
    return arrowLabel;
}

- (UIView *)clockLabel{
    
    UIImage *clockImage = [[UIImage imageNamed:@"clock"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *clockImageView = [[UIImageView alloc] initWithImage:clockImage];
    clockImageView.frame = CGRectMake(258.5, 23, clockImage.size.width, clockImage.size.height);
    clockImageView.contentMode = UIViewContentModeCenter;
    [clockImageView setTintColor:[UIColor colorWithWhite:1. alpha:1]];
    return clockImageView;
}

- (UIView *)starLabel{
    UIImage *starImage = [[UIImage imageNamed:@"star"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *starImageView = [[UIImageView alloc] initWithImage:starImage];
    starImageView.frame = CGRectMake(260, 22, starImage.size.width, starImage.size.height);
    starImageView.contentMode = UIViewContentModeCenter;
    [starImageView setTintColor:[UIColor colorWithWhite:1. alpha:1]];
    return starImageView;
}

- (UIView *)profileLabel{
    UIImage *starImage = [[UIImage imageNamed:@"profile"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *starImageView = [[UIImageView alloc] initWithImage:starImage];
    starImageView.frame = CGRectMake(262.5, 23, starImage.size.width, starImage.size.height);
    starImageView.contentMode = UIViewContentModeCenter;
    [starImageView setTintColor:[UIColor colorWithWhite:1. alpha:1]];
    return starImageView;
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

#pragma - mark Parse Methods

- (void) searchForHashtag:(NSString *)query{
    
    //query = [query lowercaseString];
    query = [query stringByReplacingOccurrencesOfString:@"#" withString:@""];
    query = [query stringByReplacingOccurrencesOfString:@" " withString:@""];
    lastQuery = query;
    [self scrollViewDidScroll:nil];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    NSLog(@"hashtag serach %@", query);
    if (query.length == 0) {
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
            for (PFObject * tag in hashtagsResults) {
                [hashtags addObject:tag[@"name"]];
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
            for (PFObject * tag in hashtagsResults) {
                [hashtags addObject:tag[@"name"]];
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

// Refresh
- (void)refresh:(id)sender {
    [(UIRefreshControl *)sender endRefreshing];
    [self searchForHashtag:lastQuery];
}

@end
