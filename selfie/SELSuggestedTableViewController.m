//
//  SELSuggestedTableViewController.m
//  #life
//
//  Created by Griffin Anderson on 4/3/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import "SELSuggestedTableViewController.h"
#import "SELPostViewController.h"

@interface SELSuggestedTableViewController ()

@property NSMutableArray *hashtaglist;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
- (IBAction)exit:(id)sender;

@end

@implementation SELSuggestedTableViewController

@synthesize hashtaglist;
@synthesize delegate;
@synthesize color;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    hashtaglist = [[NSMutableArray alloc] init];
    [self getSuggestedHashtags];
    
    // Collection View
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"SELSuggestedCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"SELSuggestedCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader  withReuseIdentifier:@"header"];

    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];

    //[self.tableView.layer setCornerRadius:5.0f];
    //[self.tableView.layer setBorderColor:[UIColor colorWithWhite:.92 alpha:1].CGColor];
    //[self.tableView.layer setBorderWidth:1.0f];
    
    // Top header border
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 1.0f);
    topBorder.backgroundColor = [UIColor colorWithWhite:1.0f alpha:.15f].CGColor;
    [self.view.layer addSublayer:topBorder];
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.view.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(4.0, 4.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.bounds;
    maskLayer.path = maskPath.CGPath;
    self.view.layer.mask = maskLayer;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return hashtaglist.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section < [hashtaglist count]) {
        NSArray *sublist = [hashtaglist objectAtIndex:section];
       // NSLog(@"sublist %ld", sublist.count);
        if (sublist.count > 8) {
            return 8;
        }
        return sublist.count;
    }
    
    return 0;
}

- (void) getSuggestedHashtags{
    
    NSArray *empty = [[NSArray alloc] init];
    [hashtaglist insertObject:empty atIndex:0];
    [hashtaglist insertObject:empty atIndex:1];
    
    PFQuery *hashtagItem;
    [[[PFUser currentUser] objectForKey:@"location" ] fetchIfNeededInBackground];
    
    if (([[PFUser currentUser] objectForKey:@"location"])) {
        hashtagItem = [PFQuery queryWithClassName:@"Tag"];
        [hashtagItem whereKey:@"location" equalTo:[[PFUser currentUser] objectForKey:@"location"]];
    }else{
        hashtagItem = [PFQuery queryWithClassName:@"Hashtag"];
    }
    [hashtagItem whereKey:@"count" greaterThan:@0];
    [hashtagItem whereKey:@"trending" greaterThan:@(-1)];
    [hashtagItem orderByDescending:@"trending"];
    [hashtagItem addAscendingOrder:@"name"];
    hashtagItem.limit = 8;
    [hashtagItem findObjectsInBackgroundWithBlock:^(NSArray *hashtagsResults, NSError *error) {
        if (!error) {
            [hashtaglist replaceObjectAtIndex:1 withObject:hashtagsResults];
            [self.collectionView reloadData];
        }else{
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    PFQuery *ahashtagItem = [PFQuery queryWithClassName:@"Trending"];
    [ahashtagItem whereKey:@"active" equalTo:@YES];
    [ahashtagItem orderByAscending:@"category"];
    [ahashtagItem addDescendingOrder:@"trending"];
    ahashtagItem.limit = 40;
    [ahashtagItem findObjectsInBackgroundWithBlock:^(NSArray *hashtagsResults, NSError *error) {
        if (!error) {
            
            NSMutableArray *yepArray = [[NSMutableArray alloc] init];
            for (PFObject *pf in hashtagsResults) {
                NSString *temp = nil;
                if (([hashtagsResults indexOfObject:pf] + 1) < hashtagsResults.count) {
                    temp = [[hashtagsResults objectAtIndex:([hashtagsResults indexOfObject:pf] + 1)] objectForKey:@"category"];
                }
                if ((temp && !([[pf objectForKey:@"category"] isEqualToString:temp])) || !temp) {
                    
                    // what is going on
                    [yepArray addObject:pf];
                    if (((NSArray*)[hashtaglist objectAtIndex:0]).count == 0) {
                        [hashtaglist replaceObjectAtIndex:0 withObject:yepArray];
                    }else{
                        [hashtaglist addObject:yepArray];
                    }
                    yepArray = [[NSMutableArray alloc] init];
                    
                }else{
                    [yepArray addObject:pf];
                }
            }
            
            [self.collectionView reloadData];
        }else{
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
    
    titleLabel.textColor = [UIColor colorWithWhite:.4 alpha:1];
    titleLabel.font = [UIFont systemFontOfSize:19];
    
    NSArray *subArray = [hashtaglist objectAtIndex:indexPath.section];
    PFObject *pf = [subArray objectAtIndex:indexPath.item];
    
    NSMutableAttributedString *attributedString;
    attributedString = [[NSMutableAttributedString alloc] initWithString:[@"#" stringByAppendingString:[pf objectForKey:@"name"]]];
    [attributedString addAttribute:NSKernAttributeName
                             value:@(1.7)
                             range:NSMakeRange(0, 1)];
    titleLabel.attributedText = attributedString;
    
    return cell;
}

   
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        
        NSMutableArray *colorArray = (NSMutableArray *)[color getColorArray];
        [colorArray removeObjectAtIndex:0];
        headerView.backgroundColor = [colorArray objectAtIndex:indexPath.section];
        
        UILabel *titleLabel = (UILabel *)[headerView viewWithTag:100];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:25];
        
        NSArray *newArray = [hashtaglist objectAtIndex:indexPath.section];
        
        if (indexPath.section != 1) {
            if (newArray.count > 0) {
                titleLabel.text = [((PFObject*)[newArray objectAtIndex:0]) objectForKey:@"category"];
            }else{
                titleLabel.text = @"Hashtags";
            }
        }else if(indexPath.section == 1){
            titleLabel.text = @"Trending at your school";
        }
        
        reusableview = headerView;
    }
    
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer" forIndexPath:indexPath];
        footerview.backgroundColor = [UIColor blackColor];
        reusableview = footerview;
    }
    
    return reusableview;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.item == 0) {
        NSArray *newArray = [hashtaglist objectAtIndex:indexPath.section];
        newArray = [newArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            
            NSString *aa = [((PFObject*)a) objectForKey:@"name"];
            NSString *bb = [((PFObject*)b) objectForKey:@"name"];
            
            NSNumber *alength = [NSNumber numberWithInt:(int)aa.length];
            NSNumber *blength = [NSNumber numberWithInt:(int)bb.length];
            return [alength compare:blength];
        }];
        [hashtaglist replaceObjectAtIndex:indexPath.section withObject:newArray];
    }
    
    NSArray *earray = [hashtaglist objectAtIndex:indexPath.section];
    
    PFObject *pf = [earray objectAtIndex:indexPath.item];
    NSMutableAttributedString *attributedString;
    attributedString = [[NSMutableAttributedString alloc] initWithString:[@"#" stringByAppendingString:[pf objectForKey:@"name"]]];
    
    NSMutableAttributedString *eattributedString;
    if (indexPath.item + 1 < earray.count) {
        PFObject *pf = [earray objectAtIndex:indexPath.item + 1];
        eattributedString = [[NSMutableAttributedString alloc] initWithString:[@"#" stringByAppendingString:[pf objectForKey:@"name"]]];
    }
    
    if (attributedString.length > 12 || (eattributedString && eattributedString.length > 12 && !(indexPath.item % 2))) {
        return CGSizeMake(290.f, 40.f);
    }
    return CGSizeMake(135.f, 40.f);
}

/**
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
        
        UIImage *okImage = [[UIImage imageNamed:@"exit"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImageView *okImageView = [[UIImageView alloc] initWithImage:okImage];
        okImageView.frame = CGRectMake(88, 18, okImage.size.width, okImage.size.height);
        //okImageView.contentMode = UIViewContentModeCenter;
        [okImageView setTintColor:[UIColor whiteColor]];
        okImageView.transform = CGAffineTransformMakeScale(.5, .5);
    
        UILabel *doneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 70)];
        doneLabel.text = @"Back";
        doneLabel.textColor = [UIColor whiteColor];
        doneLabel.font = [UIFont systemFontOfSize:32];
        doneLabel.textAlignment = NSTextAlignmentCenter;
        
        UIView *headerView= [[UIView alloc]init];
        headerView.tag = section;
        headerView.userInteractionEnabled = YES;
        headerView.backgroundColor = [color getPrimaryColor];
        headerView.frame = CGRectMake(0, 0, tableView.tableFooterView.frame.size.width, tableView.tableFooterView.frame.size.height);
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(catchFooterSubmission:)];
        tapGesture.cancelsTouchesInView = YES;
                
        [headerView addSubview:doneLabel];
        //[headerView addSubview:okImageView];
        [headerView addGestureRecognizer:tapGesture];
        
        return headerView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 70.0f;
}
 **/

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

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    NSArray *subArray = [hashtaglist objectAtIndex:indexPath.section];
    PFObject *pf = [subArray objectAtIndex:indexPath.item];
    [self.delegate addHashtag:[pf objectForKey:@"name"]];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}


- (NSMutableArray *) getAvaiableHashtags:(NSMutableArray *)listedHashatags{
    
    /**availablehashtags = [NSMutableArray arrayWithArray:suggestedhashtags];
    [availablehashtags removeObjectsInArray:listedHashatags];
    if (listedHashatags.count > 0) {
        for (NSUInteger i = 0; i < availablehashtags.count; ++i) {
            NSInteger remainingCount = availablehashtags.count - i;
            NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
            [availablehashtags exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
        }
    }**/
    /**else if(listedHashatags.count > 1){
        [availablehashtags removeAllObjects];
    }**/
    return hashtaglist;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 
 
 
 NSUInteger newIndex = [suggestedhashtags indexOfObject:tag[@"name"]
 inSortedRange:(NSRange){0, [suggestedhashtags count]}
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
*/

- (IBAction)exit:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end
