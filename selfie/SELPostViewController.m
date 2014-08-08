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

@property (weak, nonatomic) IBOutlet UIView *buttonContainerView;
@property (weak, nonatomic) IBOutlet UIView *chooseImageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIView *chooseHashtagView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
- (IBAction)okAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *exitButton;
- (IBAction)exitAction:(id)sender;
- (IBAction)backAction:(id)sender;

@end

@implementation SELPostViewController

@synthesize hashtags;
@synthesize image;
@synthesize delegate;
@synthesize color;

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
    hashtags = [[NSMutableArray alloc] init];
    [self.tableView setDelegate:self];
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"HashtagTableViewCell"];
    
    
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
    
    //Textfield Styling
    [self.textField setDelegate:self];
    UILabel *headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
    headingLabel.text = @"#";
    headingLabel.font = [UIFont systemFontOfSize:29];
    headingLabel.textColor = [UIColor whiteColor];
    headingLabel.backgroundColor = [UIColor clearColor];
    headingLabel.textAlignment = NSTextAlignmentCenter;
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, 44)];
    [paddingView addSubview:headingLabel];
    self.textField.leftView = paddingView;
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    self.textField.layer.masksToBounds=YES;
    self.textField.bounds = CGRectInset(self.textField.frame, -10.0f, 0.0f);
    
    // ok button back button
    self.okButton.layer.cornerRadius = roundf(self.okButton.frame.size.width/2.0);
    self.backButton.layer.cornerRadius = roundf(self.backButton.frame.size.width/2.0);
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void) addColor:(SELColorPicker *)acolor{
    
    self.headerView.backgroundColor = [[acolor getColorArray] objectAtIndex:0];
    
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
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    self.imageView.frame = self.view.frame;
    self.chooseHashtagView.frame = self.view.frame;
    self.chooseImageView.frame = self.view.frame;
    self.exitButton.frame = CGRectMake(0, self.view.frame.size.height - 80, self.exitButton.frame.size.width, self.exitButton.frame.size.height);
    self.buttonContainerView.frame = CGRectMake(0, self.view.frame.size.height - 85, self.buttonContainerView.frame.size.width, self.buttonContainerView.frame.size.height);
    
    // Do any additional setup after loading the view from its nib.
    self.chooseHashtagView.hidden = YES;
    self.chooseImageView.hidden = NO;
    self.imageView.image = image;
    [self.hashtags removeAllObjects];
    [self.tableView reloadData];

    //self.imageView.contentMode = UIViewContentModeCenter;
    //self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    
    NSLog(@"image w %f h %f", self.imageView.image.size.width, self.imageView.image.size.height);
}

#pragma mark - TextField

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    if (textField.text.length > 0) {
        
        NSArray* hashes = [textField.text componentsSeparatedByString:@" "];
        for(NSString * hash in hashes) {
            NSArray* hashesa = [hash componentsSeparatedByString:@"#"];
            for(NSString * hasha in hashesa) {
                if ([self checkHashtag:hasha] && hasha.length > 0 && hashtags.count < 5) {
                    [hashtags insertObject:hasha atIndex:0];
                }
            }
        }
        textField.text = @"";
    }
    [self.tableView reloadData];
    [self.textField resignFirstResponder];
}

- (BOOL) checkHashtag: (NSString *)hash{

    hash = [hash stringByReplacingOccurrencesOfString:@"#" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];

    if(hashtags.count > 5){
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

-(void)dismissKeyboard {
    [self.textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
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
    
    NSMutableArray *colorArray = (NSMutableArray *)[color getColorArray];
    [colorArray removeObjectAtIndex:0];
    int i = indexPath.item % 9;
    cell.backgroundColor = [colorArray objectAtIndex:i];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (hashtags.count > 0) {
        return @"Submit";
    }else{
        return nil;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (hashtags.count > 0) {

        UILabel *headerLabel = [[UILabel alloc]init];
        headerLabel.tag = section;
        headerLabel.userInteractionEnabled = YES;
        headerLabel.backgroundColor = [color getPrimaryColor];
        headerLabel.text = @"Submit";
        headerLabel.textColor = [UIColor whiteColor];
        headerLabel.font = [UIFont systemFontOfSize:29];
        headerLabel.textAlignment = NSTextAlignmentCenter;
        headerLabel.frame = CGRectMake(0, 0, tableView.tableHeaderView.frame.size.width, tableView.tableHeaderView.frame.size.height);
    
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(catchHeaderSubmission:)];
        tapGesture.cancelsTouchesInView = NO;
        [headerLabel addGestureRecognizer:tapGesture];
    
        return headerLabel;
    }else{
        return nil;
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.hashtags removeObjectAtIndex:indexPath.item];
        [tableView reloadData];
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (hashtags.count == 0)
        return 0.0f;
    return 80.0f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

-(void)catchHeaderSubmission:(UIGestureRecognizer*)sender{
    
    [self textFieldDidEndEditing:self.textField];
    [self saveSelfie];
}

#pragma - mark UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)activeScrollView{
    NSLog(@"scrollViewWillBeginDragging");
    [self.textField resignFirstResponder];
}

#pragma - mark save for parse

-(void)saveSelfie {
    NSLog(@"saving Selfie ...");
    
    // Clean Data
    NSArray *cleanHashtags = (NSArray*) hashtags;
    
    NSData *imageData = UIImagePNGRepresentation(image);
    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
    
    // Save Selfie
    PFObject *selfie = [PFObject objectWithClassName:@"Selfie"];
    selfie[@"likes"] = @0;
    selfie[@"flags"] = @0;
    selfie[@"visits"] = @0;
    selfie[@"from"] = [PFUser currentUser];
    selfie[@"image"] = imageFile;
    [selfie addUniqueObjectsFromArray:cleanHashtags forKey:@"hashtags"];
    [selfie saveInBackground];
    
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
                    [hash saveInBackground];
                    NSLog(@"Successfully updated hashtag.");
                }else{
                    
                    PFObject *hash = [PFObject objectWithClassName:@"Hashtag"];
                    hash[@"count"] = @1;
                    hash[@"name"] = cleanHashtag;
                    [hash saveInBackground];
                    NSLog(@"Successfully created hashtag.");
                }
                
            }else{
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
    [self closeView];
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

- (void)closeView{
    [self dismissViewControllerAnimated:NO completion:nil];
}


#pragma - mark other

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)okAction:(id)sender {
    self.chooseHashtagView.hidden = NO;
    self.chooseImageView.hidden = YES;
    [self.hashtags removeAllObjects];
    [self.tableView reloadData];
    [self.textField becomeFirstResponder];
}

- (IBAction)exitAction:(id)sender{
    self.chooseHashtagView.hidden = YES;
    self.chooseImageView.hidden = NO;
    [self.hashtags removeAllObjects];
    [self.tableView reloadData];
}

- (IBAction)backAction:(id)sender {
    self.chooseHashtagView.hidden = YES;
    self.chooseImageView.hidden = NO;
    // go to camera
    NSLog(@"picker class %@", [self.parentViewController class]);

    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate openCamera];
    }];
}
@end
