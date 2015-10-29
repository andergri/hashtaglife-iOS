//
//  SELPushNotificationViewController.h
//  #life
//
//  Created by Griffin Anderson on 10/5/15.
//  Copyright © 2015 Griffin Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SELColorPicker.h"
#import "SELPageViewController.h"

@interface SELPushNotificationViewController : UIViewController

@property SELColorPicker* color;
- (BOOL) shouldAskForNotifications;

@end
