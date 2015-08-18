//
//  SELLoadContent.h
//  #life
//
//  Created by Griffin Anderson on 5/26/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SELLoadContentDelegate <NSObject>

- (void) contentLoaded:(NSArray *)content error:(NSError*)error;

@end

@interface SELLoadContent : NSObject

@property (nonatomic) id<SELLoadContentDelegate> delegate;
- (void) showSelfies:(NSUInteger)selectingType hashtag:(NSString*)hashtag location:(BOOL)filtered objectId:(NSString*)objectId;

@end
