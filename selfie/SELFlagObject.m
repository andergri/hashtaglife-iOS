//
//  SELFlagObject.m
//  #life
//
//  Created by Griffin Anderson on 8/20/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import "SELFlagObject.h"

@interface SELFlagObject ()

@property UIImageView *flagImageView;
@property UIButton *flagButton;

@end

@implementation SELFlagObject

@synthesize flagImageView;
@synthesize flagButton;

// Init Flag
- (void) initFlag:(UIView *)view{

    flagButton = [[UIButton alloc] initWithFrame:CGRectMake(2, view.frame.size.height - 42, 95, 70)];
    
    UILabel *flagLabel = [[UILabel alloc] initWithFrame:CGRectMake(37, -12, 65, 70)];
    flagLabel.text = @"Report";
    flagLabel.textColor = [UIColor whiteColor];
    flagLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:18.0];
    
    UIImage *flagImage = [[UIImage imageNamed:@"open-flag"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [flagImage setAccessibilityIdentifier:@"open-flag"];
    flagImageView = [[UIImageView alloc] initWithImage:flagImage];
    flagImageView.frame = CGRectMake(7, 10, flagImage.size.width, flagImage.size.height);
    flagImageView.contentMode = UIViewContentModeCenter;
    [flagImageView setTintColor:[UIColor colorWithWhite:1 alpha:1]];
    
    [flagButton addSubview:flagImageView];
    [flagButton addSubview:flagLabel];
    flagButton.enabled = YES;
    [view addSubview:flagButton];
}

// Hide Flag
- (void) hideFlag{
    flagButton.hidden = YES;
}

// Show Flag
- (void) showFlag{
    flagButton.hidden = NO;
}

// Tap Flag
- (void) tapFlag:(PFObject *) selfie{

    NSLog(@"Flag");
    
    if ([[flagImageView.image accessibilityIdentifier] isEqualToString:@"open-flag"]) {
        UIImage *backImage = [[UIImage imageNamed:@"full-flag"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [backImage setAccessibilityIdentifier:@"full-flag"];
        flagImageView.image = backImage;
        [flagImageView setTintColor:[UIColor redColor]];
        [flagImageView setTintColor:[UIColor colorWithWhite:1 alpha:1]];
        [self addFlag:YES selfie:selfie];
    }else if([[flagImageView.image accessibilityIdentifier] isEqualToString:@"full-flag"]) {
        UIImage *backImage = [[UIImage imageNamed:@"open-flag"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [backImage setAccessibilityIdentifier:@"open-flag"];
        flagImageView.image = backImage;
        [flagImageView setTintColor:[UIColor colorWithWhite:1 alpha:1]];
        [self addFlag:NO selfie:selfie];
    }else{
        NSLog(@"none");
    }
}

// Reset Flag
- (void)resetFlag{
    
    UIImage *backImage = [[UIImage imageNamed:@"open-flag"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [backImage setAccessibilityIdentifier:@"open-flag"];
    flagImageView.image = backImage;
    [flagImageView setTintColor:[UIColor colorWithWhite:1 alpha:1]];
}


// Private Method
- (void)addFlag:(BOOL)increment selfie:(PFObject *) selfie{
    
    @try {
        if (increment) {
            [selfie incrementKey:@"flags"];
        }else{
            //[sel incrementKey:@"flags"];
        }
        [selfie saveEventually];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

@end
