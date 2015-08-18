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
@property UIImageView *backImageView;
@property UIButton *backButton;
@property UIView *mainView;
@property PFObject *selfiePending;
@property SELColorPicker *acolor;

@end

@implementation SELFlagObject

@synthesize flagImageView;
@synthesize flagButton;
@synthesize backImageView;
@synthesize backButton;
@synthesize mainView;
@synthesize selfiePending;
@synthesize acolor;


// Init Flag
- (void) initFlag:(UIView *)view color:(SELColorPicker *)color{

    acolor = color;
    mainView = view;
    flagButton = [[UIButton alloc] initWithFrame:CGRectMake(view.frame.size.width - 35, 0, 35, 65)];
    
    //UILabel *flagLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, -2, 65, 70)];
    //flagLabel.text = @"Report";
    //flagLabel.textColor = [UIColor whiteColor];
    //flagLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:18.0];
    
    UIImage *flagImage = [[UIImage imageNamed:@"open-flag"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [flagImage setAccessibilityIdentifier:@"open-flag"];
    flagImageView = [[UIImageView alloc] initWithImage:flagImage];
    flagImageView.frame = CGRectMake(5, 3.5, flagImage.size.width, flagImage.size.height);
    flagImageView.contentMode = UIViewContentModeTop;
    flagImageView.contentScaleFactor = 2.8;
    [flagImageView setTintColor:[UIColor colorWithWhite:.4 alpha:.7]];
    
    [flagButton addSubview:flagImageView];
    //[flagButton addSubview:flagLabel];
    flagButton.enabled = YES;
    flagButton.userInteractionEnabled = NO;
    [view addSubview:flagButton];
    
    /**
    flagDictionary = @{
                       @"Delete my photo": @"Delete",
                       @"It’s annoying or not interesting": @"Spam",
                       @"I think it shouldn’t be on #life": @{
                               @"Bullying, Hurtful, Threatening or Suicidal ": @{
                                       @"It’s mean": @"Bullying",
                                       @"It offends a race, sex, gender, orientation or ability": @"Prejudice",
                                       @"It’s threatening or violent": @"Threatening",
                                       @"I think they might hurt themselves": @"Emergency"
                                       },
                               @"Nudity, Pornography": @"Pornography",
                               @"Drugs, Guns or Adult Products": @"Mature",
                               @"Rude, Vulgar or uses Bad Language": @"Vulgar",
                               @"Intellectual Property or Private Information": @"Privacy",
                               @"Something else": @"Inappropriate"
                               },
                       @"It’s about me and I don’t like it": @{
                               @"It’s embarrassing": @"Embarrassing",
                               @"It insults me": @"Bullying",
                               @"It’s threatening": @"Threatening",
                               @"Shows personal information": @"Privacy",
                               @"Something else": @"Inappropriate"
                               }
                       };
    **/
    
}

- (void) initBack:(UIView *)view color:(SELColorPicker *)color{

    acolor = color;
    mainView = view;
    backButton = [[UIButton alloc] initWithFrame:CGRectMake(view.frame.size.width - 70, 0, 35, 65)];

    
    UIImage *backImage = [[UIImage imageNamed:@"back-button"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [backImage setAccessibilityIdentifier:@"back-button"];
    backImageView = [[UIImageView alloc] initWithImage:backImage];
    backImageView.frame = CGRectMake(3, 2, backImage.size.width, backImage.size.height);
    backImageView.contentMode = UIViewContentModeTop;
    backImageView.contentScaleFactor = 3;
    [backImageView setTintColor:[UIColor colorWithWhite:.4 alpha:.7]];
    
    [backButton addSubview:backImageView];
    backButton.enabled = YES;
    backButton.userInteractionEnabled = NO;
    [view addSubview:backButton];
    
}

// Hide Flag
- (void) hideFlag{
    flagButton.hidden = YES;
}

// Show Flag
- (void) showFlag{
    flagButton.hidden = NO;
}

// Hide Back
- (void) hideBack{
    backButton.hidden = YES;
}

// Show Back
- (void) showBack{
    backButton.hidden = NO;
}

// Tap Flag
- (void) tapFlag:(PFObject *) selfie{

    NSLog(@"Flag");
    
    if ([[flagImageView.image accessibilityIdentifier] isEqualToString:@"open-flag"]) {
        [self flagControl:YES selfie:selfie];
    }else if([[flagImageView.image accessibilityIdentifier] isEqualToString:@"full-flag"]) {
        [self flagControl:NO selfie:selfie];
    }else{
        NSLog(@"none");
    }
}

// Reset Flag
- (void)resetFlag{
    
    UIImage *backImage = [[UIImage imageNamed:@"open-flag"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [backImage setAccessibilityIdentifier:@"open-flag"];
    flagImageView.image = backImage;
    flagImageView.contentMode = UIViewContentModeTop;
    flagImageView.contentScaleFactor = 2.8;
    [flagImageView setTintColor:[UIColor colorWithWhite:.4 alpha:.7]];
}



// Private Method
- (void)addFlag:(BOOL)increment selfie:(PFObject *) selfie other:(NSString *)other{
    
    NSDictionary *flagDictionary = @{
                       @"Delete my photo": @"Delete",
                       @"Spam": @"Spam",
                       @"Nudity or Pornography": @"Pornography",
                       @"Graphic Violence": @"Violence",
                       @"Actively promotes self-harm": @"Harm",
                       @"Attacks a group or individual": @"Attack",
                       @"Hateful Speech or Symbols": @"Hateful",
                       @"I just don't like it": @"Other"
                       };
    other = [flagDictionary valueForKey:other];
    NSLog(@"flag %@", other);
    
    @try {
        if (increment) {
            [selfie incrementKey:@"flags"];
            [selfie addUniqueObjectsFromArray:[NSArray arrayWithObject:other] forKey:@"complaint"];

            
            if ([PFUser currentUser]) {
                [selfie addUniqueObjectsFromArray:[NSArray arrayWithObject:[[PFUser currentUser] objectId]] forKey:@"complainer"];
            }
    
            if ([other isEqualToString:@"Delete"]) {
                [selfie incrementKey:@"flags"];
                [selfie incrementKey:@"flags"];
                [selfie incrementKey:@"flags"];
                [selfie incrementKey:@"flags"];
                [selfie incrementKey:@"flags"];
            }
        }else{
            //[sel incrementKey:@"flags"];
        }
        [selfie saveInBackground];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

- (void) flagControl:(BOOL)increment selfie:(PFObject *) selfie{

    selfiePending = selfie;
    UIActionSheet *actionSheet;
    if (increment) {
        if ([[[selfie objectForKey:@"from"] objectId] isEqualToString:[[PFUser currentUser] objectId]]){
            
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:@"Delete my photo", nil];
        }else{
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:@"Spam", @"Nudity or Pornography", @"Graphic Violence",
                           @"Actively promotes self-harm",
                           @"Attacks a group or individual",
                           @"Hateful Speech or Symbols",
                           @"I just don't like it", nil];
        }
    }else{
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Undo Report"
                                                    otherButtonTitles:nil];
    }
    [actionSheet showInView:mainView];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (   [@"Delete my photo" isEqualToString:[actionSheet buttonTitleAtIndex:buttonIndex]]
        || [@"Spam" isEqualToString:[actionSheet buttonTitleAtIndex:buttonIndex]]
        || [@"Nudity or Pornography" isEqualToString:[actionSheet buttonTitleAtIndex:buttonIndex]]
        || [@"Graphic Violence" isEqualToString:[actionSheet buttonTitleAtIndex:buttonIndex]]
        || [@"Actively promotes self-harm" isEqualToString:[actionSheet buttonTitleAtIndex:buttonIndex]]
        || [@"Attacks a group or individual" isEqualToString:[actionSheet buttonTitleAtIndex:buttonIndex]]
        || [@"Hateful Speech or Symbols" isEqualToString:[actionSheet buttonTitleAtIndex:buttonIndex]]
        || [@"I just don't like it" isEqualToString:[actionSheet buttonTitleAtIndex:buttonIndex]]) {
        
        UIImage *backImage = [[UIImage imageNamed:@"full-flag"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [backImage setAccessibilityIdentifier:@"full-flag"];
        flagImageView.image = backImage;
        flagImageView.contentMode = UIViewContentModeTop;
        flagImageView.contentScaleFactor = 2.8;
        [flagImageView setTintColor:[UIColor redColor]];
        [flagImageView setTintColor:[UIColor colorWithWhite:1 alpha:1]];
        [self addFlag:YES selfie:selfiePending other:[actionSheet buttonTitleAtIndex:buttonIndex]];
        
        if (![@"Delete my photo" isEqualToString:[actionSheet buttonTitleAtIndex:buttonIndex]]) {
        }
    
    }else if([@"Undo Report" isEqualToString:[actionSheet buttonTitleAtIndex:buttonIndex]]){
        UIImage *backImage = [[UIImage imageNamed:@"open-flag"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [backImage setAccessibilityIdentifier:@"open-flag"];
        flagImageView.image = backImage;
        flagImageView.contentMode = UIViewContentModeTop;
        flagImageView.contentScaleFactor = 2.8;
        [flagImageView setTintColor:[UIColor colorWithWhite:.4 alpha:.7]];
        [self addFlag:NO selfie:selfiePending other:nil];
    }else{
        selfiePending = nil;
    }
}

@end
