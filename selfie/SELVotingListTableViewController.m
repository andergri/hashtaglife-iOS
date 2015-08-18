//
//  SELVotingListTableViewController.m
//  #life
//
//  Created by Griffin Anderson on 7/9/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import "SELVotingListTableViewController.h"

@interface SELVotingListTableViewController ()

@property NSInteger count;
@property NSMutableArray * usernames;
@property PFObject * aselfie;

@end

@implementation SELVotingListTableViewController

@synthesize color;
@synthesize usernames;
@synthesize count;
@synthesize aselfie;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.tableView setDelegate:self];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UsernamesTableViewCell"];
    self.tableView.dataSource = self;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    count = 0;
    aselfie = nil;
    usernames = [[NSMutableArray alloc] initWithArray:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.tableView.frame = self.view.frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setSelfie:(PFObject *)selfie{
    
    aselfie = selfie;
    count = [selfie[@"likes"] intValue];
    /** TODO **/
    PFQuery *voteItem = [PFQuery queryWithClassName:@"Vote"];
    [voteItem whereKey:@"selfie" equalTo:selfie];
    [voteItem findObjectsInBackgroundWithBlock:^(NSArray *votesResults, NSError *error) {
        if (!error) {
            [usernames removeAllObjects];
            for (int i = 0; i < votesResults.count; i++) {
                [usernames addObject:[self createVote:[votesResults objectAtIndex:i]]];
            }
            [self finalCreateFakeUsernameList];
        }else{
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (NSArray*) createVote:(PFObject*)createVote{
    NSString *ausername = [createVote objectForKey:@"voterName"];
    BOOL aupvote = [[createVote objectForKey:@"voterReaction"] boolValue];
    return [[NSArray alloc] initWithObjects:ausername, [NSNumber numberWithBool:aupvote], nil];
}

- (NSArray*) createFakeVote:(NSString*)ausername reaction:(BOOL)reaction {
    return [[NSArray alloc] initWithObjects:ausername, [NSNumber numberWithBool:reaction], nil];
}

- (void) finalCreateFakeUsernameList{
    long countSum = 0;
    for (int i = 0; i < usernames.count; i++) {
        BOOL reaction = [[[usernames objectAtIndex:i] objectAtIndex:1] boolValue];
        if (reaction)
            countSum += 1;
        else
            countSum -= 1;
    }
    long distance = count - countSum;
    for (int i = 0; i < labs(distance); i++) {
        NSString *fakeUsername = [self generateFakeUsername];
        BOOL reaction = distance < 0.0 ? false : true;
        NSArray *fakeVote = [self createFakeVote:fakeUsername reaction:reaction];
        [usernames addObject:fakeVote];
        [self updateData:fakeUsername reaction:reaction selfie:aselfie];
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return usernames.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UsernamesTableViewCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:@"UsernamesTableViewCell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:19.0f];
    NSArray *colorArray = [color getColorArray];
    int i = indexPath.item % 10;
    cell.textLabel.textColor = [colorArray objectAtIndex:i];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    NSArray *vote = [usernames objectAtIndex:indexPath.item];
    BOOL voteResult = [[vote objectAtIndex:1] boolValue];
    NSString *ausername = [vote objectAtIndex:0];
    
    cell.textLabel.text = ausername;
    cell.backgroundColor = [UIColor clearColor];
    
    UIImage *downvoteImage;
    if (voteResult)
        downvoteImage = [[UIImage imageNamed:@"upvote"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    else
        downvoteImage = [[UIImage imageNamed:@"downvote"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    cell.imageView.image = downvoteImage;
    cell.imageView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cell.imageView setTintColor:[colorArray objectAtIndex:i]];
    cell.imageView.clipsToBounds = YES;
    
    //NSArray *colorArray = [color getColorArray];
    //int i = indexPath.item % 10;
    //cell.backgroundColor = [colorArray objectAtIndex:i];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSString *) generateFakeUsername{
    NSInteger randomList1 = arc4random() % 7;
    NSString *name1 = [self getRandomName:[NSString stringWithFormat:@"%ld", (long)randomList1]];
    NSInteger randomList2 = arc4random() % 7;
    NSString *name2 = [self getRandomName:[NSString stringWithFormat:@"%ld", (long)randomList2]];
    return [name1 stringByAppendingString:name2];
}

- (NSString*) getRandomName:(NSString*)randomList{
    NSString *voteListPath = [[NSBundle mainBundle] pathForResource:@"SELVoteList" ofType:@"plist"];
    NSDictionary *creatureDictionary = [[NSDictionary alloc] initWithContentsOfFile:voteListPath];
    NSArray *animals = creatureDictionary[randomList];
    NSInteger randomNumber = arc4random() % animals.count;
    return [animals objectAtIndex:randomNumber];
}

- (void) updateData:(NSString *)fakeName reaction:(BOOL)reaction selfie:(PFObject*)selfie{
    @try {
        PFObject* vote = [PFObject objectWithClassName:@"Vote"];
        vote[@"voterName"] = fakeName;
        vote[@"voterReaction"] = @(reaction);
        vote[@"selfie"] = selfie;
        vote[@"poster"] = [selfie objectForKey:@"from"];
        vote[@"notifyAttempted"] = @YES;
        [vote saveInBackground];
    }
    @catch (NSException *exception) {
        NSLog(@"Error: %@ %@", exception, [exception userInfo]);
    }
    @finally {
    }
}

@end
