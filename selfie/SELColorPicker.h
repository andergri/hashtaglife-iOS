//
//  SELColorPicker.h
//  selfie
//
//  Created by Griffin Anderson on 7/25/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SELColorPicker : NSObject

- (void) initColor;
- (UIColor *) getPrimaryColor;
- (NSArray *) getColorArray;

@end
