//
//  SELBarViewController.m
//  #life
//
//  Created by Griffin Anderson on 3/22/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import "SELBarViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>


@interface SELBarViewController ()

@property UIButton *cameraButton;
@property UIButton *rollButton;
@property UIButton *locationButton;
@property UIButton *listButton;
@property UIButton *exitButton;
@property UIButton *gameButton;
@property UIView *footer;

@end

@implementation SELBarViewController

@synthesize color;
@synthesize delegate;

@synthesize cameraButton;
@synthesize rollButton;
@synthesize locationButton;
@synthesize listButton;
@synthesize exitButton;
@synthesize gameButton;
@synthesize footer;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark Fade
- (void) fadeBar:(BOOL)fade{
        if (fade) {
            self.cameraButton.alpha = 0.0;
            self.rollButton.alpha = 0.0;
            self.locationButton.alpha = 0.0;
            self.listButton.alpha = 0.0;
            self.gameButton.alpha = 0.0;
            self.footer.alpha = 0.0;
            [UIView animateWithDuration:0.5f animations:^{
                self.cameraButton.alpha = 1.0;
                self.rollButton.alpha = 1.0;
                self.locationButton.alpha = 1.0;
                self.listButton.alpha = 1.0;
                self.gameButton.alpha = 1.0;
                self.footer.alpha = 1.0;
            } completion:nil];
        }else{
            self.cameraButton.alpha = 1.0;
            self.rollButton.alpha = 1.0;
            self.locationButton.alpha = 1.0;
            self.listButton.alpha = 1.0;
            self.gameButton.alpha = 1.0;
            self.footer.alpha = 1.0;
            [UIView animateWithDuration:0.1f animations:^{
                self.cameraButton.alpha = 0.0;
                self.rollButton.alpha = 0.0;
                self.locationButton.alpha = 0.0;
                self.listButton.alpha = 0.0;
                self.gameButton.alpha = 0.0;
                self.footer.alpha = 0.0;
            } completion:nil];
            
        }
}

-(void)resetLikes{
    for (UIView* sub in gameButton.subviews) {
        [sub removeFromSuperview];
    }
    [self getNumberUserLikes:[self addForeGround:gameButton padding:6.0]];
}

#pragma - mark Bars

- (void) createBarFooter:(UIView *)view disapear:(BOOL)dispear{
    if (dispear) {
        footer = view;
    }
    view.backgroundColor = [color getPrimaryColor];
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, view.frame.size.width, 1.0f);
    topBorder.backgroundColor = [UIColor colorWithWhite:1.0f alpha:.15f].CGColor;
    [view.layer addSublayer:topBorder];
}
- (void) createBarOptionPrimary:(UIView *)view{
    [self createProfile:view placement:CGRectMake(21, view.frame.size.height - 70, 64, 64)];
    [self createLargeCamera:view placement:CGRectMake((view.frame.size.width / 2.0) - (88.0 / 2.0), view.frame.size.height - 88, 88, 88)];
    [self createRoll:view placement:CGRectMake(235, view.frame.size.height - 70, 64, 64) background:YES];
}
- (void) createBarOptionSecondary:(UIView *)view{
    //[self createGame:view placement:CGRectMake(21, view.frame.size.height - 70, 64, 64)];
    [self createList:view placement:CGRectMake(235, view.frame.size.height - 70, 64, 64)background:YES];
}
- (void) createBarOptionCamera:(UIView *)view{
    [self createExit:view placement:CGRectMake(21, view.frame.size.height - 70, 62, 62)background:NO];
    //[self createRoll:view placement:CGRectMake(235, view.frame.size.height - 70, 64, 64) background:NO];
}
- (void) createCameraButton:(UIView *)view{
    [self createLargeCamera:view placement:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
}

#pragma - mark Buttons

// Button Camera
- (void) createLargeCamera:(UIView *)view placement:(CGRect)placement{
    
    cameraButton = [[UIButton alloc] initWithFrame:placement];
    [self addBackground:cameraButton placement:placement];
    [self addForeGround:cameraButton padding:6];
    [self addGraphic:[UIImage imageNamed:@"camera"] button:cameraButton inset:CGSizeMake(24, 24) scale:0];
    [cameraButton addTarget:self action:@selector(tappedLargeCamera) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:cameraButton];
}

// Button Camera
- (void) createCamera:(UIView *)view placement:(CGRect)placement{
    
    cameraButton = [[UIButton alloc] initWithFrame:placement];
    [self addBackground:cameraButton placement:placement];
    [self addForeGround:cameraButton padding:5.0];
    [self addGraphic:[UIImage imageNamed:@"camera"] button:cameraButton inset:CGSizeMake(12.5, 11) scale:2.7];
    [cameraButton addTarget:self action:@selector(tappedCamera) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:cameraButton];
}

// Button Roll
- (void) createRoll:(UIView *)view placement:(CGRect)placement background:(BOOL)background{
    
    rollButton = [[UIButton alloc] initWithFrame:placement];
    if (background)
        [self addBackground:rollButton placement:placement];
    [self addForeGround:rollButton padding:5.0];
    [self getLastImage:[self addGraphic:[UIImage imageNamed:@"image"] button:rollButton inset:CGSizeMake(18, 18) scale:0]];
    [rollButton addTarget:self action:@selector(tappedRoll) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:rollButton];
}

// Button Location
- (void) createLocation:(UIView *)view placement:(CGRect)placement{
    
    locationButton = [[UIButton alloc] initWithFrame:placement];
    [self addBackground:locationButton placement:placement];
    [self addForeGround:locationButton padding:5.0];
    [self addGraphic:[UIImage imageNamed:@"location"] button:locationButton inset:CGSizeMake(16.5, 17) scale:0];
    [locationButton addTarget:self action:@selector(tappedLocation) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:locationButton];
}

// Button Global
- (void) createProfile:(UIView *)view placement:(CGRect)placement{
    
    locationButton = [[UIButton alloc] initWithFrame:placement];
    [self addBackground:locationButton placement:placement];
    [self addForeGround:locationButton padding:5.0];
    [self addGraphic:[UIImage imageNamed:@"profile"] button:locationButton inset:CGSizeMake(18, 17) scale:1.8];
    [locationButton addTarget:self action:@selector(tappedLocation) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:locationButton];
}

// Button List
- (void) createList:(UIView *)view placement:(CGRect)placement background:(BOOL)background{
    
    listButton = [[UIButton alloc] initWithFrame:placement];
    if (background)
        [self addBackground:listButton placement:placement];
    [self addForeGround:listButton padding:5.0];
    [self addGraphic:[UIImage imageNamed:@"list"] button:listButton inset:CGSizeMake(19.5, 19.5) scale:2.1];
    [listButton addTarget:self action:@selector(tappedList) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:listButton];
}

// Button List
- (void) createExit:(UIView *)view placement:(CGRect)placement background:(BOOL)background{
    
    exitButton = [[UIButton alloc] initWithFrame:placement];
    if (background)
        [self addBackground:exitButton placement:placement];
    [self addForeGround:exitButton padding:5.0];
    [self addGraphic:[UIImage imageNamed:@"exit"] button:exitButton inset:CGSizeMake(15, 15) scale:2.0];
    [exitButton addTarget:self action:@selector(tappedExit) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:exitButton];
}

// Button Game
- (void) createGame:(UIView *)view placement:(CGRect)placement{
    
    gameButton = [[UIButton alloc] initWithFrame:placement];
    [self addBackground:gameButton placement:placement];
    [self getNumberUserLikes:[self addForeGround:gameButton padding:5.0]];
    [gameButton addTarget:self action:@selector(tappedGame) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:gameButton];
}
#pragma - buttonTapped

- (void) tappedLargeCamera{
    [self.delegate cameraClicked];
}
- (void) tappedCamera{
    [self.delegate cameraClicked];
}
- (void) tappedRoll{
    [self.delegate rollClicked];
}
- (void) tappedLocation{
    [self.delegate switchToSecondaryClicked];
}
- (void) tappedList{
    [self.delegate switchToPrimaryClicked];
}
- (void) tappedGame{
    [self.delegate gameClicked];
}
- (void) tappedExit{
    [self.delegate exitClicked];
}

#pragma - mark helper methods

// Add BACKGROUND
- (void) addBackground:(UIButton*)button placement:(CGRect)placement{
    button.layer.cornerRadius = roundf(button.frame.size.width/2.0);
    button.backgroundColor = [color getPrimaryColor];
}


// Add FOREGROUND
- (UIView *) addForeGround:(UIButton*)button padding:(float)padding{
    UIView *buttonView = [[UIView alloc] init];
    buttonView.frame = CGRectMake(padding, padding, button.frame.size.width - (padding * 2.0), button.frame.size.height - (padding * 2.0));
    buttonView.layer.cornerRadius = roundf(buttonView.frame.size.width/2.0);
    buttonView.backgroundColor = [UIColor whiteColor];
    buttonView.userInteractionEnabled = NO;
    buttonView.exclusiveTouch = NO;
    [button addSubview:buttonView];
    return buttonView;
}

// Add IMAGE
- (UIImageView*) addGraphic:(UIImage*)graphic button:(UIButton*)button inset:(CGSize)inset scale:(float)scale{
    UIImage * chooseImage = [graphic imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *chooseImageView = [[UIImageView alloc] initWithImage:chooseImage];
    chooseImageView.frame = CGRectMake(inset.width, inset.height, chooseImage.size.width, chooseImage.size.height);
    chooseImageView.contentMode = UIViewContentModeCenter;
    chooseImageView.userInteractionEnabled = NO;
    chooseImageView.exclusiveTouch = NO;
    [chooseImageView setTintColor:[UIColor whiteColor]];
    [chooseImageView setTintColor:[color getPrimaryColor]];
    if (scale != 0.0)
        chooseImageView.contentScaleFactor = scale;
    [button addSubview:chooseImageView];
    return chooseImageView;
}

#pragma - mark extra methods

// set users image
- (void) getLastImage:(UIImageView *)imageView{
    
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status != ALAuthorizationStatusAuthorized) {
    }else{
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                     usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                         if (nil != group) {
                                             // be sure to filter the group so you only get photos
                                             [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                                             
                                             
                                             [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:group.numberOfAssets - 1]
                                                                     options:0
                                                                  usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                                                      if (nil != result) {
                                                                          ALAssetRepresentation *repr = [result defaultRepresentation];
                                                                          // this is the most recent saved photo
                                                                          UIImage *img = [UIImage imageWithCGImage:[repr fullResolutionImage]];
                                                                          // we only need the first (most recent) photo -- stop the enumeration
                                                                          *stop = YES;
                                                                          [self setImageViewForImage:img chooseImageView:imageView];
                                                                          
                                                                      }
                                                                  }];
                                         }
                                         
                                         *stop = NO;
                                     } failureBlock:^(NSError *error) {
                                         NSLog(@"error: %@", error);
                                     }];
    }
    
}

- (void) setImageViewForImage:(UIImage *) img chooseImageView:(UIImageView *)chooseImageView{
    
    chooseImageView.image = img;
    chooseImageView.contentMode = UIViewContentModeScaleAspectFill;
    chooseImageView.clipsToBounds = YES;
    chooseImageView.frame = CGRectMake(7, 7, 50, 50);
    chooseImageView.layer.cornerRadius = roundf(chooseImageView.frame.size.width/2.0);
    
}

// set user likes
- (void) getNumberUserLikes:(UIView*)view{
    
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
                [self showLikeCount:acount view:view];
            } else {
                // The request failed
            }
        }];
        
    }else{
        [self showLikeCount:0 view:view];
    }
}

//private method
- (void) showLikeCount:(int)count view:(UIView*)view{
    
    UILabel *likes = [[UILabel alloc] initWithFrame:CGRectMake(7.8, 7, 50, 50)];
    likes.layer.cornerRadius = roundf(likes.frame.size.width/2.0);
    likes.layer.masksToBounds = YES;
    likes.text = [NSString stringWithFormat:@"%d", count];
    likes.textColor = [color getPrimaryColor];
    likes.font = [UIFont boldSystemFontOfSize:20];
    likes.textAlignment = NSTextAlignmentCenter;
    
    for (UIView* sub in view.subviews) {
        [sub removeFromSuperview];
    }
    
    [gameButton addSubview:likes];
    gameButton.clearsContextBeforeDrawing = YES;
}

@end
