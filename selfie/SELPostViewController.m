//
//  SELPostViewController.m
//  selfie
//
//  Created by Griffin Anderson on 7/19/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import "SELPostViewController.h"
#import "SELMainViewController.h"

@interface SELPostViewController ()

@property PBJVideoPlayerController *videoPlayerController;
@property (weak, nonatomic) IBOutlet UIView *chooseShareView;

@property (weak, nonatomic) IBOutlet UIView *buttonContainerView;
@property (weak, nonatomic) IBOutlet UIView *chooseImageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIView *chooseHashtagView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UITextField *textField;
- (IBAction)okAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *exitButton;
- (IBAction)exitAction:(id)sender;
- (IBAction)backAction:(id)sender;
- (IBAction)shareAction:(id)sender;
- (IBAction)closeAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *suggestedHashtags;
- (IBAction)suggestedHashtags:(id)sender;

@property NSArray *badWordsArrayValues;
@property PFObject *pendingObject;
@property PFFile *pendingImage;
@property PFFile *pendingVideo;
@property UIToolbar* numberToolbar;
@property SELSuggestedTableViewController * suggestedTableViewController;
@property UIBackgroundTaskIdentifier photoPostBackgroundTaskId;

@end

@implementation SELPostViewController

#define BAD_WORDS @[ @"anal", @"anorexia" , @"bitch" , @"bomb", @"boner" , @"boob" , @"breast" , @"butt" , @"chode", @"cock" , @"clit" , @"dyke" , @"deepthroat", @"dick" , @"faggot" , @"fuck" , @"gay" , @"hardcore" , @"hoe" , @"jizz" , @"kill", @"orgasm" , @"pussy" , @"rape" , @"sloot" , @"slut" , @"suck" , @"threat", @"thot" , @"ugly" , @"whore" , @"xx" , @"virgin" ]

#define EXACT_BAD_WORDS @[ @"ass", @"gangbang", @"cleavage", @"crack", @"cumshot", @"cunt", @"dead", @"dildo", @"dumbass", @"fag", @"fake", @"fat", @"fetish", @"freak", @"hoe", @"jizz", @"joog", @"jugs", @"milf", @"nigger", @"nsfw", @"nude", @"orgasm", @"penis", @"porn", @"prostitute", @"pussy", @"rack", @"slayer", @"slyaer", @"sloot", @"slut", @"testicle", @"thot", @"threat", @"ugly", @"vagina", @"virgin", @"weed", @"whore", @"xx"]

@synthesize hashtags;
@synthesize image = _image;
@synthesize videoURL;
@synthesize videoPlayerController;
@synthesize delegate;
@synthesize color;
@synthesize pendingObject;
@synthesize pendingImage;
@synthesize pendingVideo;
@synthesize clickable;
@synthesize numberToolbar;
@synthesize suggestedTableViewController;
@synthesize badWordsArrayValues;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // init
    clickable = YES;
    pendingObject = nil;
    pendingImage = nil;
    pendingVideo = nil;
    hashtags = [[NSMutableArray alloc] init];
    [self.tableView setDelegate:self];
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"HashtagTableViewCell"];
    
    
    // Top header border
    
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

    NSLog(@"color %@", [color getPrimaryColor]);
    
    // Suggested Hashtags
    CALayer *atopBorder = [CALayer layer];
    atopBorder.frame = CGRectMake(0.0f, 0.0f, self.suggestedHashtags.frame.size.width, 1.0f);
    atopBorder.backgroundColor = [UIColor colorWithWhite:1.0f alpha:.3f].CGColor;
    [self.suggestedHashtags.layer addSublayer:atopBorder];
    //self.suggestedHashtags.layer.cornerRadius = 4.0f;
    
    
    //Textfield Styling
    [self.textField setDelegate:self];
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
    
    
    // exit button
    self.exitButton.frame = CGRectMake(0, self.view.frame.size.height - 70, self.exitButton.frame.size.width, self.exitButton.frame.size.height);
    
    // ok button back button
    self.okButton.layer.cornerRadius = roundf(self.okButton.frame.size.width/2.0);
    self.backButton.layer.cornerRadius = roundf(self.backButton.frame.size.width/2.0);
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    //suggestedTableViewController = [[SELSuggestedTableViewController alloc] init];
    //suggestedTableViewController.delegate = self;
    //suggestedTableViewController.view.frame = [[UIScreen mainScreen] bounds];
    
    // CUSTOM KEYBOARD
    /**
    numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.translucent = NO;
    numberToolbar.clipsToBounds = YES;
    numberToolbar.backgroundColor = [UIColor whiteColor];
    self.textField.inputAccessoryView = numberToolbar;
    **/
    
    // Video Stuff
    videoPlayerController = [[PBJVideoPlayerController alloc] init];
    videoPlayerController.delegate = self;
    videoPlayerController.view.frame = self.view.bounds;
    videoPlayerController.playbackLoops = YES;
    
    [self addChildViewController:videoPlayerController];
    [self.chooseImageView insertSubview:videoPlayerController.view atIndex:0];
    [videoPlayerController didMoveToParentViewController:self];
    videoPlayerController.view.hidden = YES;
    
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"SELBadwords_en" ofType:@"plist"];
    badWordsArrayValues=[[NSArray alloc] initWithContentsOfFile:plistPath];
    
}

- (void) addColor:(SELColorPicker *)acolor{
    
    self.headerView.backgroundColor = [[acolor getColorArray] objectAtIndex:0];
    
    [[self.okButton subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [[self.backButton subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //Ok Button UI
    UIImage *okImage = [[UIImage imageNamed:@"checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *okImageView = [[UIImageView alloc] initWithImage:okImage];
    okImageView.frame = CGRectMake(9, 9, okImage.size.width, okImage.size.height);
    okImageView.contentMode = UIViewContentModeCenter;
    [okImageView setTintColor:[acolor getPrimaryColor]];
    [self.okButton addSubview:okImageView];
    
    //Back Button UI
    UIImage *backImage = [[UIImage imageNamed:@"exit"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *backImageView = [[UIImageView alloc] initWithImage:backImage];
    backImageView.frame = CGRectMake(9.5, 9, backImage.size.width, backImage.size.height);
    backImageView.contentMode = UIViewContentModeCenter;
    [backImageView setTintColor:[acolor getPrimaryColor]];
    [self.backButton addSubview:backImageView];
    
    // posting screen
    self.headerView.backgroundColor = [acolor getPrimaryColor];
    //self.suggestedHashtags.titleLabel.textColor = [UIColor colorWithWhite:.9 alpha:1];
    //self.suggestedHashtags.layer.borderColor=[UIColor colorWithWhite:.9 alpha:1].CGColor;
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void) showVideo{
    if (videoURL != nil) {
        videoPlayerController.videoPath = videoURL;
        videoPlayerController.view.hidden = NO;
        self.imageView.hidden = YES;
    }
}

- (void) showPost {
    self.navigationController.navigationBarHidden = YES;
    
    [self setPlaceholder];
    
    clickable = YES;
    pendingImage = nil;
    pendingVideo = nil;
    [hashtags removeAllObjects];
    
    self.imageView.frame = self.view.frame;
    self.chooseHashtagView.frame = self.view.frame;
    self.chooseImageView.frame = self.view.frame;
    self.exitButton.frame = CGRectMake(0, self.view.frame.size.height - 70, self.exitButton.frame.size.width, self.exitButton.frame.size.height);
    self.buttonContainerView.frame = CGRectMake(0, self.view.frame.size.height - 99, self.buttonContainerView.frame.size.width, self.buttonContainerView.frame.size.height);
    
    // Do any additional setup after loading the view from its nib.
    self.chooseHashtagView.hidden = YES;
    self.chooseImageView.hidden = NO;
    self.imageView.image = _image;
    [self.imageView setNeedsDisplay];
    [self.hashtags removeAllObjects];
    [self.tableView reloadData];
    self.imageView.hidden = NO;

    
    videoPlayerController.videoPath = nil;
    //self.imageView.contentMode = UIViewContentModeCenter;
    //self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Post Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

#pragma mark - TextField

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    
    if([string isEqualToString:@" "] || [string isEqualToString:@"#"]){
        
        if(textField.text.length > 0){
            [self textFieldDidEndEditing:self.textField];
        }
        return NO;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    if (textField.text.length > 0) {
        
        NSArray* hashes = [textField.text componentsSeparatedByString:@" "];
        for(NSString * hash in hashes) {
            NSArray* hashesa = [hash componentsSeparatedByString:@"#"];
            for(NSString * hasha in hashesa) {
                if ([self checkHashtag:hasha]){
                
                    if((hasha.length > 0.0) && (hashtags.count < 5.0)) {
                        
                        [hashtags insertObject:hasha atIndex:0];
                        [self setPlaceholder];
                    }
                }
            }
        }
        textField.text = @"";
    }
    [self.tableView reloadData];
    //[self.textField resignFirstResponder];
}

- (BOOL) checkHashtag: (NSString *)hash{

    hash = [hash stringByReplacingOccurrencesOfString:@"#" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];

    if(hashtags.count > 4.0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops!" message:@"Only 5 Hashtags allowed." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return FALSE;
    }
    
    if([hash rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]].location != NSNotFound){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops!" message:@"Hashtags do not contain spaces." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return FALSE;
    }
    /**
    if([self.textField.text isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops!" message:@"You need to add a Full Name" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return FALSE;
    }
     **/
    
    return TRUE;
}

- (BOOL) shouldShowCaution:(NSString *)hashtag{

    hashtag = [hashtag lowercaseString];
    for (NSString *bad_word in BAD_WORDS) {
        if ([hashtag rangeOfString:bad_word].location != NSNotFound){
            return YES;
        }
    }
    if ([EXACT_BAD_WORDS indexOfObject:hashtag] != NSNotFound)
        return YES;
    if ([badWordsArrayValues indexOfObject:hashtag] != NSNotFound)
        return YES;
    return NO;
}

- (BOOL) showWarning{

    for (NSString* hashtag in hashtags) {
        if ([self shouldShowCaution:hashtag]) {
            return YES;
        }
    }
    return NO;
}

- (void) removeAllBadHashtags{
    
    // Find the things to remove
    NSMutableArray *toDelete = [NSMutableArray array];
    for (NSString* hashtag in hashtags){
        if ([self shouldShowCaution:hashtag]) {
            [toDelete addObject:hashtag];
    
        }
    }
    [hashtags removeObjectsInArray:toDelete];
    [self.tableView reloadData];
}

-(void)dismissKeyboard {
    [self.textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self textFieldDidEndEditing:textField];
    //[textField resignFirstResponder];
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return hashtags.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HashtagTableViewCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [@"#" stringByAppendingString:[hashtags objectAtIndex:indexPath.item]];
    cell.textLabel.font = [UIFont systemFontOfSize:28];
    cell.textLabel.textColor = [UIColor whiteColor];
    if ([self shouldShowCaution:[hashtags objectAtIndex:indexPath.item]]) {
        
        UIImageView *cautionImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"caution"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [cautionImageView setTintColor:[UIColor whiteColor]];
        cell.accessoryView = cautionImageView;
        
        
    }else{
        cell.accessoryView = nil;
    }//[UIColor colorWithRed:255.0/255.0 green:127.0/255.0 blue:0/255.0 alpha:1]
    
    NSMutableArray *colorArray = (NSMutableArray *)[color getColorArray];
    [colorArray removeObjectAtIndex:0];
    int i = indexPath.item % 9;
    cell.backgroundColor = [colorArray objectAtIndex:i];
    
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (hashtags.count > 0) {
        return @"Share";
    }else{
        return nil;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (hashtags.count == 0) {
        /**
        UIImage *okImage = [[UIImage imageNamed:@"arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImageView *okImageView = [[UIImageView alloc] initWithImage:okImage];
        okImageView.frame = CGRectMake(282, 6, okImage.size.width, okImage.size.height);
        okImageView.contentMode = UIViewContentModeCenter;
        [okImageView setTintColor:[UIColor colorWithWhite:1 alpha:.8]];
        okImageView.transform = CGAffineTransformMakeScale(.8, .8);
        
        UILabel *doneLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 290, 40)];
        doneLabel.text = @"Hashtag Suggestions";
        doneLabel.textColor = [UIColor colorWithWhite:1 alpha:.8];
        doneLabel.font = [UIFont boldSystemFontOfSize:15];
        doneLabel.textAlignment = NSTextAlignmentLeft;
        
        UIView *headerView= [[UIView alloc]init];
        headerView.tag = section;
        headerView.userInteractionEnabled = YES;
        NSArray *colorArray = [color getColorArray];
        headerView.backgroundColor = [colorArray objectAtIndex:0];
        headerView.frame = CGRectMake(0, 0, tableView.tableHeaderView.frame.size.width, tableView.tableHeaderView.frame.size.height);
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(suggestedHashtags:)];
        tapGesture.cancelsTouchesInView = YES;
        
        [headerView addSubview:doneLabel];
        [headerView addSubview:okImageView];
        [headerView addGestureRecognizer:tapGesture];
        
        return headerView;
         **/
        return nil;
    }else {

        if ([self showWarning]){
        
        
            UIView *headerView= [[UIView alloc]init];
            headerView.tag = section;
            headerView.userInteractionEnabled = YES;
            headerView.backgroundColor = [color getPrimaryColor];
            headerView.frame = CGRectMake(0, 0, tableView.tableHeaderView.frame.size.width, tableView.tableHeaderView.frame.size.height);
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeAllBadHashtags)];
            tapGesture.cancelsTouchesInView = YES;
            
            UIView *warning= [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
            warning.userInteractionEnabled = NO;
            warning.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:127.0/255.0 blue:0/255.0 alpha:1];
            
            UIImageView *cautionImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"caution"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            cautionImageView.frame = CGRectMake(11, 17, 28, 28);
            [cautionImageView setTintColor:[UIColor whiteColor]];
            
            UILabel *warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(38, 0, 280, 60)];
            warningLabel.text = @"Posting inappropriate hashtags and photos will get you suspended from the app.";
            warningLabel.numberOfLines = 2;
            warningLabel.textColor = [UIColor whiteColor];
            warningLabel.font = [UIFont systemFontOfSize:14];
            warningLabel.textAlignment = NSTextAlignmentCenter;
            
            [headerView addSubview:warning];
            [headerView addSubview:cautionImageView];
            [headerView addSubview:warningLabel];
            
            //[headerView addSubview:doneLabel];
            //[headerView addSubview:okImageView];
            [headerView addGestureRecognizer:tapGesture];
            
            return headerView;
            
        }else{
            
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
            headerView.tag = section;
            headerView.userInteractionEnabled = YES;
            headerView.backgroundColor = [color getPrimaryColor];
            headerView.frame = CGRectMake(0, 0, tableView.tableHeaderView.frame.size.width, tableView.tableHeaderView.frame.size.height);
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(catchHeaderSubmission:)];
            tapGesture.cancelsTouchesInView = YES;
            
            [headerView addSubview:doneLabel];
            [headerView addSubview:okImageView];
            [headerView addGestureRecognizer:tapGesture];
            
            return headerView;
        }
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.hashtags removeObjectAtIndex:indexPath.item];
        [self setPlaceholder];
        [tableView reloadData];
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (hashtags.count == 0)
        return 0.0f; //return 40.0f;
    
    return 60.0f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

-(void)catchHeaderSubmission:(UIGestureRecognizer*)sender{
    
    clickable = NO;
    [self textFieldDidEndEditing:self.textField];
    [self.textField resignFirstResponder];
     NSLog(@"save selfie");
    [self saveSelfie];
}

#pragma - mark UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)activeScrollView{
    NSLog(@"scrollViewWillBeginDragging");
    [self.textField resignFirstResponder];
}

#pragma - mark save for parse

- (void) startSaving {

    // Save Selfie
    
    NSData *imageData = UIImageJPEGRepresentation(_image, 0.8f);
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
    
    if (videoURL) {
        
         NSData *videodata = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:videoURL]];
        PFFile *videoFile = [PFFile fileWithName:@"video.mov" data:videodata];
        if(videoFile){
            pendingVideo = videoFile;
            [videoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                if (!error) {
                    NSLog(@"video save succesus");
                }else{
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
             }progressBlock:^(int percentDone) {
                 NSLog(@"percent done video %d", percentDone);
            }];
        }else{
            NSLog(@"Error: no file");
        }
    }
}

- (void) deleteSaving{

    //[pendingObject deleteInBackground];
    pendingObject = nil;
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder
                    createEventWithCategory:@"Data"
                    action:@"saving"
                    label:@"image delete"
                    value:nil] build]];
}

-(void)saveSelfie {
    NSLog(@"saving Selfie ...");
    
    // Clean Data
    NSArray *cleanHashtags = (NSArray*) hashtags;
    
    // Save Selfie
    pendingObject = nil;
    pendingObject = [PFObject objectWithClassName:@"Queue"];
    pendingObject[@"likes"] = @0;
    pendingObject[@"flags"] = @0;
    pendingObject[@"visits"] = @1;
    pendingObject[@"from"] = [PFUser currentUser];
    pendingObject[@"image"] = pendingImage;
    if (pendingVideo)
        pendingObject[@"video"] = pendingVideo;
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
            
            /**
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
             **/
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
    [self closeAction:nil];
}

#pragma - mark naviation

- (void) showError{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                      message:@"Problem saving image, check internet connection"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
}

- (void)setPlaceholder{
    if (hashtags.count == 5.0) {
        self.textField.placeholder = [NSString stringWithFormat:@"Tap 'Share'"];
    }else if (hashtags.count == 4.0) {
        self.textField.placeholder = [NSString stringWithFormat:@"1 hashtag left"];
    }else if (hashtags.count == 0.0) {
        self.textField.placeholder = [NSString stringWithFormat:@"Add a few hashtags"];
    }else{
        self.textField.placeholder = [NSString stringWithFormat:@"%lu hashtags left", (5 - hashtags.count)];
    }
    //[self setNumberToolbar];
}


#pragma - mark other

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) completeAction{
    self.chooseShareView.hidden = NO;
    self.chooseHashtagView.hidden = YES;
    self.chooseImageView.hidden = YES;
}

- (IBAction)shareAction:(id)sender {
    
    NSString *hash = [hashtags objectAtIndex:1];
    NSLog(@"hash %@", hash);
    NSString *_postText = [NSString stringWithFormat:@"See my img @ http://life.uffda.me/%@", hash];
    NSArray *activityItems = nil;
    activityItems = @[_postText];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:^{
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder
                        createEventWithCategory:@"UX"
                        action:@"taped share"
                        label:@""
                        value:nil] build]];
    }];
    
}

- (IBAction)closeAction:(id)sender {
    //[self dismissViewControllerAnimated:NO completion:nil];
    
    self.chooseShareView.hidden = YES;
    self.chooseHashtagView.hidden = YES;
    self.chooseImageView.hidden = NO;
    self.view.hidden = YES;
    [(SELPageViewController*)self.parentViewController.parentViewController lockSideSwipe:NO];
    [(SELPageViewController*)self.parentViewController.parentViewController exitClicked];
    
    // problem 1 parent
    
    [UIView animateWithDuration:2.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                     } completion:^(BOOL finished){
                         if (finished) {
                             clickable = YES;
                         }
                     }];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder
                    createEventWithCategory:@"UX"
                    action:@"posting"
                    label:@"submitted"
                    value:nil] build]];
}

- (IBAction)okAction:(id)sender {
    [self setPlaceholder];
    self.chooseShareView.hidden = YES;
    self.chooseHashtagView.hidden = NO;
    self.chooseImageView.hidden = YES;
    [videoPlayerController stop];
    [self.hashtags removeAllObjects];
    [self.tableView reloadData];
    [self.textField becomeFirstResponder];
    [self startSaving];
    
    //[self setNumberToolbar];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder
                    createEventWithCategory:@"UX"
                    action:@"posting"
                    label:@"ok image"
                    value:nil] build]];
}

- (IBAction)exitAction:(id)sender{
    self.chooseShareView.hidden = YES;
    self.chooseHashtagView.hidden = YES;
    self.chooseImageView.hidden = NO;
    [videoPlayerController playFromBeginning];
    [self.hashtags removeAllObjects];
    [self.tableView reloadData];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder
                    createEventWithCategory:@"UX"
                    action:@"posting"
                    label:@"exit image"
                    value:nil] build]];
}

- (IBAction)backAction:(id)sender {

    self.chooseShareView.hidden = YES;
    self.chooseHashtagView.hidden = YES;
    self.chooseImageView.hidden = NO;
    _image = nil;
    videoURL = nil;
    [videoPlayerController stop];
    // go to camera
    [self deleteSaving];
    NSLog(@"picker class %@", [self.parentViewController class]);
    self.view.hidden = YES;
    [(SELPageViewController*)self.parentViewController.parentViewController lockSideSwipe:NO];
    
    if ([self.delegate respondsToSelector:@selector(didCancelPost)]) {
        [self.delegate didCancelPost];
    }
    
    //[self dismissViewControllerAnimated:NO completion:^{
    //    [self.delegate openCamera];
    //}];
}

// SUGGESTED HASHTAGS //

- (void) suggestedHashtagTapped:(id)sender{
    UIBarButtonItem *barButtonItem = (UIBarButtonItem *)sender;
    self.textField.text = barButtonItem.title;
    [self.textField resignFirstResponder];
    //[self setNumberToolbar];
}

- (void) moreHashtagsTapped:(id)sender{
    
    @try {
        [suggestedTableViewController getAvaiableHashtags:hashtags];
    }
    @catch (NSException *exception) {
    }
    
    suggestedTableViewController.color = color;
    [self presentViewController:suggestedTableViewController animated:YES completion:^{
    }];
    //[self setNumberToolbar];
}

- (void) setNumberToolbar{
    
    UIBarButtonItem *a = [self getSuggestedHashtag:0];
    UIBarButtonItem *b = [self getSuggestedHashtag:1];
    UIBarButtonItem *c = [self getSuggestedHashtag:2];
    UIBarButtonItem *space = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *more = [[UIBarButtonItem alloc]initWithTitle:@"+ " style:UIBarButtonItemStyleDone target:self action:@selector(moreHashtagsTapped:)];
    NSMutableArray *colorArray = (NSMutableArray *)[color getColorArray];
    more.tintColor = [colorArray objectAtIndex:4];
    NSDictionary * attributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:24.0f]};
    [more setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    numberToolbar.items = [NSArray arrayWithObjects:a, b, c, space, more, nil];
    [numberToolbar sizeToFit];
}

- (UIBarButtonItem *) getSuggestedHashtag:(int)place{
    
    NSString *suggested;
    @try {
        suggested = [[suggestedTableViewController getAvaiableHashtags:hashtags] objectAtIndex:place];
        suggested = [@"#" stringByAppendingString:suggested];
        numberToolbar.hidden = NO;
    }
    @catch (NSException *exception) {
        numberToolbar.hidden = YES;
    }
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithTitle:suggested style:UIBarButtonItemStyleBordered target:self action:@selector(suggestedHashtagTapped:)];
    NSMutableArray *colorArray = (NSMutableArray *)[color getColorArray];
    barButton.tintColor = [colorArray objectAtIndex:place];
    return barButton;
}

- (void) addHashtag:(NSString *)hashtag{
    self.textField.text = hashtag;
    [self textFieldDidEndEditing:self.textField];
    //[self setNumberToolbar];
}

- (IBAction)suggestedHashtags:(id)sender {
    NSLog(@"tappled suggeted Hashtags");
    [self moreHashtagsTapped:sender];
}


// Color change
- (UIColor*)changeBrightness:(UIColor*)ecolor amount:(CGFloat)amount
{
    
    CGFloat hue, saturation, brightness, alpha;
    if ([ecolor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
        brightness += (amount-1.0);
        brightness = MAX(MIN(brightness, 1.0), 0.0);
        return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
    }
    
    CGFloat white;
    if ([ecolor getWhite:&white alpha:&alpha]) {
        white += (amount-1.0);
        white = MAX(MIN(white, 1.0), 0.0);
        return [UIColor colorWithWhite:white alpha:alpha];
    }
    
    return nil;
}

#pragma mark - PBJVideoPlayerControllerDelegate

- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer {
    NSLog(@"Max duration of the video: %f", videoPlayer.maxDuration);
    [videoPlayer playFromBeginning];
}

- (void)videoPlayerPlaybackStateDidChange:(PBJVideoPlayerController *)videoPlayer{
}

- (void)videoPlayerBufferringStateDidChange:(PBJVideoPlayerController *)videoPlayer {
    /*switch (videoPlayer.bufferingState) {
     case PBJVideoPlayerBufferingStateUnknown:
     NSLog(@"Buffering state unknown!");
     break;
     
     case PBJVideoPlayerBufferingStateReady:
     NSLog(@"Buffering state Ready! Video will start/ready playing now.");
     break;
     
     case PBJVideoPlayerBufferingStateDelayed:
     NSLog(@"Buffering state Delayed! Video will pause/stop playing now.");
     break;
     default:
     break;
     }*/
}

- (void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer{
}

- (void)videoPlayerPlaybackDidEnd:(PBJVideoPlayerController *)videoPlayer{
}


@end
