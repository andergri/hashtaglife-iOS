//
//  SELImagePickerViewController.m
//  #life
//
//  Created by Griffin Anderson on 11/6/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import "SELImagePickerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface SELImagePickerViewController ()

@end

@implementation SELImagePickerViewController

@synthesize uploadHint;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showUploadHint{
    /**
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status != ALAuthorizationStatusAuthorized) {
    
    uploadHint.hidden = NO;
    uploadHint.alpha = 1.0;
    
    [UIView animateWithDuration:1.0f
                          delay:2.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         uploadHint.alpha = 0.0;
                     } completion:^(BOOL finished){
                         if (finished) {
                             uploadHint.hidden = YES;
                         }
                     }];
    }else{
        uploadHint.hidden = YES;
    }
     **/
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
