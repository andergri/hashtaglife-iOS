//
//  SELHashtagLabel.m
//  #life
//
//  Created by Griffin Anderson on 9/22/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import "SELHashtagLabel.h"

#define PADDING 3
#define TOPPADDING 3

@implementation SELHashtagLabel

- (void)drawTextInRect:(CGRect)rect {
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(TOPPADDING, PADDING, TOPPADDING, PADDING))];
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    return CGRectInset([self.attributedText boundingRectWithSize:CGSizeMake(999, 999)
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                         context:nil], -PADDING, 0);
}


@end
