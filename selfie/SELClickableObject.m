//
//  SELClickableObject.m
//  #life
//
//  Created by Griffin Anderson on 11/10/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import "SELClickableObject.h"

@implementation SELClickableObject

@synthesize positivevotes;
@synthesize negativevotes;
@synthesize views;

- (id) initClickable{
    
    positivevotes = [[NSMutableArray alloc] init];
    negativevotes = [[NSMutableArray alloc] init];
    views = [[NSMutableArray alloc] init];
    return  self;
}

// Votes

- (BOOL) canVote:(NSString *)selfieId{
    if ([positivevotes containsObject:selfieId] || [negativevotes containsObject:selfieId]) {
        return NO;
    }else {
        return YES;
    }
}

- (BOOL) isPostiveVote:(NSString *)selfieId{
    return [positivevotes containsObject:selfieId];
}
- (BOOL) isNegativeVote:(NSString *)selfieId{
    return [negativevotes containsObject:selfieId];
}

- (void) addPostiveVote:(NSString *)selfieId{
    if ([self canVote:selfieId]) {
        [positivevotes addObject:selfieId];
    }
    NSLog(@"postive count %lu", (unsigned long)[positivevotes count]);
}

- (void) addNegativeVote:(NSString *)selfieId{
    if ([self canVote:selfieId]) {
        [negativevotes addObject:selfieId];
    }
    NSLog(@"negative count %lu", (unsigned long)[negativevotes count]);
}
- (void) removeVote:(NSString *)selfieId{
    if (![self canVote:selfieId]) {
        if ([self isPostiveVote:selfieId]) {
            [positivevotes removeObject:selfieId];
        }
        if ([self isNegativeVote:selfieId]) {
            [negativevotes removeObject:selfieId];
        }
    }
    NSLog(@"postive r count %lu", (unsigned long)[positivevotes count]);
    NSLog(@"negative r count %lu", (unsigned long)[negativevotes count]);
}

// Views

- (BOOL) canView:(NSString *)selfieId{
    return ![views containsObject:selfieId];
}

- (void) addView:(NSString *)selfieId{
    if ([self canView:selfieId]) {
        [views addObject:selfieId];
    }
}


@end
