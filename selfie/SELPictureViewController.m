//
//  SELPictureViewController.m
//  #life
//
//  Created by Griffin Anderson on 5/26/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import "SELPictureViewController.h"

@interface SELPictureViewController () <UIGestureRecognizerDelegate>


@end

@implementation SELPictureViewController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = [[UIScreen mainScreen] bounds];
    self.imageView.frame = CGRectMake(0, 25, self.view.frame.size.width, self.view.frame.size.height-25);
    
    // Top header border
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.imageView.frame.size.width, .5f);
    topBorder.backgroundColor = [UIColor colorWithWhite:1.0f alpha:.15f].CGColor;
    topBorder.opacity = 0.0;
    [self.imageView.layer addSublayer:topBorder];
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.imageView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(3.0, 3.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.imageView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.imageView.layer.mask = maskLayer;
    
    [self.imageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [self.imageView setClipsToBounds:YES];
    [self.imageView setAutoresizesSubviews:YES];
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.view.frame = [[UIScreen mainScreen] bounds];
    self.imageView.frame = CGRectMake(0, 25, self.view.frame.size.width, self.view.frame.size.height-25);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setImage:(UIImage*)image{
    self.imageView.image = image;
    [self.imageView setNeedsDisplay];
    [self.imageView setFrame:CGRectMake(0, 25.0, self.imageView.frame.size.width, self.imageView.frame.size.height)];

   
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
