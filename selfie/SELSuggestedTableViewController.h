//
//  SELSuggestedTableViewController.h
//  #life
//
//  Created by Griffin Anderson on 4/3/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SELColorPicker.h"

@protocol SELSuggestedViewControllerDelegate;

@interface SELSuggestedTableViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

- (NSMutableArray *) getAvaiableHashtags:(NSMutableArray *)listedHashatags;
@property (nonatomic, weak) id <SELSuggestedViewControllerDelegate> delegate;
@property SELColorPicker *color;
@end

@protocol SELSuggestedViewControllerDelegate <NSObject>
@optional

- (void) addHashtag:(NSString *)hashtag;

@end