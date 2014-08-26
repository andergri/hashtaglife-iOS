//
//  SELCameraObject.h
//  #life
//
//  Created by Griffin Anderson on 8/20/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SELColorPicker.h"

@interface SELCameraObject : NSObject

@property UIImagePickerController *imagePicker;

- (void) initCameraView:(UIView *)view color:(SELColorPicker *)color;
- (void) initCamera:(UIView *)view;

@end
