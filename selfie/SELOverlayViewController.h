//
//  SELOverlayViewController.h
//  #life
//
//  Created by Griffin Anderson on 5/25/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SELColorPicker.h"
#import "SELHashtagsListObject.h"

@protocol SELOverlayViewControllerDelegate <NSObject>

- (void) goBackward;
- (void) goForward;
- (void) pullDown:(BOOL)isUsernameListVisible;
- (void) showSelfies:(NSUInteger)selectingType hashtag:(NSString*)hashtag color:(UIColor*)acolor location:(BOOL)filtered objectId:(NSString*)objectId;
@end

@interface SELOverlayViewController : UIViewController <SELHashtagsListObjectDelegate>

@property (nonatomic) id<SELOverlayViewControllerDelegate> delegate;
@property SELColorPicker *color;
- (void) setSelfie:(PFObject *)selfie;
- (void) hideOverlay;

@end
