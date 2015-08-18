//
//  SELImageCountObject.m
//  #life
//
//  Created by Griffin Anderson on 8/20/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import "SELImageCountObject.h"

@interface SELImageCountObject ()

    @property UILabel *heartCountLabel;
    @property NSString *visits;

@end

@implementation SELImageCountObject

@synthesize heartCountLabel;
@synthesize visits;

- (void) initImageTally: (UIView *)view color:(SELColorPicker *)color{
    
    heartCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, view.frame.size.height - 40, 40, 40)];
    heartCountLabel.textColor = [color getPrimaryColor];
    heartCountLabel.font = [UIFont boldSystemFontOfSize:19];
    heartCountLabel.textAlignment = NSTextAlignmentRight;
    //heartCountLabel.backgroundColor = [UIColor whiteColor]; [UIColor colorWithWhite:0 alpha:.5]
    heartCountLabel.shadowColor = [UIColor colorWithWhite:0 alpha:.15];
    heartCountLabel.shadowOffset = CGSizeMake(0,1);
    
    [view addSubview:heartCountLabel];
    
    UIImage *eyeImage = [[UIImage imageNamed:@"eye"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    UIImageView *shadoweyeImageView = [[UIImageView alloc] initWithImage:eyeImage];
    shadoweyeImageView.frame = CGRectMake(heartCountLabel.frame.origin.x+45, view.frame.size.height - 32, eyeImage.size.width, eyeImage.size.height);
    shadoweyeImageView.contentMode = UIViewContentModeCenter;
    [shadoweyeImageView setTintColor:[UIColor colorWithWhite:0 alpha:.1]];
    [view addSubview:shadoweyeImageView];
    
    
    UIImageView *eyeImageView = [[UIImageView alloc] initWithImage:eyeImage];
    eyeImageView.frame = CGRectMake(heartCountLabel.frame.origin.x+45, view.frame.size.height - 33, eyeImage.size.width, eyeImage.size.height);
    eyeImageView.contentMode = UIViewContentModeCenter;
    [eyeImageView setTintColor:[color getPrimaryColor]];
    [view addSubview:eyeImageView];
}
- (void) countImageTally:(PFObject *) selfie{
    
    visits = [NSString stringWithFormat:@"%@", selfie[@"visits"]];
    visits = [self abbreviateNumber:[visits intValue]];
    heartCountLabel.text = visits;
    //[self getTime:selfie];
}

- (void) hideTally{
    heartCountLabel.hidden = YES;
}
- (void) showTally{
    heartCountLabel.hidden = NO;
}

- (void) getTime:(PFObject *) selfie {
    
    static int hrs = 96;
    
    NSInteger _ticks;
    if (_ticks) {
        NSDate *now = [NSDate date];
        NSDate *oldDate = (NSDate *)[selfie createdAt];
        _ticks = (NSInteger)[now timeIntervalSinceDate:oldDate];
        if (_ticks > (3600 * hrs)) {
            _ticks = (3600 * hrs);
        }
        _ticks = (3600 * hrs) - _ticks;
    }
    
    NSString *clock = [self formatTime:_ticks];
    heartCountLabel.text = [NSString stringWithFormat:@"%@ · %@", visits, clock];

}

- (NSString *)formatTime:(NSInteger )ticks{
    int minutes = fmod(trunc(ticks / 60.0), 60.0);
    int hours = trunc(ticks / 3600.0);
    
    if (hours > 0) {
        return [NSString stringWithFormat:@"%d hrs left", hours];
    }else if (minutes > 0){
        return [NSString stringWithFormat:@"%d min left", minutes];
    }else{
        return [NSString stringWithFormat:@"5 min left"];
    }
}

-(NSString *)abbreviateNumber:(int)num {
    
    NSString *abbrevNum;
    float number = (float)num;
    
    //Prevent numbers smaller than 1000 to return NULL
    if (num >= 1000) {
        NSArray *abbrev = @[@"K", @"M", @"B"];
        
        for (int i = abbrev.count - 1.0; i >= 0; i--) {
            
            // Convert array index to "1000", "1000000", etc
            int size = pow(10,(i+1)*3);
            
            if(size <= number) {
                // Removed the round and dec to make sure small numbers are included like: 1.1K instead of 1K
                number = number/size;
                NSString *numberString = [self floatToString:number];
                
                // Add the letter for the abbreviation
                abbrevNum = [NSString stringWithFormat:@"%@%@", numberString, [abbrev objectAtIndex:i]];
            }
            
        }
    } else {
        
        // Numbers like: 999 returns 999 instead of NULL
        abbrevNum = [NSString stringWithFormat:@"%d", (int)number];
    }
    
    return abbrevNum;
}

- (NSString *) floatToString:(float) val {
    NSString *ret = [NSString stringWithFormat:@"%.1f", val];
    unichar c = [ret characterAtIndex:[ret length] - 1];
    
    while (c == 48) { // 0
        ret = [ret substringToIndex:[ret length] - 1];
        c = [ret characterAtIndex:[ret length] - 1];
        
        //After finding the "." we know that everything left is the decimal number, so get a substring excluding the "."
        if(c == 46) { // .
            ret = [ret substringToIndex:[ret length] - 1];
        }
    }
    
    return ret;
}

@end
