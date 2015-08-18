//
//  SELLocationTableViewController.m
//  #life
//
//  Created by Griffin Anderson on 11/22/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import "SELLocationTableViewController.h"
#import "SELAddLocationViewController.h"
#import "SELLocationViewController.h"

@interface SELLocationTableViewController ()

@property NSMutableArray *locations;
@property NSMutableArray *categories;
@property NSString *category;

@property SELAddLocationViewController *addLocation;

@end

@implementation SELLocationTableViewController

@synthesize locations;
@synthesize categories;
@synthesize color;
@synthesize addLocation;
@synthesize category;
@synthesize selecting;
@synthesize search;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setDelegate:self];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"LocationTableViewCell"];
    self.tableView.dataSource = self;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    self.view.backgroundColor = [UIColor blackColor];
    locations = [[NSMutableArray alloc] init];
    categories = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:@"College / University", @"High School", @"Other", nil]];
    category = nil;
    
    self.view.backgroundColor = [color getPrimaryColor];
    
    addLocation = [[SELAddLocationViewController alloc] init];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    PFObject *object = [[PFUser currentUser] objectForKey:@"location"];
    if (object) {
        [self dismissViewControllerAnimated:NO completion:^{
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (category == nil) {
         return categories.count;
    }else{
        if (selecting) {
            return locations.count + 2;
        }else{
            return locations.count;
        }
    }
}
/**
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Choose your school:";
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
   
    UILabel *sectionHeaderView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
    sectionHeaderView.text = @"Choose your school:";
    sectionHeaderView.textColor = [UIColor whiteColor];
    sectionHeaderView.font = [UIFont systemFontOfSize:24.0f];
    sectionHeaderView.textAlignment = NSTextAlignmentCenter;
    sectionHeaderView.backgroundColor = [color getPrimaryColor];
    
    // Top header border
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 1.0f);
    topBorder.backgroundColor = [UIColor colorWithWhite:1.0f alpha:.15f].CGColor;
    [sectionHeaderView.layer addSublayer:topBorder];
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:sectionHeaderView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(4.0, 4.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = sectionHeaderView.bounds;
    maskLayer.path = maskPath.CGPath;
    sectionHeaderView.layer.mask = maskLayer;
    
    return sectionHeaderView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 64.0f;
}
 **/

- (void) getLocations: (NSString *) type query:(NSString *)query{
    
    @try {
    
    PFQuery *queryLocations = [PFQuery queryWithClassName:@"Location"];
    [queryLocations whereKey:@"active" equalTo:@YES];
    if (query != nil && query.length > 0) {
        [queryLocations whereKey:@"name" containsString:query];
        [queryLocations whereKey:@"type" equalTo:type];
    }else{
        [queryLocations whereKey:@"type" equalTo:type];
    }
    [queryLocations orderByAscending:@"type"];
    [queryLocations addAscendingOrder:@"name"];
    [queryLocations findObjectsInBackgroundWithBlock:^(NSArray *locationResults, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved %lu locations.", (unsigned long)locationResults.count);
            [locations removeAllObjects];
            for (PFObject * location in locationResults) {
                [locations addObject:location];
            }
            [self.tableView reloadData];
        }else{
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocationTableViewCell" forIndexPath:indexPath];
    

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:@"LocationTableViewCell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:22];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.numberOfLines = 2;
    
    if (category != nil) {
    
    NSString *loc;
    NSString *address;
    if (selecting && (indexPath.item == locations.count)) {
        loc = @"I don't see my school";
        address = @"";
        cell.textLabel.font = [UIFont systemFontOfSize:24.0f];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }else if (selecting && (indexPath.item == locations.count + 1)) {
            loc = @"Back";
            address = @"";
            cell.textLabel.font = [UIFont systemFontOfSize:24.0f];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }else{
        loc = [(PFObject *)[locations objectAtIndex:indexPath.item] objectForKey:@"name"];
        NSString * city = [(PFObject *)[locations objectAtIndex:indexPath.item] objectForKey:@"city"];
        NSString * state = [(PFObject *)[locations objectAtIndex:indexPath.item] objectForKey:@"state"];
        address = [NSString stringWithFormat:@"%@, %@", city, state];
    }
    cell.textLabel.text = [@"" stringByAppendingString:loc];
    cell.detailTextLabel.text = address;
    
    }else{
        cell.textLabel.text = [categories objectAtIndex:indexPath.item];
    }
    
    //[cell.textLabel.subviews.firstObject removeFromSuperview];
    
    NSArray *colorArray = [color getColorArray];
    int i = indexPath.item % 10;
    cell.backgroundColor = [colorArray objectAtIndex:i];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (category != nil) {
    
    if (locations.count > 0 && indexPath.item < locations.count) {
        
    PFObject *selectedLocation = [locations objectAtIndex:indexPath.item];
    [selectedLocation incrementKey:@"students"];
    [selectedLocation saveInBackground];
        
    [[PFUser currentUser] setObject:selectedLocation forKey:@"location"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self dismissViewControllerAnimated:YES completion:^{
                [((SELLocationViewController*)self.parentViewController) changedLocation];
            }];
        }
    }];
        
    }else{
        if (indexPath.item == locations.count + 1) {
            categories = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:@"College / University", @"High School", @"Other", nil]];
            locations = [[NSMutableArray alloc] init];
            category = nil;
            [self.tableView reloadData];
            [((SELLocationViewController*) self.parentViewController) lockSearch];
        }else{
            addLocation.color = color;
            [self presentViewController:addLocation animated:YES completion:^{
            }];
        }
    }
        
    }else{
        [((SELLocationViewController*) self.parentViewController) unlockSearch];
        NSString *categoriesLocation = [categories objectAtIndex:indexPath.item];
        [self getLocations:categoriesLocation query:@""];
        category = categoriesLocation;
    }
}

- (void) searchForLocation:(NSString *)query{
    // for the and the -in
    query = [query capitalizedString];
    NSRange range = [query rangeOfString:@" Of "];
    if (range.location != NSNotFound) {
        NSLog(@"query found");
        NSString * lower = [query substringWithRange:range];
        lower = [lower lowercaseString];
        query = [[query substringToIndex:range.location] stringByAppendingString:[lower stringByAppendingString:[query substringFromIndex:range.location + range.length]]];
    }
    NSLog(@"query %@", query);
    [self getLocations:category query:query];
}

#pragma - mark UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)activeScrollView{
    NSLog(@"scrollViewWillBeginDragging");
    [self.search resignFirstResponder];
}


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

@end
