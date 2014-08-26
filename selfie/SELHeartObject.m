//
//  SELHeartObject.m
//  #life
//
//  Created by Griffin Anderson on 8/20/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import "SELHeartObject.h"

@interface SELHeartObject ()


@property UIImageView *heartImageView;
@property UIButton *heartButton;

@end

@implementation SELHeartObject

@synthesize heartImageView;
@synthesize heartButton;

// Init Heart
- (void) initHeart:(UIView *)view{
    heartButton = [[UIButton alloc] initWithFrame:CGRectMake(view.frame.size.width - 70, -5, 70, 70)];
    UIImage *backImage = [[UIImage imageNamed:@"open-heart"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [backImage setAccessibilityIdentifier:@"open"];
    heartImageView = [[UIImageView alloc] initWithImage:backImage];
    heartImageView.frame = CGRectMake(15, 15, backImage.size.width, backImage.size.height);
    heartImageView.contentMode = UIViewContentModeCenter;
    [heartImageView setTintColor:[UIColor colorWithWhite:1 alpha:1]];
    [heartButton addSubview:heartImageView];
    heartButton.enabled = YES;
    [view addSubview:heartButton];
}

// Hide Heart
- (void) hideHeart{
    heartButton.hidden = YES;
}

// Show Heart
- (void) showHeart{
    heartButton.hidden = NO;
}

// Tap Heart
- (void) tapHeart:(PFObject *) selfie{
    
    NSLog(@"heart");
    
    if ([[heartImageView.image accessibilityIdentifier] isEqualToString:@"open"]) {
        UIImage *backImage = [[UIImage imageNamed:@"full-heart"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [backImage setAccessibilityIdentifier:@"full"];
        heartImageView.image = backImage;
        [heartImageView setTintColor:[UIColor redColor]];
        [heartImageView setTintColor:[UIColor colorWithWhite:1 alpha:1]];
        [self addHeart:YES selfie:selfie];
    }else if([[heartImageView.image accessibilityIdentifier] isEqualToString:@"full"]) {
        UIImage *backImage = [[UIImage imageNamed:@"open-heart"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [backImage setAccessibilityIdentifier:@"open"];
        heartImageView.image = backImage;
        [heartImageView setTintColor:[UIColor colorWithWhite:1 alpha:1]];
        [self addHeart:NO selfie:selfie];
    }else{
        NSLog(@"none");
    }
 
}

// Reset Heart
- (void)resetHeart{
    
    UIImage *backImage = [[UIImage imageNamed:@"open-heart"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [backImage setAccessibilityIdentifier:@"open"];
    heartImageView.image = backImage;
    [heartImageView setTintColor:[UIColor colorWithWhite:1 alpha:1]];

}


// Private Method
- (void)addHeart:(BOOL)increment selfie:(PFObject *) selfie{
    
    @try {
        if (increment) {
            [selfie incrementKey:@"likes"];
        }else{
            //[sel incrementKey:@"likes"];
        }
        [selfie saveEventually];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

@end

