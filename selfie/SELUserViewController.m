//
//  SELUserViewController.m
//  selfie
//
//  Created by Griffin Anderson on 7/25/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import "SELUserViewController.h"

@interface SELUserViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *intro;
@property NSArray *login;
@property NSArray *signup;
@property NSArray *current;
@property UITextField *usernameTextField;
@property UITextField *passwordTextField;

- (IBAction)sendToTerms:(id)sender;
- (IBAction)sendToPrivacy:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *termsppView;

@end

@implementation SELUserViewController

@synthesize intro;
@synthesize login;
@synthesize signup;
@synthesize current;
@synthesize color;
@synthesize usernameTextField;
@synthesize passwordTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (id)init{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil]; // nil is ok if the nib is included in the main bundle
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [color getPrimaryColor];
    
    intro = [NSArray arrayWithObjects:@"Signup", @"Login", nil];
    signup = [NSArray arrayWithObjects:@"Username", @"Password", @"Signup", @"Back", nil];
    login = [NSArray arrayWithObjects:@"Username", @"Password", @"Login", @"Back", nil];
    current = intro;
    
    usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 320, 70)];
    usernameTextField.backgroundColor = [UIColor clearColor];
    usernameTextField.textAlignment = NSTextAlignmentCenter;
    usernameTextField.textColor = [UIColor whiteColor];
    usernameTextField.font = [UIFont systemFontOfSize:28];
    usernameTextField.returnKeyType = UIReturnKeyNext;
    usernameTextField.autocorrectionType = FALSE;
    usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 320, 70)];
    passwordTextField.backgroundColor = [UIColor clearColor];
    passwordTextField.textAlignment = NSTextAlignmentCenter;
    passwordTextField.textColor = [UIColor whiteColor];
    passwordTextField.font = [UIFont systemFontOfSize:28];
    passwordTextField.returnKeyType = UIReturnKeyDone;
    passwordTextField.autocorrectionType = FALSE;
    passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    passwordTextField.secureTextEntry = YES;
    
    [self.tableView setDelegate:self];
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"HashtagTableViewCell"];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    PFUser *user = [PFUser currentUser];
    if (user) {
        NSLog(@"logged in");
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return current.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HashtagTableViewCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HashtagTableViewCell"];
    }
    
    NSArray *colorArray = [color getColorArray];
    int i = indexPath.item % 10;
    cell.backgroundColor = [colorArray objectAtIndex:i];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:28];
    cell.textLabel.text = @"";
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    usernameTextField.hidden = YES;
    passwordTextField.hidden = YES;
    
    usernameTextField.text = @"";
    passwordTextField.text = @"";
    
    if (current.count == 2) {
        cell.textLabel.text = [current objectAtIndex:indexPath.item];
    }else{

        usernameTextField.hidden = NO;
        passwordTextField.hidden = NO;
        
        if(indexPath.item == 0){
            
            usernameTextField.placeholder = [current objectAtIndex:indexPath.item];
            [cell addSubview:usernameTextField];
        
        } else if(indexPath.item == 1){

            passwordTextField.placeholder = [current objectAtIndex:indexPath.item];
            [cell addSubview:passwordTextField];
            
        }else{
            cell.textLabel.text = [current objectAtIndex:indexPath.item];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (current.count == 2) {
        self.termsppView.hidden = YES;
        if (indexPath.item == 0) {
            current = signup;
        }else if (indexPath.item == 1) {
            current = login;
        }else{}
        [self.tableView reloadData];
        return;
    }
    if (current.count == 4) {
        if (indexPath.item == 3) {
            current = intro;
            self.termsppView.hidden = NO;
        }else if (indexPath.item == 2) {
            if ([[current objectAtIndex:2] isEqualToString:@"Signup"]) {
                [self signupUser];
            }else{
                [self loginUser];
            }
        }else{}
        [self.tableView reloadData];
        return;
    }
}

/**
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
}
**/

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) signupUser {
    
    if (usernameTextField.text.length > 0 && passwordTextField.text.length > 0) {
    
    PFUser *newUser = [PFUser user];
    newUser.username = usernameTextField.text;
    newUser.password = passwordTextField.text;
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            NSString *errorString = [error userInfo][@"error"];
            NSIndexPath *path = [NSIndexPath indexPathForRow:2 inSection:0];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
            [cell.textLabel setText:errorString];
            [cell.textLabel performSelector:@selector(setText:)
                                   withObject:@"Signup"
                                   afterDelay:3.0];
            
        }else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
        
    }
}

- (void) loginUser {
    
    if (usernameTextField.text.length > 0 && passwordTextField.text.length > 0) {
    
    [PFUser logInWithUsernameInBackground:usernameTextField.text password:passwordTextField.text block:^(PFUser *user, NSError *error) {
        if (error) {
            NSString *errorString = [error userInfo][@"error"];
            NSIndexPath *path = [NSIndexPath indexPathForRow:2 inSection:0];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
            [cell.textLabel setText:errorString];
            [cell.textLabel performSelector:@selector(setText:)
                                 withObject:@"Login"
                                 afterDelay:3.0];

        }else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
        
    }
}

//Terms & privacy
- (IBAction)sendToTerms:(id)sender {
    NSLog(@"Send To Terms of Service");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.uffda.me/terms"]];
}

- (IBAction)sendToPrivacy:(id)sender {
    NSLog(@"Send To Privacy Policy");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.uffda.me/privacy"]];
}

@end
