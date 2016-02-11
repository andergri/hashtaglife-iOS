//
//  SELPictureViewController.h
//  #life
//
//  Created by Griffin Anderson on 5/26/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SELPictureViewControllerDelegate <NSObject>

@end

@interface SELPictureViewController : UIViewController

@property (nonatomic) id<SELPictureViewControllerDelegate> delegate;
- (void) setImage:(UIImage*)image;
- (UIImage *) getImage;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end
