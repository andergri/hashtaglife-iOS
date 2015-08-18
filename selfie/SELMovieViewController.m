//
//  SELMovieViewController.m
//  #life
//
//  Created by Griffin Anderson on 5/27/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import "SELMovieViewController.h"
#import "SELVideoObject.h"

@interface SELMovieViewController (){
    NSMutableArray *videoList;
    NSMutableArray *allList;
    id mTimeObserver;
    SELMoviePlayerPlaybackState _moviePlayerPlaybackState;

}

@property SELMoviePlayerViewController *moviePlayerViewController;
@property UIActivityIndicatorView *activityIndicator;

@end

@implementation SELMovieViewController

@synthesize moviePlayerViewController;
@synthesize activityIndicator;
@synthesize delegate;

#pragma mark -
#pragma mark ===========   Videos Players  =========
#pragma mark -

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.frame = [[UIScreen mainScreen] bounds];
    self.view.hidden = YES;
    
    videoList = [[NSMutableArray alloc] init];
    allList = [[NSMutableArray alloc] init];
    moviePlayerViewController = SELMoviePlayerPlaybackStateNew;
    
    // Video Sub View Controller
    moviePlayerViewController = [[SELMoviePlayerViewController alloc] init];
    moviePlayerViewController.delegate = self;
    moviePlayerViewController.view.frame = CGRectMake(0, 25, self.view.bounds.size.width, self.view.bounds.size.height - 25);
    [self addChildViewController:moviePlayerViewController];
    [self.view addSubview:moviePlayerViewController.view];
    [moviePlayerViewController didMoveToParentViewController:self];
    
    // Top header border
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, moviePlayerViewController.view.frame.size.width, .5f);
    topBorder.backgroundColor = [UIColor colorWithWhite:1.0f alpha:.15f].CGColor;
    topBorder.opacity = 0.0;
    [moviePlayerViewController.view.layer addSublayer:topBorder];
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:moviePlayerViewController.view.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(3.0, 3.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = moviePlayerViewController.view.bounds;
    maskLayer.path = maskPath.CGPath;
    moviePlayerViewController.view.layer.mask = maskLayer;
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.alpha = 1.0;
    activityIndicator.center = CGPointMake(moviePlayerViewController.view.frame.size.width / 2.0, moviePlayerViewController.view.frame.size.height / 2.0);
    activityIndicator.hidesWhenStopped = NO;
    [moviePlayerViewController.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
    activityIndicator.hidden = YES;
}



#pragma mark - Local

- (void) loadVideos:(NSMutableArray*)selfies{
    
    [self mute];
    // Load locally
    [videoList removeAllObjects];
    [allList removeAllObjects];
    if (selfies.count > 0) {
        for (PFObject *selfie in selfies) {
            SELVideoObject* videoObj = [[SELVideoObject alloc] createVideo:selfie];
            [allList addObject:videoObj];
            if (videoObj.isVideoLoaded && videoObj.hasVideo) {
                [videoList addObject:videoObj];
            }
        }
    }
    
    // Load mplayer
   [moviePlayerViewController removeItems];
    moviePlayerViewController.itemsCount = [videoList count];
    for (int i = 0; i < [videoList count]; i++) {
        SELVideoObject* videoObj = [videoList objectAtIndex:i];
        [moviePlayerViewController setupUrl:videoObj.videoURL index:i];
    }
    [self pause];
}

- (void)playAtIndex:(int)index{
    
    // check current index and matched selfie
    [self changeState:SELMoviePlayerPlaybackStateNew];
    SELVideoObject *videoObj = [allList objectAtIndex:index];
    if (videoObj.isVideoLoaded && videoObj.hasVideo) {
        NSUInteger index = [videoList indexOfObject:videoObj];
        
        [moviePlayerViewController playItem:index];
    
        /**NSLog(@"player getCurrentItem %lu index %lu", (unsigned long)[moviePlayerViewController getCurrentItem], (unsigned long)index);
         **/
    }
}
- (void)cancel{
    [moviePlayerViewController removeItems];
}

- (void)pause{
    [moviePlayerViewController pause];
}
- (void)play{
    NSLog(@"hit play");
    [moviePlayerViewController play];
}
- (void)mute{
    [moviePlayerViewController mute];
}

- (SELMoviePlayerPlaybackState) getMoviePlayerPlaybackState{
    return _moviePlayerPlaybackState;
}

#pragma mark -
#pragma mark ===========  Movie Delegate  =========
#pragma mark -

- (void) changeState:(SELMoviePlayerPlaybackState)state{
    
    _moviePlayerPlaybackState = state;
    if ([self.delegate respondsToSelector:@selector(moviePlayerPlaybackStateChanged:)]) {
        [self.delegate moviePlayerPlaybackStateChanged:_moviePlayerPlaybackState];
    }
}
#pragma mark -
#pragma mark ===========   Delegate  =========
#pragma mark -

- (void)SELVideoPlayerCurrentItemPreloaded:(CMTime)time{
    NSLog(@"m SELVideoPlayerCurrentItemPreloaded");
}
- (void)SELVideoPlayerCurrentItemChanged:(AVPlayerItem *)item{
    //NSLog(@"m SELVideoPlayerCurrentItemChanged");
    [self changeState:SELMoviePlayerPlaybackStatePlaying];
}
- (void)SELVideoPlayerRateChanged:(BOOL)isPlaying{
    if (isPlaying) {
    }
}
- (void)SELVideoPlayerDidFailed:(SELVideoPlayerFailed)identifier error:(NSError *)error{
    NSLog(@"m SELVideoPlayerDidFailed");
}
- (void)SELVideoPlayerReadyToPlay:(SELVideoPlayerReadyToPlay)identifier{
    // NSLog(@"identifier %ld", (long) identifier);
        //NSLog(@"m SELVideoPlayerReadyToPlay");
    if (identifier == 3001) {
    //    activityIndicator.hidden = YES;
    }
}
- (void)SELVIdeoPlayerPlayerItemErrorAt:(NSUInteger)index{
    NSLog(@"Error: can't find item at index %lu", (unsigned long)index);
}
- (void)SELVideoPlayerPlayerItemBuffering:(BOOL)buffering{
    if (buffering) {
        activityIndicator.hidden = NO;
        [self changeState:SELMoviePlayerPlaybackStateBuffering];
    }else{
        // ! problem code !//
        if (self.view.hidden == NO) {
            [self play];
        }
        activityIndicator.hidden = YES;
        [self changeState:SELMoviePlayerPlaybackStatePlaying];
    }
}

#pragma mark -
#pragma mark ===========   Additions  =========
#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
