//
//  SELClickableObject.h
//  #life
//
//  Created by Griffin Anderson on 11/10/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SELClickableObject : NSObject

@property NSMutableArray* views;
@property NSMutableArray* positivevotes;
@property NSMutableArray* negativevotes;

- (id) initClickable;
- (BOOL) canVote:(NSString *)selfieId;
- (BOOL) isPostiveVote:(NSString *)selfieId;
- (BOOL) isNegativeVote:(NSString *)selfieId;
- (void) addPostiveVote:(NSString *)selfieId;
- (void) addNegativeVote:(NSString *)selfieId;
- (void) removeVote:(NSString *)selfieId;
- (BOOL) canView:(NSString *)selfieId;
- (void) addView:(NSString *)selfieId;


@end
