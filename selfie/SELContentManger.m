//
//  SELContentManger.m
//  #life
//
//  Created by Griffin Anderson on 5/26/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import "SELContentManger.h"

@interface SELContentManger ()

@property NSMutableArray *selfies;
@property int currentItemIndex;

@end

@implementation SELContentManger

@synthesize selfies;
@synthesize currentItemIndex;
@synthesize delegate;

- (void) initWithSelfies:(NSArray*)loadselfies{
    selfies = nil;
    currentItemIndex = -1;
    if (loadselfies.count == 0)
        [self exit];
    [selfies removeAllObjects];
    selfies = (NSMutableArray*)loadselfies;
    [self.delegate selfiesLoaded:selfies];
    
}
- (void) moveToDirection:(SELSelfieContentDirection)direction{
    switch(direction) {
        case SELSelfieDirectionBackward:
            [self backward];
            break;
        case SELSelfieDirectionForward:
            [self forward];
            break;
        case SELSelfieDirectionExit:
            [self exit];
            break;
        default:
            break;
    }
}

- (PFObject *) getCurrentSelfie{
    PFObject * currentSelfie = [selfies objectAtIndex:currentItemIndex];
    if (currentSelfie)
        return currentSelfie;
    return nil;
}

- (SELSelfieContentType) getCurrentSelfieType{
    PFObject * currentSelfie = [self getCurrentSelfie];
    if (!currentSelfie)
        return SELSelfieContentTypeError;
    PFFile *videoFile = currentSelfie[@"video"];
    return videoFile != nil ? SELSelfieContentTypeVideo : SELSelfieContentTypeImage;
}

- (void) selfieFailedToLoad:(PFObject *)selfie{
    if([selfies containsObject:selfie]){
        int index = [selfies indexOfObject:selfie];
        [selfies replaceObjectAtIndex:index withObject:nil];
    }
}

#pragma - private methods

- (void) exit{
    selfies = nil;
    [self.delegate hideViewer];
}
- (void) forward{
    currentItemIndex++;
    if (currentItemIndex >= selfies.count) {
        [self exit];
        return;
    }
    [self.delegate directionChanged:currentItemIndex];
    [self addVisit];
}
- (void) backward{
    if (currentItemIndex <= 0.0) {
        [self exit];
        return;
    }
    currentItemIndex--;
    [self.delegate directionChanged:currentItemIndex];
}

#pragma - additional methods

// markVisit
- (void)addVisit{
    
    @try {
        if ([self getCurrentSelfieType] != SELSelfieContentTypeError) {
            PFObject * selfie = [self getCurrentSelfie];
            [selfie incrementKey:@"visits"];
            [selfie saveInBackground];
        }
    }
    @catch (NSException *exception) {
    }
}


@end
