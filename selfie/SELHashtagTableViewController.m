//
//  SELHashtagTableViewController.m
//  selfie
//
//  Created by Griffin Anderson on 7/19/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import "SELHashtagTableViewController.h"
#import "SELMainViewController.h"

@interface SELHashtagTableViewController ()

@property NSString* lastQuery;

@end

@implementation SELHashtagTableViewController

@synthesize hashtags;
@synthesize lastQuery;

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
    
    
    //refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
    hashtags = [[NSMutableArray alloc] init];
    [self popularHashtags];
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
    return hashtags.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HashtagTableViewCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [@"#" stringByAppendingString:[hashtags objectAtIndex:indexPath.item]];
    cell.textLabel.font = [UIFont systemFontOfSize:28];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    NSArray *colorArray = [[((SELMainViewController *) self.parentViewController) color] getColorArray];
    int i = indexPath.item % 10;
    cell.backgroundColor = [colorArray objectAtIndex:i];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma - mark UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)activeScrollView{
    NSLog(@"scrollViewWillBeginDragging");
    [(SELMainViewController *) self.parentViewController dismissKeyboard];
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
    
    query = [query lowercaseString];
    query = [query stringByReplacingOccurrencesOfString:@"#" withString:@""];
    query = [query stringByReplacingOccurrencesOfString:@" " withString:@""];
    lastQuery = query;
    NSLog(@"this is a query test %@", query);
    if (query.length == 0) {
        [self popularHashtags];
        return;
    }
    
    PFQuery *queryHashtag = [PFQuery queryWithClassName:@"Hashtag"];
    [queryHashtag whereKey:@"name" containsString:query];
    [queryHashtag orderByDescending:@"count"];
    [queryHashtag findObjectsInBackgroundWithBlock:^(NSArray *hashtagsResults, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved %lu hashtags.", (unsigned long)hashtagsResults.count);
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
    
    PFQuery *queryHashtag = [PFQuery queryWithClassName:@"Hashtag"];
    //[queryHashtag whereKey:@"count" greaterThan:@0];
    [queryHashtag orderByDescending:@"count"];
    
    [queryHashtag findObjectsInBackgroundWithBlock:^(NSArray *hashtagsResults, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved %lu hashtags.", (unsigned long)hashtagsResults.count);
            [hashtags removeAllObjects];
            for (PFObject * tag in hashtagsResults) {
                [hashtags addObject:tag[@"name"]];
            }
            [self.tableView reloadData];
        }else{
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

// Refresh
- (void)refresh:(id)sender {
    [(UIRefreshControl *)sender endRefreshing];
    [self searchForHashtag:lastQuery];
    [(SELMainViewController *) self.parentViewController countLikes];
}

@end