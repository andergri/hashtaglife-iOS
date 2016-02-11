//
//  SELOverlayViewController.m
//  #life
//
//  Created by Griffin Anderson on 5/25/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import "SELOverlayViewController.h"
#import "SELFlagObject.h"
#import "SELHeartObject.h"
#import "SELImageCountObject.h"

#import <CoreGraphics/CoreGraphics.h>

#define kExposedHeight 110.0

@interface SELOverlayViewController () <UIGestureRecognizerDelegate>

@property SELFlagObject  *flagButton;
@property SELHeartObject *heartButton;
@property SELHashtagsListObject *hashtagsList;
@property SELImageCountObject *imageCount;
@property UITapGestureRecognizer *tap;
@property PFObject *currentObject;
@property BOOL isUsernameTrayShown;
@property UIImageView *arrowImageView;
@property UILabel *arrowLabel;

@end

@implementation SELOverlayViewController

@synthesize flagButton;
@synthesize heartButton;
@synthesize hashtagsList;
@synthesize imageCount;
@synthesize color;
@synthesize tap;
@synthesize delegate;
@synthesize currentObject;
@synthesize isUsernameTrayShown;
@synthesize arrowImageView;
@synthesize arrowLabel;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.frame = [[UIScreen mainScreen] bounds];
    
    //Heart Button
    heartButton = [[SELHeartObject alloc] init];
    [heartButton initHeart:self.view color:color];
    
    //Flag Button
    flagButton = [[SELFlagObject alloc] init];
    [flagButton initFlag:self.view color:color];
    
    //Back Button
    [flagButton initBack:self.view color:color];
    
    // Hashtags
    hashtagsList = [[SELHashtagsListObject alloc] init];
    [hashtagsList initHashtags:self.view color:color];
    hashtagsList.delegate = self;
    
    // Count label on popup
    imageCount = [[SELImageCountObject alloc] init];
    [imageCount initImageTally:self.view color:color];
    
    // Arrow Button
    arrowImageView = [[UIImageView alloc] init];
    arrowImageView.contentMode = UIViewContentModeCenter;
    [arrowImageView setTintColor:[UIColor colorWithWhite:1 alpha:.9]];
    arrowImageView.userInteractionEnabled = YES;
    [self.view addSubview:arrowImageView];
    arrowLabel = [[UILabel alloc] initWithFrame:CGRectMake((-65+arrowImageView.frame.size.width)/2.0, -28, 120, 40)];
    arrowLabel.text = @"my votes";
    arrowLabel.font = [UIFont boldSystemFontOfSize:22];
    arrowLabel.textAlignment = NSTextAlignmentCenter;
    arrowLabel.textColor = [UIColor colorWithWhite:1.0 alpha:.9];
    [arrowImageView addSubview:arrowLabel];
    arrowImageView.alpha = 0.0;
    arrowLabel.alpha = 0.0;
    
    // Swipe Gesture Recogniser
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tapForwardButton)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer];
    recognizer.delegate = self;
    UISwipeGestureRecognizer *lrecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tapForwardButton)];
    [lrecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.view addGestureRecognizer:lrecognizer];
    lrecognizer.delegate = self;
    UISwipeGestureRecognizer *trecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tapForwardButton)];//tapPullUp:
    [trecognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [self.view addGestureRecognizer:trecognizer];
    trecognizer.delegate = self;
    UISwipeGestureRecognizer *drecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tapForwardButton)];//tapPullDown
    [drecognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.view addGestureRecognizer:drecognizer];
    drecognizer.delegate = self;
    
    // Tap Gesture
    tap = [[UITapGestureRecognizer alloc]
            initWithTarget:self action:@selector(handlIconsTap:)];
    tap.numberOfTouchesRequired = 1;
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //[self setArrowDown:YES];
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [arrowImageView.layer removeAnimationForKey:@"animateArrow"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma - private Methods

- (void) setSelfie:(PFObject *)selfie{
    [self reset];
    currentObject = selfie;
    [heartButton resetHeart:currentObject];
    [heartButton setCount:currentObject];
    [imageCount countImageTally:currentObject];
    [hashtagsList setHashtags:currentObject searched:nil];
    //[self setArrowDown:YES];
    self.view.hidden = NO;
    
}

- (void) hideOverlay{
    [self reset];
    self.view.hidden = YES;
}

#pragma - private Methods


// reset photos
- (void) reset{
    currentObject = nil;
    isUsernameTrayShown = NO;
    [self.delegate pullDown:NO];
    [flagButton resetFlag];
}

// tap forward button
- (void) tapForwardButton{
    if ([self isTrayOpen])
        return;
    [self.delegate goForward];
    [self recordIconPressed:@"next image" value:nil];
}
// tap back button
- (void) tapBackButton{
    if ([self isTrayOpen])
        return;
    [self.delegate goBackward];
    [self recordIconPressed:@"tap back" value:nil];
}

// tap pull up
/**
- (void) tapPullUp:(UIGestureRecognizer *)recognizer{
    if ([self isTrayOpen] && [self isUserCreated]){
        CGPoint point = [recognizer locationInView:[self view]];
        NSLog(@"taray open %f", point.y);
        if (point.y > self.view.frame.size.height - kExposedHeight) {
            isUsernameTrayShown = NO;
            [self setArrowDown:YES];
            [self.delegate pullDown:NO];
        }
    }else
        [self tapForwardButton];
}

// tap pull down
- (void) tapPullDown{
    if ([self isTrayOpen] || ![self isUserCreated])
        return;
    isUsernameTrayShown = YES;
    [self setArrowDown:NO];
    [self.delegate pullDown:YES];
    [self recordIconPressed:@"pull down" value:nil];
}
**/
// tap flag
- (void) tapFlag{
    if ([self isTrayOpen])
        return;
    [flagButton tapFlag:currentObject];
    [self recordIconPressed:@"tap flag" value:nil];
}

// tap Heart
- (void) tapUpvote{
    [heartButton tapUpvote:currentObject];
    [self recordIconPressed:@"tap heart" value:[NSNumber numberWithInt:1]];
}

// tap downvote
- (void) tapDownvote{
    [heartButton tapDownvote:currentObject];
    [self recordIconPressed:@"tap heart" value:[NSNumber numberWithInt:-1]];
}

// tap twitter
- (void) tapTwitter{
    [self.delegate showTweetView];
}

/** Handle Tray Checking **/

- (BOOL) isTrayOpen{
    return isUsernameTrayShown;
}

- (BOOL) isUserCreated{
    if([((PFUser*)currentObject[@"from"]).objectId isEqualToString:[PFUser currentUser].objectId])
        return YES;
    return NO;
}

#pragma - handle taps

-(void)handlIconsTap:(UITapGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    NSLog(@"point %f %f %f", point.y, self.view.frame.size.height - (kExposedHeight + 20), (self.view.frame.size.height - (kExposedHeight - 20)));
    if(((self.view.frame.size.width - 110) < point.x) && ((self.view.frame.size.height - 70) < point.y)){
            if((self.view.frame.size.width - 60) < point.x){
                [self tapDownvote];
            }else{
                [self tapUpvote];
            }
    } else if(((self.view.frame.size.width - 110) > point.x) && ((self.view.frame.size.height - 70) < point.y)){
        //[self tapTwitter];
    } else if ((self.view.frame.size.width - 40) < point.x && 55 > point.y) {
        [self tapFlag];
        
    } else if ((self.view.frame.size.width - 90) < point.x && (self.view.frame.size.width - 40) > point.x && 55 > point.y) {
        [self tapBackButton];
    }else if(140 < point.x && point.x < 180 && 40 < point.y && point.y < 80 && [self isUserCreated]){
        //[self tapPullDown];
    }else if(140 < point.x && point.x < 180 && (self.view.frame.size.height - (kExposedHeight + 20)) < point.y && point.y < (self.view.frame.size.height - (kExposedHeight - 20)) && [self isUserCreated]){
        //[self tapPullUp:gestureRecognizer];
    }else if((self.view.frame.size.height - 70) > point.y){
        [self tapForwardButton];
    }
}


#pragma mark - Hashtag pressed

- (void)setupGesture:(UILabel *)label{
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hashtagTapped:)];
    tapGesture.numberOfTouchesRequired = 1;
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.delegate = self;
    tapGesture.enabled = YES;
    tapGesture.cancelsTouchesInView = NO;
    [label addGestureRecognizer:tapGesture];
    
}

-(void)hashtagTapped:(UITapGestureRecognizer *)gestureRecognizer {
    
    NSString *hashtag = [((UILabel *)gestureRecognizer.view).text stringByReplacingOccurrencesOfString:@"#" withString:@""];
    hashtag = [hashtag stringByReplacingOccurrencesOfString:@" " withString:@""];
    [self.delegate showSelfies:2 hashtag:hashtag color:[UIColor colorWithRed:249.0/255.0 green:191.0/255.0 blue:59.0/255.0 alpha:1.0f] location:NO objectId:nil];
}


#pragma mark - Google Analytics

- (void) recordIconPressed:(NSString*)action value:(NSNumber*)value{
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder
                    createEventWithCategory:@"UX"
                    action:@"selfie"
                    label:action
                    value:value] build]];
}

/** Arrow **/

- (void) setArrowDown:(BOOL)downArrow{
    
    arrowImageView.alpha = 0.0;
    arrowLabel.alpha = 0.0;
    
    if (![self isUserCreated])
        return;

    if (downArrow) {
        UIImage *downArrowImage = [[UIImage imageNamed:@"arrow-down"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        arrowImageView.image = downArrowImage;
        arrowImageView.frame = CGRectMake((self.view.frame.size.width - downArrowImage.size.width) / 2.0, 64, downArrowImage.size.width, downArrowImage.size.height);
        //UIGestureRecognizer *tapGestureRecognizer = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(setArrowDown:)];
        //[self.arrowImageView addGestureRecognizer:tapGestureRecognizer];
        
    }else{
        UIImage *adownArrowImage = [[UIImage imageNamed:@"arrow-up"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        arrowImageView.image = adownArrowImage;
        arrowImageView.frame = CGRectMake((self.view.frame.size.width - adownArrowImage.size.width) / 2.0, self.view.frame.size.height - kExposedHeight, adownArrowImage.size.width, adownArrowImage.size.height);
    }
    [arrowImageView setNeedsDisplay];

    [UIView animateWithDuration:1.0 delay:0.8 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        arrowImageView.alpha = 1.0;
        if (downArrow)
            arrowLabel.alpha = 1.0;
            
    } completion:^(BOOL finished) {
        
    }];
        
    [arrowImageView.layer removeAnimationForKey:@"animateArrow"];
    [self animateArrow];
}

- (void) animateArrow {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = 2.0;
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:5];
    [values addObject:[NSNumber numberWithFloat:arrowImageView.frame.origin.y]];
    [values addObject:[NSNumber numberWithFloat:3 + arrowImageView.frame.origin.y]];
    [values addObject:[NSNumber numberWithFloat:arrowImageView.frame.origin.y]];
    [values addObject:[NSNumber numberWithFloat:-3 + arrowImageView.frame.origin.y]];
    [values addObject:[NSNumber numberWithFloat:arrowImageView.frame.origin.y]];
    
    animation.values = values;
    animation.repeatCount = 100;
    [arrowImageView.layer setValue:[NSNumber numberWithInt:160] forKeyPath:animation.keyPath];
    [self.arrowImageView.layer addAnimation:animation forKey:@"animateArrow"];
}

@end
