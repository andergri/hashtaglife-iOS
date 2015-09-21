//
//  SELPostViewController.h
//  selfie
//
//  Created by Griffin Anderson on 7/19/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SELColorPicker.h"
#import "SELSuggestedTableViewController.h"
#import "PBJVideoPlayerController.h"

@protocol SELPostViewControllerDelegate;

@interface SELPostViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate,  SELSuggestedViewControllerDelegate, PBJVideoPlayerControllerDelegate>

@property (nonatomic, assign) UIImage *image;
@property NSString *videoURL;
@property SELColorPicker *color;
@property NSMutableArray *hashtags;
@property BOOL clickable;
- (void) addColor:(SELColorPicker *)acolor;
- (void) showPost;
- (void) showVideo;
@property (nonatomic, weak) id <SELPostViewControllerDelegate> delegate;
@end

@protocol SELPostViewControllerDelegate <NSObject>
@optional
- (void) didCancelPost;
@end
