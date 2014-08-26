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
    
@end

@implementation SELImageCountObject

@synthesize heartCountLabel;

- (void) initImageTally: (UIView *)view{
    
    heartCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(view.frame.size.width - 180, view.frame.size.height - 38, 170, 42)];
    heartCountLabel.textColor = [UIColor whiteColor];
    heartCountLabel.font = [UIFont systemFontOfSize:20];
    heartCountLabel.textAlignment = NSTextAlignmentRight;
    [view addSubview:heartCountLabel];
}
- (void) countImageTally:(PFObject *) selfie{
    
    heartCountLabel.text = [NSString stringWithFormat:@"%@ likes %@ views", selfie[@"likes"], selfie[@"visits"]];
}
- (void) hideTally{
    heartCountLabel.hidden = YES;
}
- (void) showTally{
    heartCountLabel.hidden = NO;
}


@end
