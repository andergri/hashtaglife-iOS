//
//  SELFlagObject.h
//  #life
//
//  Created by Griffin Anderson on 8/20/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SELColorPicker.h"

@interface SELFlagObject : NSObject <UIActionSheetDelegate>

- (void) initFlag:(UIView *)view color:(SELColorPicker *)color;
- (void) initBack:(UIView *)view color:(SELColorPicker *)color;
- (void) hideFlag;
- (void) showFlag;
- (void) hideBack;
- (void) showBack;
- (void) tapFlag:(PFObject *) selfie;
- (void) resetFlag;
@end
