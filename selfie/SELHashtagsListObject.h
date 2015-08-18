//
//  SELHashtagsListObject.h
//  #life
//
//  Created by Griffin Anderson on 9/22/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SELColorPicker.h"

@protocol SELHashtagsListObjectDelegate <NSObject>

- (void)setupGesture:(UILabel *)label;

@end

@interface SELHashtagsListObject : NSObject

- (void) initHashtags:(UIView *)view color:(SELColorPicker *)color;
- (void) hideHashtags;
- (void) showHashtags;
- (void) setHashtags:(PFObject *) selfie searched:(NSString *)searched;
@property (nonatomic) id<SELHashtagsListObjectDelegate> delegate;

@end
