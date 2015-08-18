//
//  SELHeartObject.m
//  #life
//
//  Created by Griffin Anderson on 8/20/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import "SELHeartObject.h"
#import "SELClickableObject.h"

@interface SELHeartObject ()


@property UIImageView *heartImageView;
@property UIButton *heartButton;
@property SELColorPicker *acolor;

@property UIImageView *upvoteImageView;
@property UIImageView *downvoteImageView;
@property UIButton *upvoteButton;
@property UIButton *downvoteButton;
@property UILabel *acountLabel;

@property UIView *backgroundUpvote;
@property UIView *backgroundDownvote;

@property PFObject *vote;

@property SELClickableObject *clickableObject;

@end

@implementation SELHeartObject

@synthesize heartImageView;
@synthesize heartButton;
@synthesize acolor;
@synthesize vote;

@synthesize upvoteImageView;
@synthesize downvoteImageView;
@synthesize upvoteButton;
@synthesize downvoteButton;
@synthesize acountLabel;
@synthesize backgroundUpvote;
@synthesize backgroundDownvote;

@synthesize clickableObject;

// Init Heart
- (void) initHeart:(UIView *)view color:(SELColorPicker *)color{
    
    acolor = color;
    
    /**
    heartButton = [[UIButton alloc] initWithFrame:CGRectMake(view.frame.size.width - 55, view.frame.size.height - 70, 55, 70)];
    heartButton.backgroundColor = [acolor getPrimaryColor];
    UIImage *backImage = [[UIImage imageNamed:@"open-heart"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [backImage setAccessibilityIdentifier:@"open"];
    heartImageView = [[UIImageView alloc] initWithImage:backImage];
    heartImageView.frame = CGRectMake(6.5, 15, backImage.size.width, backImage.size.height);
    heartImageView.contentMode = UIViewContentModeCenter;
    [heartImageView setTintColor:[UIColor colorWithWhite:1 alpha:1]];
    [heartButton addSubview:heartImageView];
    heartButton.enabled = YES;
    heartButton.userInteractionEnabled = NO;
    [view addSubview:heartButton];
    **/
    
    upvoteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, view.frame.size.height - 40, 320, 40)];
    
    
    CAGradientLayer *layer = [CAGradientLayer layer];
    NSArray *colors = [NSArray arrayWithObjects:
                       (id)[UIColor colorWithWhite:0 alpha:.4].CGColor,
                       (id)[UIColor colorWithWhite:0 alpha:.5].CGColor,
                       nil];
    [layer setColors:colors];
    [layer setFrame:upvoteButton.bounds];
    [upvoteButton.layer insertSublayer:layer atIndex:0];
    upvoteButton.clipsToBounds = YES;
    
    // count
    acountLabel = [[UILabel alloc] initWithFrame:CGRectMake(236, 0, 50, 40)];
    acountLabel.textColor = [acolor getPrimaryColor];
    acountLabel.font = [UIFont boldSystemFontOfSize:19];
    acountLabel.backgroundColor = [UIColor yellowColor];
    acountLabel.backgroundColor = [UIColor clearColor];
    acountLabel.textAlignment = NSTextAlignmentCenter;
    acountLabel.text = @"24";
    acountLabel.shadowColor = [UIColor colorWithWhite:0 alpha:.15];
    acountLabel.shadowOffset = CGSizeMake(0,1);
    [upvoteButton addSubview:acountLabel];
    
    
    UIImage *upvoteImage = [[UIImage imageNamed:@"upvote"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [upvoteImage setAccessibilityIdentifier:@"untapped"];
    
    UIImageView *shadowupvoteImageView = [[UIImageView alloc] initWithImage:upvoteImage];
    shadowupvoteImageView.frame = CGRectMake(278, 9, upvoteImage.size.width, upvoteImage.size.height);
    shadowupvoteImageView.contentMode = UIViewContentModeCenter;
    [shadowupvoteImageView setTintColor:[UIColor colorWithWhite:0 alpha:.1]];
    [upvoteButton addSubview:shadowupvoteImageView];
    
    upvoteImageView = [[UIImageView alloc] initWithImage:upvoteImage];
    upvoteImageView.frame = CGRectMake(278, 8, upvoteImage.size.width, upvoteImage.size.height);
    upvoteImageView.contentMode = UIViewContentModeCenter;
    [upvoteImageView setTintColor:[acolor getPrimaryColor]];
    [upvoteButton addSubview:upvoteImageView];
    upvoteButton.enabled = YES;
    upvoteButton.userInteractionEnabled = NO;
    
    [view addSubview:upvoteButton];
    
    
    downvoteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, view.frame.size.height - 40, 320, 40)];
    UIImage *downvoteImage = [[UIImage imageNamed:@"downvote"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [downvoteImage setAccessibilityIdentifier:@"untapped"];
    
    UIImageView * shadowdownvoteImageView = [[UIImageView alloc] initWithImage:downvoteImage];
    shadowdownvoteImageView.frame = CGRectMake(214, 3, downvoteImage.size.width, downvoteImage.size.height);
    shadowdownvoteImageView.contentMode = UIViewContentModeCenter;
    [shadowdownvoteImageView setTintColor:[UIColor colorWithWhite:0 alpha:.1]];
    [downvoteButton addSubview:shadowdownvoteImageView];
    
    downvoteImageView = [[UIImageView alloc] initWithImage:downvoteImage];
    downvoteImageView.frame = CGRectMake(214, 2, downvoteImage.size.width, downvoteImage.size.height);
    downvoteImageView.contentMode = UIViewContentModeCenter;
    [downvoteImageView setTintColor:[acolor getPrimaryColor]];
    [downvoteButton addSubview:downvoteImageView];
    downvoteButton.enabled = YES;
    downvoteButton.userInteractionEnabled = NO;
    [view addSubview:downvoteButton];
    
    /**
    downvoteButton.layer.shadowColor = [UIColor whiteColor].CGColor;
    downvoteButton.layer.shadowRadius = 7.0f;
    downvoteButton.layer.shadowOpacity = 1.0f;
    downvoteButton.layer.shadowOffset = CGSizeZero;
    **/
    clickableObject = [[SELClickableObject alloc] initClickable];
    
    // Background Image
    backgroundUpvote = [[UIView alloc] initWithFrame:CGRectMake(upvoteImageView.frame.origin.x - 35, upvoteImageView.frame.origin.y - 5.0, 70, 33)];
    backgroundUpvote.backgroundColor = [[acolor getColorArray]objectAtIndex:1];
    backgroundUpvote.layer.cornerRadius = 5.0f;
    [upvoteButton insertSubview:backgroundUpvote belowSubview:acountLabel];
    
    backgroundDownvote = [[UIView alloc] initWithFrame:CGRectMake(downvoteImageView.frame.origin.x - 5.0, downvoteImageView.frame.origin.y + 1, 70, 33)];
    backgroundDownvote.backgroundColor = [[acolor getColorArray]objectAtIndex:2];
    backgroundDownvote.layer.cornerRadius = 5.0f;
    [upvoteButton insertSubview:backgroundDownvote belowSubview:acountLabel];
}

// Hide Heart
- (void) hideHeart{
    //heartButton.hidden = YES;
    upvoteButton.hidden = YES;
    downvoteButton.hidden = YES;
}

// Show Heart
- (void) showHeart{
    //heartButton.hidden = NO;
    upvoteButton.hidden = NO;
    downvoteButton.hidden = NO;
}

// Tap Heart
- (void) tapUpvote:(PFObject *) selfie{
    
    acountLabel.textColor = [acolor getPrimaryColor];
    if ([[upvoteImageView.image accessibilityIdentifier] isEqualToString:@"untapped"]) {
        acountLabel.textColor = [UIColor whiteColor];
        [upvoteImageView setTintColor:[UIColor colorWithWhite:1 alpha:1]];
        [upvoteImageView.image setAccessibilityIdentifier:@"tapped"];
        if([[downvoteImageView.image accessibilityIdentifier] isEqualToString:@"tapped"]) {
            [downvoteImageView setTintColor:[acolor getPrimaryColor]];
            [downvoteImageView.image setAccessibilityIdentifier:@"untapped"];
            [self addHeart:YES change:YES selfie:selfie];
            [clickableObject removeVote:[selfie objectId]];
            [clickableObject addPostiveVote:[selfie objectId]];
            backgroundDownvote.hidden = YES;
            backgroundUpvote.hidden = NO;
        }else{
            [self addHeart:YES change:NO selfie:selfie];
            [clickableObject removeVote:[selfie objectId]];
            [clickableObject addPostiveVote:[selfie objectId]];
            backgroundUpvote.hidden = NO;
        }
    }else{
        NSLog(@"none");
        [downvoteImageView setTintColor:[acolor getPrimaryColor]];
        [upvoteImageView setTintColor:[acolor getPrimaryColor]];
        [upvoteImageView.image setAccessibilityIdentifier:@"untapped"];
        [self addHeart:NO change:NO selfie:selfie];
        [clickableObject removeVote:[selfie objectId]];
        backgroundUpvote.hidden = YES;
    }
}

// Tap Heart
- (void) tapDownvote:(PFObject *) selfie{
    
    acountLabel.textColor = [acolor getPrimaryColor];
    if ([[downvoteImageView.image accessibilityIdentifier] isEqualToString:@"untapped"]) {
        acountLabel.textColor = [UIColor whiteColor];
        [downvoteImageView setTintColor:[UIColor colorWithWhite:1 alpha:1]];
        [downvoteImageView.image setAccessibilityIdentifier:@"tapped"];
        if([[upvoteImageView.image accessibilityIdentifier] isEqualToString:@"tapped"]) {
            [upvoteImageView setTintColor:[acolor getPrimaryColor]];
            [upvoteImageView.image setAccessibilityIdentifier:@"untapped"];
            [self addHeart:NO change:YES selfie:selfie];
            [clickableObject removeVote:[selfie objectId]];
            [clickableObject addNegativeVote:[selfie objectId]];
            backgroundDownvote.hidden = NO;
            backgroundUpvote.hidden = YES;
        }else{
            [self addHeart:NO change:NO selfie:selfie];
            [clickableObject removeVote:[selfie objectId]];
            [clickableObject addNegativeVote:[selfie objectId]];
            backgroundDownvote.hidden = NO;
        }
    }else{
        NSLog(@"none");
        [upvoteImageView setTintColor:[acolor getPrimaryColor]];
        [downvoteImageView setTintColor:[acolor getPrimaryColor]];
        [downvoteImageView.image setAccessibilityIdentifier:@"untapped"];
        [self addHeart:YES change:NO selfie:selfie];
        [clickableObject removeVote:[selfie objectId]];
        backgroundDownvote.hidden = YES;
    }
}

/**
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
**/
 
// Reset Heart
- (void)resetHeart:(PFObject *) selfie{
    /**
    UIImage *backImage = [[UIImage imageNamed:@"open-heart"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [backImage setAccessibilityIdentifier:@"open"];
    heartImageView.image = backImage;
    [heartImageView setTintColor:[UIColor colorWithWhite:1 alpha:1]];
    **/
    
    backgroundDownvote.hidden = YES;
    backgroundUpvote.hidden = YES;
    vote = nil;
    
    UIImage *upvoteImage = [[UIImage imageNamed:@"upvote"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [upvoteImage setAccessibilityIdentifier:@"untapped"];
    upvoteImageView.image = upvoteImage;
    [upvoteImageView setTintColor:[acolor getPrimaryColor]];
    
    
    UIImage *downvoteImage = [[UIImage imageNamed:@"downvote"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [downvoteImage setAccessibilityIdentifier:@"untapped"];
    downvoteImageView.image = downvoteImage;
    [downvoteImageView setTintColor:[acolor getPrimaryColor]];
    
    acountLabel.textColor = [acolor getPrimaryColor];
    
    if (selfie && ![clickableObject canVote:[selfie objectId]]) {
        if ([clickableObject isPostiveVote:[selfie objectId]]) {
            [upvoteImageView setTintColor:[UIColor colorWithWhite:1 alpha:1]];
            [upvoteImage setAccessibilityIdentifier:@"tapped"];
            backgroundUpvote.hidden = NO;
        }else{
            [downvoteImageView setTintColor:[UIColor colorWithWhite:1 alpha:1]];
            [downvoteImage setAccessibilityIdentifier:@"tapped"];
            backgroundDownvote.hidden = NO;
        }
    }
     
}


// Private Method
- (void)addHeart:(BOOL)increment change:(BOOL)change selfie:(PFObject *) selfie{
    
    @try {
        if (increment) {
            [selfie incrementKey:@"likes"];
            if (change) {
                [selfie incrementKey:@"likes"];
            }
        }else{
            NSInteger like = [[selfie objectForKey:@"likes"] intValue] - 1;
            [selfie setObject:@(like) forKey:@"likes"];
            if (change) {
                NSInteger like = [[selfie objectForKey:@"likes"] intValue] - 1;
                [selfie setObject:@(like) forKey:@"likes"];
            }
            //[sel incrementKey:@"likes"];
        }
        [selfie saveInBackground];
        [self setCount:selfie];
    }
    @catch (NSException *exception) {
    }
    @finally {
        [self saveVoteData:increment change:(BOOL)change selfie:selfie];
    }
}

- (void) saveVoteData:(BOOL)reaction change:(BOOL)change selfie:(PFObject*)selfie{

    if (vote != nil) {
        if (change)
            [self updateVote:vote reaction:reaction selfie:selfie];
        else
            [self remvoeVote:vote];
        return;
    }
    PFQuery *voteItem = [PFQuery queryWithClassName:@"Vote"];
    [voteItem whereKey:@"voter" equalTo:[PFUser currentUser]];
    [voteItem whereKey:@"selfie" equalTo:selfie];
    [voteItem findObjectsInBackgroundWithBlock:^(NSArray *votesResults, NSError *error) {
        if (!error) {
            switch (votesResults.count) {
                case 0:
                    vote = [PFObject objectWithClassName:@"Vote"];
                    [self updateVote:vote reaction:reaction selfie:selfie];
                    break;
                case 1:
                    vote = [votesResults objectAtIndex:0];
                    if (change)
                        [self updateVote:vote reaction:reaction selfie:selfie];
                    else if([[vote objectForKey:@"voterReaction"] boolValue] == reaction)
                        break;
                    else
                        [self remvoeVote:vote];
                    break;
                default:
                     NSLog(@"Oh shit double votes");
                    break;
            }
        }else{
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void) remvoeVote:(PFObject *)avote{
    vote = nil;
    [avote deleteInBackground];
}

- (void) updateVote:(PFObject *)avote reaction:(BOOL)reaction selfie:(PFObject*)selfie{
    @try {
        avote[@"voter"] = [PFUser currentUser];
        avote[@"voterName"] = [[PFUser currentUser] objectForKey:@"username"];
        avote[@"voterReaction"] = @(reaction);
        avote[@"selfie"] = selfie;
        avote[@"poster"] = [selfie objectForKey:@"from"];
        avote[@"notifyAttempted"] = @NO;
        [avote saveInBackground];
    }
    @catch (NSException *exception) {
        NSLog(@"Error: %@ %@", exception, [exception userInfo]);
    }
    @finally {
        
    }
}

- (void) setCount:(PFObject *) selfie{
    NSNumber *count = [selfie objectForKey:@"likes"];
    acountLabel.text = [count stringValue];
}

- (BOOL) isHidden{
   return upvoteButton.hidden;
}

@end

