//
//  SELBarViewController.h
//  #life
//
//  Created by Griffin Anderson on 3/22/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SELColorPicker.h"

@protocol SELBarViewControllerDelegate;

@interface SELBarViewController : UIViewController

@property SELColorPicker *color;
- (void) createBarFooter:(UIView *)view  disapear:(BOOL)dispear;
- (void) createBarOptionPrimary:(UIView *)view;
- (void) createBarOptionSecondary:(UIView *)view;
- (void) createBarOptionCamera:(UIView *)view;
- (void) createCameraButton:(UIView *)view;
- (void) fadeBar:(BOOL)fade;
- (void) resetLikes;
@property (nonatomic, weak) id <SELBarViewControllerDelegate> delegate;

@end

@protocol SELBarViewControllerDelegate <NSObject>
@required
- (void) cameraClicked;
- (void) rollClicked;
- (void) gameClicked;
- (void) switchToPrimaryClicked;
- (void) switchToSecondaryClicked;
- (void) exitClicked;
@optional
@end