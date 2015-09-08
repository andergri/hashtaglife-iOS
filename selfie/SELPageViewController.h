//
//  SELPageViewController.h
//  #life
//
//  Created by Griffin Anderson on 3/21/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SELColorPicker.h"

#import "SELOnStartViewController.h"
#import "SELBarViewController.h"
#import "SELSelifeViewController.h"
#import "SELMainViewController.h"
#import "SELSecondaryViewController.h"
#import "SELGameViewController.h"
#import "SELCaptureViewController.h"
#import "SELLocationViewController.h"
#import "SELPremissionViewController.h"
#import "SELRollViewController.h"

@interface SELPageViewController : UIPageViewController <UIPageViewControllerDataSource, SELBarViewControllerDelegate>

@property SELColorPicker *color;
- (void) setFooterBar:(UIView *)view disapear:(BOOL)dispear;
- (void) setPrimaryBar:(UIView *)view;
- (void) setSeondaryBar:(UIView *)view;
- (void) setCameraBar:(UIView *)view;
- (void) setCamera:(UIView *)view;
- (void) fadeBar:(BOOL)fade;
- (void) showSelfies:(NSUInteger)type hashtag:(NSString *)hashtag color:(UIColor*)color global:(BOOL)global objectId:(NSString*)objectId;
- (void) changeLocation;
- (void) updateLocation;
- (void) lockSideSwipe:(BOOL)lock;

@end
