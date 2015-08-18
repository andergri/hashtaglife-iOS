//
//  SELImagePickerViewController.h
//  #life
//
//  Created by Griffin Anderson on 11/6/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SELImagePickerViewController : UIImagePickerController

@property UILabel *uploadHint;
- (void) showUploadHint;

@end
