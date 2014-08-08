//
//  SELPostViewController.h
//  selfie
//
//  Created by Griffin Anderson on 7/19/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SELColorPicker.h"

@protocol SELPostViewControllerDelegate;

@interface SELPostViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate>

@property UIImage *image;
@property SELColorPicker *color;
@property NSMutableArray *hashtags;
- (void) addColor:(SELColorPicker *)acolor;

@property (nonatomic, weak) id <SELPostViewControllerDelegate> delegate;
@end

@protocol SELPostViewControllerDelegate <NSObject>
@optional

- (void) openCamera;

@end
