//
//  SELLoadSelfiesObject.m
//  #life
//
//  Created by Griffin Anderson on 8/20/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import "SELLoadSelfiesObject.h"
#import "SELHashtagTableViewController.h"


@interface SELLoadSelfiesObject ()

@property UIView* apopView;
@property UIImageView* aimageView;
@property SELFlagObject * aflag;
@property SELHeartObject * aheart;
@property SELImageCountObject* aimageCount;
@property UITapGestureRecognizer *atgr;
@property UITapGestureRecognizer *aalertTgr;
@property UIViewController *avc;
@property UILabel *helpText;

@end

@implementation SELLoadSelfiesObject

@synthesize aselfies;
@synthesize aselfiesImages;
@synthesize selfiesCounter;
@synthesize apopView;
@synthesize aflag;
@synthesize aheart;
@synthesize aimageView;
@synthesize aimageCount;
@synthesize atgr;
@synthesize aalertTgr;
@synthesize avc;
@synthesize helpText;

// init
- (void) initDefault:(UIView*)popView imageView:(UIImageView*)imageView flag:(SELFlagObject *)flag heart:(SELHeartObject *)heart imagCount:(SELImageCountObject *)imageCount tap:(UITapGestureRecognizer *)tgr alertTap:(UITapGestureRecognizer *)alertTgr vc:(UIViewController *)vc{
    
    aselfies = [[NSMutableArray alloc] init];
    aselfiesImages = [[NSMutableArray alloc] init];
    selfiesCounter = 0;
    
    apopView = popView;
    aflag = flag;
    aheart = heart;
    aimageView = imageView;
    aimageCount = imageCount;
    atgr = tgr;
    aalertTgr = alertTgr;
    avc = vc;
    helpText = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.frame.size.height - 180, imageView.frame.size.width, 60)];
    helpText.text = @"Tap to Browse";
    helpText.alpha = 0.0;
    helpText.textColor = [UIColor whiteColor];
    helpText.font = [UIFont fontWithName:@"Helvetica Neue" size:32.0];
    helpText.textAlignment = NSTextAlignmentCenter;
    helpText.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
    [imageView addSubview:helpText];
}

// show image page
- (void) showPopup{
    
    aimageView.image = nil;
    [aheart resetHeart];
    [self hideControls];
    apopView.hidden = NO;
    selfiesCounter = 0;
    atgr.enabled = YES;
    aalertTgr.enabled = NO;
    for (UIViewController* vc in avc.childViewControllers) {
        if ([vc isKindOfClass:[SELHashtagTableViewController class]]) {
            ((SELHashtagTableViewController *) vc).tableView.scrollEnabled = NO;
        }
    }

}
// hide image page
- (void) hidePopup{

    apopView.hidden = YES;
    [self hideControls];
    atgr.enabled = NO;
    aalertTgr.enabled = YES;
    for (UIViewController* vc in avc.childViewControllers) {
        if ([vc isKindOfClass:[SELHashtagTableViewController class]]) {
            ((SELHashtagTableViewController *) vc).tableView.scrollEnabled = YES;
        }
    }
}

// tap flag
- (void) tapFlag{
    [aflag tapFlag:[aselfies objectAtIndex:(selfiesCounter - 1)]];
}
// tap Heart
- (void) tapHeart{
    [aheart tapHeart:[aselfies objectAtIndex:(selfiesCounter - 1)]];
}
// load next img
- (void) loadNextImage {
    
    @try {
        
        NSLog(@"lni %ld %lu", (long)selfiesCounter, (unsigned long)aselfiesImages.count);
        
        if (selfiesCounter < aselfiesImages.count) {
            
            [aflag resetFlag];
            [aheart resetHeart];
            [aimageCount countImageTally:[aselfies objectAtIndex:selfiesCounter]];
            PFUser *user = [PFUser currentUser];
            if ([user.objectId isEqualToString:(((PFUser *) [aselfies objectAtIndex:selfiesCounter][@"from"]).objectId)]) {
                [self hideControls];
                [aimageCount showTally];
            }else{
                [self showControls];
            }
            
            [self addVisit];
            UIImage * image = [aselfiesImages objectAtIndex:selfiesCounter];
            aimageView.image = image;
            selfiesCounter++;
            
        }else{
            [self hidePopup];
        }
    }
    @catch (NSException *exception) {
        [self hidePopup];
    }
    @finally {
    }
}

/// Private Method //////

// show controls
- (void) showControls{
    [aheart showHeart];
    [aflag showFlag];
    [aimageCount showTally];
}
// hide controls
- (void) hideControls{
    [aheart hideHeart];
    [aflag hideFlag];
    [aimageCount hideTally];
}


// load Hashtag
- (void) loadHashtag:(NSString *)hashtag color:(UIColor *)acolor{
    
    apopView.backgroundColor = acolor;
    
    PFQuery *queryHashtag = [PFQuery queryWithClassName:@"Selfie"];
    [queryHashtag orderByDescending:@"createdAt"];
    [queryHashtag whereKey:@"hashtags" equalTo:hashtag];
    [queryHashtag whereKey:@"flags" lessThanOrEqualTo:@9];
    [queryHashtag findObjectsInBackgroundWithBlock:^(NSArray *selfies, NSError *error) {
        if (!error) {
            NSLog(@"Successfully got %lu selfies for %@.", (unsigned long)selfies.count, hashtag);
            [aselfies removeAllObjects];
            aselfies = (NSMutableArray *)selfies;
            [self loadImages];
        }else{
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [self loadNextImage];
        }
    }];
    
}

// load users photos
- (void) loadUserPhotos:(UIColor *)acolor{

    PFQuery *queryHashtag = [PFQuery queryWithClassName:@"Selfie"];
    [queryHashtag orderByDescending:@"createdAt"];
    [queryHashtag whereKey:@"from" equalTo:[PFUser currentUser]];
    [queryHashtag findObjectsInBackgroundWithBlock:^(NSArray *selfies, NSError *error) {
        if (!error) {
            NSLog(@"Successfully got selfies for self.");
            [aselfies removeAllObjects];
            aselfies = (NSMutableArray *)selfies;
            [self loadImages];
        }else{
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [self loadNextImage];
        }
        
    }];
}

// load images
- (void) loadImages{
    [aselfiesImages removeAllObjects];
    for (PFObject *selfie in aselfies) {
        PFFile *imageFile = selfie[@"image"];
        [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                if([UIImage imageWithData:imageData]){
                   // NSUInteger i = [aselfies indexOfObject:selfie];
                   // if (i) {
                   //     [aselfiesImages insertObject:[UIImage imageWithData:imageData] atIndex:i];
                   // }else{
                        [aselfiesImages addObject:[UIImage imageWithData:imageData]];
                   // }
                    if (selfie == aselfies.lastObject) {
                        [self loadNextImage];
                        [self fadeOutLabels];
                    }
                }
            }
        }];
    }
    if (aselfies.count == 0) {
        [self loadNextImage];
    }
}

// markVisit
- (void)addVisit{
    @try {
        PFObject * selfie = [aselfies objectAtIndex:selfiesCounter];
        [selfie incrementKey:@"visits"];
        [selfie saveEventually];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

// Fade out helper label
-(void)fadeOutLabels {
    
    helpText.alpha = 1.0;
    [UIView animateWithDuration:1.0
                          delay:0.8  /* starts the animation after 3 seconds */
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         helpText.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                     }];
}

@end
