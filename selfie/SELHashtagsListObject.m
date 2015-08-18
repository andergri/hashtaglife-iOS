//
//  SELHashtagsListObject.m
//  #life
//
//  Created by Griffin Anderson on 9/22/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import "SELHashtagsListObject.h"
#import "SELHashtagLabel.h"

@interface SELHashtagsListObject ()

@property CGRect mainView;
@property UIView *hashtagsView;
@property NSUInteger lineHeight;
@property NSString *likeCount;
@property NSString *asearched;
@property SELColorPicker *acolor;

@end

@implementation SELHashtagsListObject

@synthesize mainView;
@synthesize hashtagsView;
@synthesize lineHeight;
@synthesize likeCount;
@synthesize asearched;
@synthesize acolor;
@synthesize delegate;

- (void) initHashtags:(UIView *)view color:(SELColorPicker *)color{

    mainView = view.frame;
    hashtagsView = [[UIView alloc] initWithFrame:CGRectMake(0, view.frame.size.height - 112, 320, 72)];
    CAGradientLayer *layer = [CAGradientLayer layer];
    NSArray *colors = [NSArray arrayWithObjects:
                       (id)[UIColor colorWithWhite:0 alpha:0].CGColor,
                       (id)[UIColor colorWithWhite:0 alpha:.4].CGColor,
                       nil];
    [layer setColors:colors];
    [layer setFrame:hashtagsView.bounds];
    [hashtagsView.layer insertSublayer:layer atIndex:0];
    
    hashtagsView.userInteractionEnabled = YES;
    hashtagsView.clipsToBounds = YES;
    //hashtagsView.bounds = CGRectInset(hashtagsView.frame, 3.0f, 0.0f);

    
    // border
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, view.frame.size.width, 2.0f);
    topBorder.backgroundColor = [UIColor colorWithWhite:1.0f
                                                     alpha:1.0f].CGColor;
    
    //[hashtagsView.layer addSublayer:topBorder];
    acolor = color;
    [view addSubview:hashtagsView];
    
    [self showHashtags];
    
}
- (void) hideHashtags{
    hashtagsView.hidden = YES;
}
- (void) showHashtags{
    hashtagsView.hidden = NO;
}
- (void) setHashtags:(PFObject *) selfie searched:(NSString *)searched{
    
    asearched = searched;
    for (UIView *view in hashtagsView.subviews) {
        [view removeFromSuperview];
    }
    
    likeCount = [NSString stringWithFormat:@"%@ likes %@ views", selfie[@"likes"], selfie[@"visits"]];
    //[self likeCountLabel];
    
    @try {
        [self buildHashtagTextViewFromArray:selfie[@"hashtags"]];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

#pragma - mark private methods

- (void)likeCountLabel {
    SELHashtagLabel *label = [[SELHashtagLabel alloc] init];
    label.font = [UIFont systemFontOfSize:20.0f];
    label.textColor = [UIColor whiteColor];
    label.text = likeCount;
    //label.backgroundColor = [acolor getPrimaryColor];
    label.frame = CGRectMake(0,0,label.frame.size.width,label.frame.size.height + 5);
    [label sizeToFit];
    [self.hashtagsView addSubview:label];
}

- (void)buildHashtagTextViewFromArray:(NSArray *)hashtags{

    
    // 2. Loop through all the pieces:
    lineHeight = 2;
    hashtagsView.frame = CGRectMake(0, mainView.size.height - 112, 320, 72);

    hashtags = hashtags.count > 5 ? [[hashtags subarrayWithRange:NSMakeRange(0, 5)] mutableCopy] : hashtags;
    // sort
    hashtags = [self hashtagSort:hashtags];
    
    NSUInteger msgChunkCount = hashtags ? hashtags.count : 0;
    CGPoint wordLocation = CGPointMake(2.0, 42.0);
    
    for (NSUInteger i = 0; i < msgChunkCount; i++) {
        
        
        NSString *chunk = [hashtags objectAtIndex:i];
        if ([chunk isEqualToString:@""])
        {
            continue;     // skip this loop if the chunk is empty
        }
        
        // sort for hashtags to fit length
        
        
        // 4. Create label, styling dependent on whether it's a link:
        SELHashtagLabel *label = [[SELHashtagLabel alloc] init];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:21.0f];
        label.text = chunk;
        label.userInteractionEnabled = YES;
        label.textColor = [UIColor whiteColor];
        label.highlightedTextColor = [UIColor colorWithWhite:.92 alpha:1];
        label.text = [@"#" stringByAppendingString:label.text];
        label.text = [label.text stringByAppendingString:@""];
        label.shadowColor = [UIColor colorWithWhite:0 alpha:.15];
        label.shadowOffset = CGSizeMake(0,1);
        
        [self.delegate setupGesture:label];
        
        // 6. Lay out the labels so it forms a complete sentence again:
        
        [label sizeToFit];
        
        if (self.hashtagsView.frame.size.width < wordLocation.x + label.bounds.size.width)
        {
            lineHeight += 1;
            wordLocation.x = 2.0;                       // move this word all the way to the left...
            wordLocation.y -= (label.frame.size.height + 0);  // ...on the next line
            hashtagsView.frame = CGRectMake(0, mainView.size.height - 112, 320, 72);
            
            // And trim of any leading white space:
            NSRange startingWhiteSpaceRange = [label.text rangeOfString:@"^\\s*"
                                                                options:NSRegularExpressionSearch];
            if (startingWhiteSpaceRange.location == 0)
            {
                label.text = [label.text stringByReplacingCharactersInRange:startingWhiteSpaceRange
                                                                 withString:@""];
                [label sizeToFit];
            }
        }
        
        // Set the location for this label:
        label.frame = CGRectMake(wordLocation.x,
                                 wordLocation.y,
                                 label.frame.size.width,
                                 label.frame.size.height + 5);
        
        
        // Show this label:
        [self.hashtagsView addSubview:label];
        
        // Update the horizontal position for the next word:
        wordLocation.x += label.frame.size.width;

    }
    
    for (NSUInteger i = lineHeight; i < 4; i++) {

        self.hashtagsView.frame = CGRectMake(self.hashtagsView.frame.origin.x, self.hashtagsView.frame.origin.y, self.hashtagsView.frame.size.width, self.hashtagsView.frame.size.height);
    }
}

/** private functions **/

// Cleans up the hashtags
- (NSArray*) hashtagSort:(NSArray *)hashtags {
    
    NSMutableArray * dirtyHashtags = [[NSMutableArray alloc] init];
    NSMutableArray * row1 = [[NSMutableArray alloc] init];
    NSMutableArray * row2 = [[NSMutableArray alloc] init];
    
    float boxLength = hashtagsView.frame.size.width - 4;
    float lengthRow1 = boxLength;
    float lengthRow2 = boxLength;
    
    // sort by size
    //dirtyHashtags = [NSMutableArray arrayWithArray:[self sortByLength:hashtags]];
    dirtyHashtags = [NSMutableArray arrayWithArray:hashtags];
    
    /**
    // remove current hashtag
    for (NSString *hashtag in dirtyHashtags) {
        if ([hashtag isEqualToString:asearched] && [self canHashtagFit:hashtag rowLength:lengthRow1]) {
            [row1 addObject:hashtag];
            lengthRow1 = [self newRowLength:hashtag rowLength:lengthRow1];
            //break;
        }
    }
    [dirtyHashtags removeObjectsInArray:row1];
    **/

    for (NSString *hashtag in dirtyHashtags) {
        
        if ([self canHashtagFit:hashtag rowLength:lengthRow1]) {
            [row1 addObject:hashtag];
            lengthRow1 = [self newRowLength:hashtag rowLength:lengthRow1];
        }
    }
    [dirtyHashtags removeObjectsInArray:row1];
    
    for (NSString *hashtag in dirtyHashtags) {
        
        if ([self canHashtagFit:hashtag rowLength:lengthRow2]) {
            [row2 addObject:hashtag];
            lengthRow2 = [self newRowLength:hashtag rowLength:lengthRow2];
        }
    }
    [dirtyHashtags removeObjectsInArray:row2];
    
    if (row2.count > 0) {
        return [row2 arrayByAddingObjectsFromArray:row1];
    }else{
        return row1;
    }
}

// can it fit in a row
- (BOOL) canHashtagFit:(NSString *) hashtag rowLength:(float)rowLength{
    return (rowLength - [self caculateHashtagLength:hashtag]) > 0 ? YES : NO;
}

// remainder of row length
- (float) newRowLength:(NSString *) hashtag rowLength:(float)rowLength{
    return (rowLength - [self caculateHashtagLength:hashtag]);
}

// Caculates a hashtag length
- (float) caculateHashtagLength:(NSString *) hashtag{

    SELHashtagLabel *label = [[SELHashtagLabel alloc] init];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:21.0f];
    label.text = hashtag;
    [label sizeToFit];
    return label.frame.size.width;
}

// sort array of hashtags by length
- (NSArray *) sortByLength :(NSArray *)array{

    return [array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        if ([self caculateHashtagLength:a] > [self caculateHashtagLength:b]) {
            return NSOrderedAscending;
        } else if ([self caculateHashtagLength:a] < [self caculateHashtagLength:b]) {
            return NSOrderedDescending;
        } else{
            return NSOrderedSame;
        }
    }];
}

- (CAGradientLayer*) backgroundGradient {
    
    UIColor *colorOne = [UIColor colorWithRed:(120/255.0) green:(135/255.0) blue:(150/255.0) alpha:1.0];
    UIColor *colorTwo = [UIColor colorWithRed:(57/255.0)  green:(79/255.0)  blue:(96/255.0)  alpha:1.0];
    
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];
    
    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, nil];
    
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.colors = colors;
    headerLayer.locations = locations;
    
    return headerLayer;
    
}

@end
