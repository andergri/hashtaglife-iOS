//
//  SELReplyViewController.h
//  #life
//
//  Created by Griffin Anderson on 10/12/15.
//  Copyright © 2015 Griffin Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SELColorPicker.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface SELReplyViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property SELColorPicker *color;
@property NSString* hashtag;
+ (ALAssetsLibrary *)defaultAssetsLibrary;
@end
