//
//  SELReplyViewController.m
//  #life
//
//  Created by Griffin Anderson on 10/12/15.
//  Copyright © 2015 Griffin Anderson. All rights reserved.
//

#import "SELReplyViewController.h"
#import "SELReplyCollectionViewCell.h"
#import "SELEditImage.h"

@interface SELReplyViewController ()

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property NSMutableArray *usersPhotos;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property PFObject *pendingObject;
@property PFFile *pendingImage;
@property UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
@property (weak, nonatomic) IBOutlet UIButton *exitButton;
- (IBAction)exit:(id)sender;

@end

@implementation SELReplyViewController

@synthesize pendingObject;
@synthesize pendingImage;
@synthesize color;
@synthesize hashtag;
@synthesize usersPhotos;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    pendingObject = nil;
    pendingImage = nil;
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Top header border
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.headerView.frame.size.width, 1.0f);
    topBorder.backgroundColor = [UIColor colorWithWhite:1.0f alpha:.15f].CGColor;
    [self.headerView.layer addSublayer:topBorder];
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.headerView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(4.0, 4.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.headerView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.headerView.layer.mask = maskLayer;
    self.headerView.backgroundColor = [[color getColorArray] objectAtIndex:0];
    
    //Textfield Styling
    UILabel *headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 44)];
    headingLabel.text = @"#";
    headingLabel.font = [UIFont systemFontOfSize:29];
    headingLabel.textColor = [UIColor whiteColor];
    headingLabel.backgroundColor = [UIColor clearColor];
    headingLabel.textAlignment = NSTextAlignmentCenter;
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 22, 44)];
    [paddingView addSubview:headingLabel];
    self.textField.leftView = paddingView;
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    self.textField.layer.masksToBounds=YES;
    self.textField.tintColor = [UIColor whiteColor];
    self.textField.bounds = CGRectInset(self.textField.frame, -11.0f, 0.0f);
    self.textField.text = hashtag;
    
    usersPhotos = [[NSMutableArray alloc] init];
    
    [self getUsersPhotos];
    
    // Collection View
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"SELReplyCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"CollectionViewCellIdentifier"];
    self.collectionView.allowsMultipleSelection = NO;
    
    [self shareView];
    self.shareButton.hidden = YES;
    
    // exit
    UIImage *exitImg = [[UIImage imageNamed:@"exit"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.exitButton.imageView setTintColor:[UIColor whiteColor]];
    [self.exitButton setImage:exitImg forState:UIControlStateNormal];
    self.exitButton.transform = CGAffineTransformMakeScale(1, 1);
    self.exitButton.imageEdgeInsets = UIEdgeInsetsMake(4., 8., 8., 4.);
    //self.exitButton.imageView.image = exitImg;
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


-(BOOL)prefersStatusBarHidden {
    return YES;
}


// Collection View

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section{
    return usersPhotos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    SELReplyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCellIdentifier" forIndexPath:indexPath];

    ALAsset *asset = [usersPhotos objectAtIndex:indexPath.row];
    [cell.imageView setImage:[UIImage imageWithCGImage:[asset thumbnail]]];

    //ALAssetRepresentation *representation = [alAsset defaultRepresentation];
    //UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
    
    [self setCellState:cell];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    SELReplyCollectionViewCell *cell = (SELReplyCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.selectButton.selected = NO;
    [self setCellState:cell];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SELReplyCollectionViewCell *cell = (SELReplyCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.selectButton.selected = !cell.selectButton.selected;
    [self setCellState:cell];
    [self cellPicked:cell indexPath:indexPath];
}

- (void) cellPicked:(SELReplyCollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath{
    if (cell.selectButton.selected) {
        self.shareButton.hidden = NO;
        
        ALAsset *asset = [usersPhotos objectAtIndex:indexPath.row];
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        UIImage *image = [UIImage imageWithCGImage:[representation fullScreenImage]];
        UIImage *editImage = [SELEditImage scaleAndRotateImage:image size:self.view.frame.size];
        
        self.coverImage.image = editImage;
        //self.coverImage.alpha = 1.0;
        //self.coverImage.hidden = NO;
        /**
        [UIView animateWithDuration:1.0 delay:1.0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.coverImage.alpha = 0.0;
        }completion:^(BOOL finished) {
            //self.coverImage.hidden = YES;
        }];**/
    }else{
        self.shareButton.hidden = YES;
    }
}

- (void) setCellState:(SELReplyCollectionViewCell *)cell{
    [cell.selectButton.layer setCornerRadius:cell.selectButton.frame.size.width/2.0];
    UIImage *checkmark = [cell.selectButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell.selectButton.imageView setTintColor:[UIColor whiteColor]];
    cell.selectButton.imageView.image = checkmark;
    if (cell.selectButton.selected) {
        cell.selectButton.backgroundColor = [color getPrimaryColor];
        cell.selectButton.layer.borderWidth = 0;
    }else{
        cell.selectButton.backgroundColor = [UIColor clearColor];
        cell.selectButton.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.selectButton.layer.borderWidth = 1;
    }
}

// Get Users Photos
- (void) getUsersPhotos{

    ALAssetsLibrary *library = [SELReplyViewController defaultAssetsLibrary];
    
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        // Within the group enumeration block, filter to enumerate just photos.
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        // Chooses the photo at the last index
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
            // The end of the enumeration is signaled by asset == nil.
            if (alAsset) {
                
                [usersPhotos addObject:alAsset];
                
                //ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                //UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
                
                
                //UIImage *latestPhotoThumbnail =  [UIImage imageWithCGImage:[alAsset thumbnail]];
                
                
                // Stop the enumerations
                *stop = NO; *innerStop = NO;
                
                //[usersPhotos addObject:[NSArray arrayWithObjects: latestPhotoThumbnail, latestPhoto, nil]];
            }
        }];
    } failureBlock: ^(NSError *error) {
        // Typically you should handle an error more gracefully than this.
        NSLog(@"No groups");
    }];
}

// Add Header View

- (void) shareView{

    UIImage *okImage = [[UIImage imageNamed:@"arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *okImageView = [[UIImageView alloc] initWithImage:okImage];
    okImageView.frame = CGRectMake(183, 17, okImage.size.width, okImage.size.height);
    okImageView.contentMode = UIViewContentModeCenter;
    [okImageView setTintColor:[UIColor whiteColor]];
    okImageView.transform = CGAffineTransformMakeScale(1, 1);
    
    UILabel *doneLabel = [[UILabel alloc] initWithFrame:CGRectMake(106, 0, 100, 60)];
    doneLabel.text = @"Share";
    doneLabel.textColor = [UIColor whiteColor];
    doneLabel.font = [UIFont boldSystemFontOfSize:28];
    doneLabel.textAlignment = NSTextAlignmentLeft;
    
    UIView *headerView= [[UIView alloc]init];
    headerView.userInteractionEnabled = YES;
    headerView.backgroundColor = [color getPrimaryColor];
    headerView.frame = CGRectMake(0, 0, 320, 60);
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startSaving)];
    tapGesture.cancelsTouchesInView = YES;
    
    [headerView addSubview:doneLabel];
    [headerView addSubview:okImageView];
    [headerView addGestureRecognizer:tapGesture];
    
    [self.shareButton addSubview:headerView];
}



#pragma - mark save for parse

- (void) startSaving{
    
    // Save Selfie
    NSData *imageData = UIImageJPEGRepresentation(self.coverImage.image, 0.8f);
    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
    pendingImage = imageFile;
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder
                            createEventWithCategory:@"Data"
                            action:@"saving"
                            label:@"image start"
                            value:nil] build]];
            
        }else{
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        
    } progressBlock:^(int percentDone) {
        // = (float)percentDone/100;
    }];
    [self saveSelfie];
}


-(void)saveSelfie {
    NSLog(@"saving Selfie ...");
    
    // Clean Data
    NSArray *cleanHashtags = [NSArray arrayWithObject:self.textField.text];
    
    // Save Selfie
    pendingObject = nil;
    pendingObject = [PFObject objectWithClassName:@"Selfie"];
    pendingObject[@"likes"] = @0;
    pendingObject[@"flags"] = @0;
    pendingObject[@"visits"] = @1;
    pendingObject[@"from"] = [PFUser currentUser];
    pendingObject[@"image"] = pendingImage;
    if([[PFUser currentUser] objectForKey:@"location"]){
        pendingObject[@"location"] = [[PFUser currentUser] objectForKey:@"location"];
    }
    
    [pendingObject addUniqueObjectsFromArray:cleanHashtags forKey:@"hashtags"];
    
    // Request a background execution task to allow us to finish uploading
    self.photoPostBackgroundTaskId = [[UIApplication sharedApplication]   beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    
    [pendingObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if(!error){
            // Add or incrment hashtag count
            
            
            for (NSString *cleanHashtag in cleanHashtags) {
                
                PFQuery *queryHashtag = [PFQuery queryWithClassName:@"Hashtag"];
                [queryHashtag whereKey:@"name" equalTo:cleanHashtag];
                [queryHashtag findObjectsInBackgroundWithBlock:^(NSArray *hashtagsResults, NSError *error) {
                    if (!error) {
                        
                        // Save new hashtags
                        if(hashtagsResults.count > 0){
                            
                            PFObject *hash = hashtagsResults[0];
                            [hash incrementKey:@"count"];
                            [hash incrementKey:@"trending"];
                            [hash saveInBackground];
                            
                        }else{
                            
                            PFObject *hash = [PFObject objectWithClassName:@"Hashtag"];
                            hash[@"count"] = @1;
                            hash[@"trending"] = @1;
                            hash[@"name"] = cleanHashtag;
                            [hash saveInBackground];
                        }
                        
                    }else{
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                    }
                }];
            }
            
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder
                            createEventWithCategory:@"Data"
                            action:@"saving"
                            label:@"image finished"
                            value:nil] build]];
            
            // If we are currently in the background, suspend the app, otherwise
            // cancel request for background processing.
            NSLog(@"end background task");
            [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
        }else{
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)exit:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

+ (ALAssetsLibrary *)defaultAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}
@end
