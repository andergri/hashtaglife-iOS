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
@property (nonatomic, strong) NSMutableArray *objectsH;
@property (nonatomic, strong) NSMutableArray *inbox;
@property (nonatomic, strong) NSMutableArray *inboxSeen;
@property (nonatomic, strong) NSMutableArray *subscribed;
- (void) markInbox:(NSString *)hashtag;

@end
