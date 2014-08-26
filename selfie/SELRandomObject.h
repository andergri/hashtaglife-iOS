//
//  SELRandomObject.h
//  #life
//
//  Created by Griffin Anderson on 8/20/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SELColorPicker.h"

@interface SELRandomObject : NSObject

- (void) initMainView:(UIView *)headerView text:(UITextField *)text exit:(UIButton*)exit color:(SELColorPicker *)color;

@end
