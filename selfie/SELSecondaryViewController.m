//
//  SELSecondaryViewController.m
//  #life
//
//  Created by Griffin Anderson on 3/21/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import "SELSecondaryViewController.h"

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface SELSecondaryViewController ()

@property SELSecondaryTableTableViewController *tableViewController;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIImageView *gamingImageView;
@property (weak, nonatomic) IBOutlet UILabel *gamingRanking;
@property (weak, nonatomic) IBOutlet UILabel *gamingPts;
@property (weak, nonatomic) IBOutlet UIView *gamingStatus;
- (IBAction)gamingQ:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *gamingQ;

@end

@implementation SELSecondaryViewController

@synthesize color;
@synthesize tableViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    color = ((SELPageViewController*)self.parentViewController).color;
    
    self.view.backgroundColor = [UIColor colorWithWhite:.98 alpha:1];
    // TableViewController
    tableViewController = [[SELSecondaryTableTableViewController alloc] init];
    tableViewController.color = color;
    [self.view addSubview:tableViewController.view];
    [self addChildViewController:tableViewController];
    [tableViewController didMoveToParentViewController:self];

    // footer view
    [(SELPageViewController*)self.parentViewController setFooterBar:self.footerView disapear:NO];
    
    // Set Bar
    [(SELPageViewController*)self.parentViewController setSeondaryBar:self.view];
    
    // top
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 1.0f);
    topBorder.backgroundColor = [UIColor colorWithWhite:1.0 alpha:.15f].CGColor;
    [self.view.layer addSublayer:topBorder];
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.view.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(4.0, 4.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.bounds;
    maskLayer.path = maskPath.CGPath;
    self.view.layer.mask = maskLayer;
    
    // Gaming Section
    /**
    UIImage *upvote = [[UIImage imageNamed:@"upvote"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.gamingImageView.image = upvote;
    self.gamingImageView.transform = CGAffineTransformMakeScale(.8, .8);
    self.gamingImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.gamingImageView setTintColor:[color getPrimaryColor]];
    self.gamingImageView.clipsToBounds = YES;
    
    UITapGestureRecognizer *gamingTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gamingQ:)];
    [self.gamingStatus addGestureRecognizer:gamingTapRecognizer];
    
    [self getNumberUserLikes];
     **/

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Second Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)gamingQ:(id)sender {
    self.gamingQ.hidden = !self.gamingQ.hidden;
    self.gamingQ.alpha = 1.0;
    
    [UIView animateKeyframesWithDuration:2.0 delay:4.0 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
        self.gamingQ.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.gamingQ.hidden = !self.gamingQ.hidden;
    }];
}

/** Gaming **/

- (void) setGamingData:(float)status{
    
    [self getLevels:(int)status];
    self.gamingPts.text = [NSString stringWithFormat:@"%d",(int)status];
    [self drawHalfCircle];
    [self drawHalfCircleColor:status];
}

- (void) drawHalfCircle{
    int padding = 8.0;
    int radius = (self.gamingStatus.frame.size.width / 2.0) - padding;
    CAShapeLayer *statusViewLayer = [CAShapeLayer layer];
    statusViewLayer.position = CGPointMake(padding, padding);
    statusViewLayer.fillColor = [UIColor clearColor].CGColor;
    statusViewLayer.strokeColor = ([UIColor colorWithWhite:.95 alpha:1]).CGColor;
    statusViewLayer.lineWidth = 14;
    UIBezierPath *apath = [UIBezierPath bezierPath];
    CGPoint point = CGPointMake(0, radius);
    point.x += radius;
    [apath addArcWithCenter:point radius:radius startAngle:DEGREES_TO_RADIANS(135.1) endAngle:M_PI_4 clockwise:YES];
    statusViewLayer.path = apath.CGPath;
    [self.gamingStatus.layer addSublayer:statusViewLayer];
}

- (void) drawHalfCircleColor:(float)status{
    int numDaysIn = [self getDaysSinceJoined];
    float totalStatus = (34 * numDaysIn);
    int padding = 8.0;
    int radius = (self.gamingStatus.frame.size.width / 2.0) - padding;
    CAShapeLayer *statusViewLayer = [CAShapeLayer layer];
    statusViewLayer.position = CGPointMake(padding, padding);
    statusViewLayer.fillColor = [UIColor clearColor].CGColor;
    statusViewLayer.strokeColor = ([color getPrimaryColor]).CGColor;
    statusViewLayer.lineWidth = 12;
    
    UIBezierPath *apath = [UIBezierPath bezierPath];
    CGPoint point = CGPointMake(0, radius);
    point.x += radius;
    
    float degreeStatus = (status / totalStatus) * 270.00;
    degreeStatus = MAX(degreeStatus, 2);
    float radiansStatus =  MIN(M_PI + DEGREES_TO_RADIANS(degreeStatus) - M_PI_4, DEGREES_TO_RADIANS(270));
    [apath addArcWithCenter:point radius:radius startAngle:M_PI - M_PI_4 endAngle:radiansStatus clockwise:YES];
    statusViewLayer.path = apath.CGPath;
    [self.gamingStatus.layer addSublayer:statusViewLayer];
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
                [self setGamingData:acount];
            } else {
                // The request failed
            }
        }];
    }else{
        [self setGamingData:0];
    }
}

- (int) postedSince:(NSDate *)postedSince{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:postedSince
                                                          toDate:[NSDate date]
                                                         options:NSCalendarWrapComponents];
    return (int)[components day];
}

- (int) getDaysSinceJoined {
    
    
    return [self postedSince:[PFUser currentUser].createdAt];
    /**
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit fromDate:now];
    
    NSUInteger weekdayToday = [components weekday];
    return (int) weekdayToday - 1;
     **/
}

- (void) getLevels:(int)pts{
    
    int numDaysIn = [self getDaysSinceJoined];
    //** 1000 is located up as well
    if ((34 * numDaysIn) < pts) {
        self.gamingRanking.text = @"Top 1%";
    }else if((21 * numDaysIn) < pts) {
        self.gamingRanking.text = @"Top 3%";
    }else if((13 * numDaysIn) < pts) {
        self.gamingRanking.text = @"Top 5%";
    }else if((8 * numDaysIn) < pts) {
        self.gamingRanking.text = @"Top 10%";
    }else if((5 * numDaysIn) < pts) {
        self.gamingRanking.text = @"Top 25%";
    }else if((1 * numDaysIn) < pts) {
        self.gamingRanking.text = @"Top 50%";
    }else{
        self.gamingRanking.text = @"Not Ranked";
        self.gamingRanking.textColor = [UIColor colorWithWhite:.82 alpha:1];
    }
}
@end
