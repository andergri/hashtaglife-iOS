//
//  SELUserLikesObject.m
//  #life
//
//  Created by Griffin Anderson on 8/20/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import "SELUserLikesObject.h"

@interface SELUserLikesObject ()

@property SELColorPicker * acolor;

@end

@implementation SELUserLikesObject

@synthesize likeContainer;
@synthesize acolor;

- (void) initUserLikes:(UIView *)view below:(UIView *)belowView color:(SELColorPicker *)color{
    likeContainer = [[UIView alloc] initWithFrame:CGRectMake(250, view.frame.size.height - 70, 54, 54)];
    likeContainer.layer.cornerRadius = roundf(likeContainer.frame.size.width/2.0);
    likeContainer.layer.masksToBounds = YES;
    likeContainer.backgroundColor = [color getPrimaryColor];
    likeContainer.layer.borderWidth = 1.2;
    likeContainer.layer.borderColor = [UIColor whiteColor].CGColor;
    [view addSubview:likeContainer];
    [view insertSubview:likeContainer belowSubview:belowView];
    acolor = color;
 
}

- (void) getNumberUserLikes{
    
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
            [self showLikeCount:acount];
        } else {
            // The request failed
        }
    }];
        
    }else{
        [self showLikeCount:0];
    }
}

//private method
- (void) showLikeCount:(int) count{
    
    UILabel *likes = [[UILabel alloc] initWithFrame:CGRectMake(-4, -5, 50, 50)];
    likes.layer.cornerRadius = roundf(likes.frame.size.width/2.0);
    likes.layer.masksToBounds = YES;
    likes.text = [NSString stringWithFormat:@"%d", count];
    likes.textColor = [acolor getPrimaryColor];
    likes.font = [UIFont systemFontOfSize:15];
    likes.textAlignment = NSTextAlignmentCenter;
    
    UIImage *likeImage = [[UIImage imageNamed:@"full-heart"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *likeImageView = [[UIImageView alloc] initWithImage:likeImage];
    likeImageView.frame = CGRectMake(6, 9, likeImage.size.width, likeImage.size.height);
    likeImageView.contentMode = UIViewContentModeCenter;
    [likeImageView setTintColor:[UIColor whiteColor]];
    [likeImageView addSubview:likes];
    [likeContainer addSubview:likeImageView];
    likeContainer.clearsContextBeforeDrawing = YES;
}

@end
