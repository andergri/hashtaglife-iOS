//
//  SELRandomObject.m
//  #life
//
//  Created by Griffin Anderson on 8/20/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import "SELRandomObject.h"

@implementation SELRandomObject

- (void) initMainView:(UIView *)headerView text:(UITextField *)text exit:(UIButton *)exit color:(SELColorPicker *)color{

    // Top header border
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, headerView.frame.size.width, 1.0f);
    topBorder.backgroundColor = [UIColor colorWithWhite:1.0f alpha:.15f].CGColor;
    [headerView.layer addSublayer:topBorder];
    headerView.backgroundColor = [color getPrimaryColor];
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:headerView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(4.0, 4.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = headerView.bounds;
    maskLayer.path = maskPath.CGPath;
    headerView.layer.mask = maskLayer;
    
    //Textfield Styling
    UILabel *headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 44)];
    headingLabel.text = @"#";
    headingLabel.font = [UIFont systemFontOfSize:29];
    headingLabel.textColor = [UIColor whiteColor];
    headingLabel.backgroundColor = [UIColor clearColor];
    headingLabel.textAlignment = NSTextAlignmentCenter;
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, 44)];
    [paddingView addSubview:headingLabel];
    text.leftView = paddingView;
    text.leftViewMode = UITextFieldViewModeAlways;
    text.layer.masksToBounds=YES;
    text.bounds = CGRectInset(text.frame, -22.0f, 0.0f);

    //Image view exit
    UIImage *backImage = [[UIImage imageNamed:@"exit"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *backImageView = [[UIImageView alloc] initWithImage:backImage];
    backImageView.frame = CGRectMake(2, 2, backImage.size.width, backImage.size.height);
    backImageView.contentMode = UIViewContentModeCenter;
    [backImageView setTintColor:[UIColor whiteColor]];
    [exit addSubview:backImageView];
    
}

@end
