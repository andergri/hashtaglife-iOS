//
//  SELSelifeViewController.m
//  #life
//
//  Created by Griffin Anderson on 3/21/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import "SELSelifeViewController.h"

#define kExposedHeight 160.0

@interface SELSelifeViewController ()

@property (weak, nonatomic) IBOutlet UIProgressView *selfieProgressView;
@property (weak, nonatomic) IBOutlet UIButton *exitButton;
@property (weak, nonatomic) IBOutlet UILabel *hashtagLabel;
- (IBAction)exitImage:(id)sender;

@property SELColorPicker *color;
@property SELLoadContent *loadContent;
@property SELContentManger *contentManger;
@property SELImageLoader *imageLoader;
@property SELProgressManger * progressManger;
@property SELPictureViewController *pictureViewController;
@property SELOverlayViewController *overlayViewController;
@property SELMovieViewController *movieViewController;
//@property SELVotingOverlayViewController *votingOverlayViewController;
@property UIActivityIndicatorView *activityIndicator;

@end

@implementation SELSelifeViewController

@synthesize loadContent;
@synthesize contentManger;
@synthesize imageLoader;
@synthesize progressManger;
@synthesize color;
@synthesize pictureViewController;
@synthesize overlayViewController;
@synthesize movieViewController;
//@synthesize votingOverlayViewController;
@synthesize activityIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithColor:(SELColorPicker *)acolor {
    if ((self = [super initWithNibName:@"SELSelifeViewController" bundle:nil]))
    {
        color = acolor;
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = [[UIScreen mainScreen] bounds];

    /** Style **/
    
    UIImage *backImage = [[UIImage imageNamed:@"exit"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *backImageView = [[UIImageView alloc] initWithImage:backImage];
    backImageView.frame = CGRectMake(2, 2, backImage.size.width, backImage.size.height);
    backImageView.contentMode = UIViewContentModeCenter;
    [backImageView setTintColor:[UIColor colorWithWhite:.4 alpha:.7]];
    backImageView.contentMode = UIViewContentModeTop;
    backImageView.contentScaleFactor = 3;
    [self.exitButton addSubview:backImageView];
    
    /** Main **/
    
    // Load Content
    loadContent = [[SELLoadContent alloc] init];
    loadContent.delegate = self;
    
    // Load Content Manger
    contentManger = [[SELContentManger alloc] init];
    contentManger.delegate = self;
    
    // Load Progress Manger
    [self.selfieProgressView setFrame:CGRectMake(0, 0, 300, 15)];
    progressManger = [[SELProgressManger alloc] init:self.selfieProgressView];
    progressManger.delegate = self;
    
    /** Views **/
    
    // Load Image View
    imageLoader = [[SELImageLoader alloc] init];
    imageLoader.delegate = self;
    pictureViewController = [[SELPictureViewController alloc] init];
    pictureViewController.delegate = self;
    [self.view addSubview:pictureViewController.view];
    [self addChildViewController:pictureViewController];
    [pictureViewController didMoveToParentViewController:self];
    
    // Load Video View
    movieViewController = [[SELMovieViewController alloc] init];
    movieViewController.delegate = self;
    [movieViewController pause];
    [self.view addSubview:movieViewController.view];
    [self addChildViewController:movieViewController];
    [movieViewController didMoveToParentViewController:self];
    
    // Load Overlay View
    overlayViewController = [[SELOverlayViewController alloc] init];
    overlayViewController.delegate = self;
    overlayViewController.color = color;
    [self.view addSubview:overlayViewController.view];
    [self addChildViewController:overlayViewController];
    [overlayViewController didMoveToParentViewController:self];
    [overlayViewController hideOverlay];
    
    // Load Voting Overlay View
    /**
    votingOverlayViewController = [[SELVotingOverlayViewController alloc] init];
    votingOverlayViewController.color = color;
    [self.view addSubview:votingOverlayViewController.view];
    [self addChildViewController:votingOverlayViewController];
    [votingOverlayViewController didMoveToParentViewController:self];
    votingOverlayViewController.view.hidden = YES;
    **/
    [self.view bringSubviewToFront:self.exitButton];
    
    // Activity Indicator
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.alpha = 1.0;
    activityIndicator.center = CGPointMake(movieViewController.view.frame.size.width / 2.0, movieViewController.view.frame.size.height / 2.0);
    activityIndicator.hidesWhenStopped = NO;
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
    activityIndicator.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - Loading Methods

- (void) showSelfies:(SELSelfieLoadContent)selectingType hashtag:(NSString*)hashtag color:(UIColor*)acolor location:(BOOL)filtered objectId:(NSString*)objectId{
    
    activityIndicator.hidden = YES;
    movieViewController.view.hidden = YES;
    pictureViewController.view.hidden = YES;
    //votingOverlayViewController.view.hidden = YES;
    [pictureViewController setImage:nil];
    [movieViewController cancel];
    [overlayViewController hideOverlay];
    [progressManger stop];
    self.view.backgroundColor = acolor;
    self.view.hidden = NO;
    
    switch (selectingType) {
        case SELSelifePopular:
            self.hashtagLabel.text = @"popular";
            break;
        case SELSelifeRecent:
            self.hashtagLabel.text = @"recent";
            break;
        case SELSelifeHashtag:
            self.hashtagLabel.text = [NSString stringWithFormat:@"#%@", hashtag];
            break;
        case SELSelifePhotos:
            self.hashtagLabel.text = @"my photos";
            break;
        case SELSelifeObject:
            NSLog(@"hit loading photo");
            self.hashtagLabel.text = @"loading photo";
            break;
        default:
            NSLog(@"Hmm, no selecting photos");
            break;
    }
    
    [loadContent showSelfies:selectingType hashtag:hashtag location:filtered objectId:objectId];
}

#pragma - SELLoadContentDelegate

- (void) contentLoaded:(NSArray *)content error:(NSError*)error{
    if (!error) {
        [contentManger initWithSelfies:content];
    }else{
        [contentManger moveToDirection:SELSelfieDirectionExit];
    }
}

#pragma - SELContentMangerDelegate

// start loading
- (void) selfiesLoaded:(NSMutableArray*)selfies{
    NSLog(@"loading content ...");
    [imageLoader loadSelfies:selfies];
    [movieViewController loadVideos:selfies];
    [progressManger start:selfies];
}

// next image
- (void) directionChanged:(NSUInteger)index{
    // Get Image
    if ([contentManger getCurrentSelfieType] == SELSelfieContentTypeImage) {
        if([imageLoader imageStatusFor:(int)index] == SELSelfieImageStatusSuccessus){
            self.view.backgroundColor = [UIColor blackColor];
            [movieViewController pause];
            UIImage *image = [imageLoader getImageAt:(int)index];
            [overlayViewController setSelfie:[contentManger getCurrentSelfie]];
            [pictureViewController setImage:image];
            pictureViewController.view.hidden = NO;
            movieViewController.view.hidden = YES;
            activityIndicator.hidden = YES;
        }else{
            [contentManger moveToDirection:SELSelfieDirectionForward];
        }
    } else
    // Get Video
    if ([contentManger getCurrentSelfieType] == SELSelfieContentTypeVideo) {
        self.view.backgroundColor = [UIColor blackColor];
        UIImage *image = [imageLoader getImageAt:(int)index];
        [overlayViewController setSelfie:[contentManger getCurrentSelfie]];
        [pictureViewController setImage:image];
        [movieViewController playAtIndex:(int)index];
        pictureViewController.view.hidden = NO;
        movieViewController.view.hidden = YES;
    } else
    // Error
    if ([contentManger getCurrentSelfieType] == SELSelfieContentTypeError) {
        [contentManger moveToDirection:SELSelfieDirectionForward];
    }
}

- (void) hideViewer{
    [progressManger stop];
    self.view.hidden = YES;
    activityIndicator.hidden = YES;
    movieViewController.view.hidden = YES;
    pictureViewController.view.hidden = YES;
    //votingOverlayViewController.view.hidden = YES;
    [pictureViewController setImage:nil];
    [movieViewController cancel];
    [overlayViewController hideOverlay];
}

#pragma - SELProgressMangerDelegate

// Pings for current loading progress
- (void)pingForProgress{
    if ([imageLoader loadingState] == SELSelfieImageLoadingStateBuffering
        || [imageLoader loadingState] == SELSelfieImageLoadingStateUnknown
        ) {
        NSInteger progress =[imageLoader loadingProgress];
        [progressManger update:progress];
    }else if ([imageLoader loadingState] == SELSelfieImageLoadingStateReady) {
        [progressManger loaded];
    }else if ([imageLoader loadingState] == SELSelfieImageLoadingStateFailed) {
        [contentManger moveToDirection:SELSelfieDirectionExit];
    }else{
    }
}

// finished loading
- (void)finishedLoading{
    [contentManger moveToDirection:SELSelfieDirectionForward];
}

#pragma - SELMovieViewControllerDelegate <NSObject>
- (void)moviePlayerPlaybackStateChanged:(SELMoviePlayerPlaybackState)moviePlayerPlaybackState{
    
    @try {
    
        if ((moviePlayerPlaybackState == SELMoviePlayerPlaybackStatePlaying ||
             moviePlayerPlaybackState == SELMoviePlayerPlaybackStateBuffering) &&
            movieViewController.view.hidden == YES && ([contentManger getCurrentSelfieType] == SELSelfieContentTypeVideo)) {
            activityIndicator.hidden = YES;
            movieViewController.view.alpha = 0.0;
            movieViewController.view.hidden = NO;
            [UIView animateWithDuration:.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                movieViewController.view.alpha = 1.0;
            } completion:^(BOOL finished) {
                if([contentManger getCurrentSelfieType] == SELSelfieContentTypeVideo) {
                    //pictureViewController.view.hidden = YES;
                }
            }];
        }
        
        if ([contentManger getCurrentSelfieType] == SELSelfieContentTypeVideo) {
            if(moviePlayerPlaybackState == SELMoviePlayerPlaybackStateNew){
                
                activityIndicator.alpha = 0.0;
                activityIndicator.hidden = NO;
                [UIView animateWithDuration:.2 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    activityIndicator.alpha = 1.0;
                } completion:^(BOOL finished) {
                }];
            }
        }
        
    
        if ([contentManger getCurrentSelfieType] == SELSelfieContentTypeVideo) {
            switch (moviePlayerPlaybackState) {
                case SELMoviePlayerPlaybackStateNew:
                    NSLog(@"movie state: New");
                    break;
                case SELMoviePlayerPlaybackStatePlaying:
                    NSLog(@"movie state: Playing");
                    break;
                case SELMoviePlayerPlaybackStateBuffering:
                    NSLog(@"movie state: Buffering");
                    break;
                case SELMoviePlayerPlaybackStateFailed:
                    NSLog(@"movie state: Failed");
                    break;
                default:
                    NSLog(@"movie state: default");
                    break;
            }
        }
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

#pragma -SELPictureViewControllerDelegate

#pragma - SELImageLoaderDelegate

- (void) selfieFailedToLoad:(PFObject*)selfie{
    [contentManger selfieFailedToLoad:selfie];
}

#pragma -SELOverlayViewControllerDelegate

- (void) goForward{
    [contentManger moveToDirection:SELSelfieDirectionForward];
}

- (void) goBackward{
    [contentManger moveToDirection:SELSelfieDirectionBackward];
}
- (void) pullDown:(BOOL)isUsernameListVisible{
    
    /**
    if (isUsernameListVisible) {
        [votingOverlayViewController setSelfie:[contentManger getCurrentSelfie]];
        [UIView animateWithDuration:0.4 animations:^{
            pictureViewController.view.frame = CGRectMake(0, pictureViewController.view.frame.size.height - kExposedHeight, pictureViewController.view.frame.size.width, pictureViewController.view.frame.size.height);
        }];
        [UIView animateWithDuration:0.4 animations:^{
            movieViewController.view.frame = CGRectMake(0, movieViewController.view.frame.size.height - kExposedHeight, movieViewController.view.frame.size.width, movieViewController.view.frame.size.height);
        }];
        self.hashtagLabel.hidden = YES;
        votingOverlayViewController.view.alpha = 0.0;
        votingOverlayViewController.view.hidden = NO;
        [UIView animateWithDuration:0.6 delay:0.2 options:UIViewAnimationOptionCurveEaseIn animations:^{
            votingOverlayViewController.view.alpha = 1.0;
        } completion:nil];
    } else{
        votingOverlayViewController.view.hidden = YES;
        [UIView animateWithDuration:0.4 animations:^{
            pictureViewController.view.frame = CGRectMake(0, 0, pictureViewController.view.frame.size.width, pictureViewController.view.frame.size.height);
        }];
        [UIView animateWithDuration:0.4 animations:^{
            movieViewController.view.frame = CGRectMake(0, 0, movieViewController.view.frame.size.width, movieViewController.view.frame.size.height);
        } completion:^(BOOL finished) {
            self.hashtagLabel.hidden = NO;
        }];
    }
 **/
}

#pragma - Exit Button

- (IBAction)exitImage:(id)sender{
    NSLog(@"exit button pressed");
    [contentManger moveToDirection:SELSelfieDirectionExit];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
