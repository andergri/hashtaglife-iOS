//
//  SELHashtagTableViewController.h
//  selfie
//
//  Created by Griffin Anderson on 7/19/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SELHashtagTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

- (void) searchForHashtag:(NSString *)query;
@property (nonatomic, strong) NSMutableArray *hashtags;

@end