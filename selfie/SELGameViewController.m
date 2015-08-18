//
//  SELGameViewController.m
//  #life
//
//  Created by Griffin Anderson on 11/19/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import "SELGameViewController.h"

@interface SELGameViewController ()
@property (weak, nonatomic) IBOutlet UIView *circlelastphoto;
@property (weak, nonatomic) IBOutlet UIView *circletotal;
@property (weak, nonatomic) IBOutlet UIView *circleshare;
@property (weak, nonatomic) IBOutlet UILabel *countlastphoto;
@property (weak, nonatomic) IBOutlet UIImageView *shareimage;

@property UITapGestureRecognizer *exittpgr;


@end

@implementation SELGameViewController

@synthesize acolor;
@synthesize exittpgr;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [acolor getPrimaryColor];
    
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
    
    //Image view exit
    UIImage *backImage = [[UIImage imageNamed:@"exit"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *backImageView = [[UIImageView alloc] initWithImage:backImage];
    backImageView.frame = CGRectMake(4, 4, backImage.size.width, backImage.size.height);
    backImageView.contentMode = UIViewContentModeCenter;
    [backImageView setTintColor:[UIColor whiteColor]];
    backImageView.userInteractionEnabled = YES;
    
    // exit tap gesture
    exittpgr = [[UITapGestureRecognizer alloc]
                initWithTarget:self action:@selector(exitTap:)];
    exittpgr.numberOfTouchesRequired = 1;
    exittpgr.numberOfTapsRequired = 1;
    exittpgr.delegate = self;
    exittpgr.enabled = YES;
    [backImageView addGestureRecognizer:exittpgr];
    
    [self.view addSubview:backImageView];
    
    // circle last photo
    self.circlelastphoto.layer.cornerRadius = roundf(self.circlelastphoto.frame.size.width/2.0);
    self.circlelastphoto.backgroundColor = [UIColor whiteColor];
    
    // count last photo
    self.countlastphoto.textColor = [acolor getPrimaryColor];
    
    // circle total points
    self.circletotal.layer.cornerRadius = roundf(self.circletotal.frame.size.width/2.0);
    self.circletotal.backgroundColor = [UIColor whiteColor];
    
    // count total points
    self.counttotal.textColor = [acolor getPrimaryColor];
    
    // circle share
    self.circleshare.layer.cornerRadius = roundf(self.circleshare.frame.size.width/2.0);
    self.circleshare.backgroundColor = [UIColor whiteColor];
    
    // share imgae
    
    UIImage *shareImage = [[UIImage imageNamed:@"share"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.shareimage.image = shareImage;
    [self.shareimage setTintColor:[acolor getPrimaryColor]];
    self.shareimage.contentMode = UIViewContentModeCenter;
    
    // count
    [self getNumberUserLikes];
    
    UITapGestureRecognizer *lpgr = [[UITapGestureRecognizer alloc]
                                    initWithTarget:self action:@selector(helpShare:)];
    lpgr.numberOfTouchesRequired = 1;
    lpgr.numberOfTapsRequired = 1;
    lpgr.delegate = self;
    lpgr.enabled = YES;
    [self.circleshare addGestureRecognizer:lpgr];
    
    // half circle
    //[self drawHalfCircle:self.circlelastphoto];
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(void)exitTap:(UITapGestureRecognizer *)gestureRecognizer {
    NSLog(@"eit");
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) drawHalfCircle:(UIView *)parent{

    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint point = CGPointMake(85, 85);
    CGFloat radius = 83.0;
    
    [path addArcWithCenter:point radius:radius startAngle:0 endAngle:1 * M_PI clockwise:YES];
    

    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = [path CGPath];
    layer.lineWidth = 2.0;
    layer.fillColor = [[acolor getPrimaryColor] CGColor];
    layer.strokeColor = [[UIColor whiteColor] CGColor];
    layer.opacity = .30f;
    
    [parent.layer insertSublayer:layer below:self.countlastphoto.layer];
}

- (void) getNumberUserLikes{
    
    PFUser *user = [PFUser currentUser];
    if (user) {
        
        PFQuery *query = [PFQuery queryWithClassName:@"Selfie"];
        [query whereKey:@"from" equalTo:[PFUser currentUser]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
            if (!error) {
                // The count request succeeded. Log the count
                int acount = 0;
                for (PFObject *obj in results) {
                    acount += [obj[@"likes"] intValue];
                }
                self.counttotal.text = [NSString stringWithFormat:@"%d", acount];
            } else {
                // The request failed
            }
        }];
        
    }else{
        self.counttotal.text = @"0";
    }
}

- (void) helpShare:(UITapGestureRecognizer *)gestureRecognizer{
 
    NSString *_postText = [NSString stringWithFormat:@"Check out #life app on the app store @ https://itunes.apple.com/us/app/life-hashtag-your-life/id904884186"];
    NSArray *activityItems = nil;
    activityItems = @[_postText];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:^{
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder
                        createEventWithCategory:@"UX"
                        action:@"taped share b"
                        label:@""
                        value:nil] build]];
    }];
}

// Social Share Open
- (void)showShare:(NSArray *)activityItems{
    
    //tpgr.enabled = NO;
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:^{
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder
                        createEventWithCategory:@"UX"
                        action:@"taped share"
                        label:@""
                        value:nil] build]];
    }];
    
    //tpgr.enabled = YES;
}
@end
