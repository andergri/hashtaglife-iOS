//
//  SELCameraOverlayView.h
//  selfie
//
//  Created by Griffin Anderson on 7/23/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SELColorPicker.h"

@interface SELCameraOverlayView : UIView

- (instancetype)initWithFrame:(CGRect)frame color:(SELColorPicker*)color;
@property UIImagePickerController *pickerRefrenece;
@property (nonatomic) SELColorPicker *color;

@end
