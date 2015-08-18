//
//  SELLoadContent.m
//  #life
//
//  Created by Griffin Anderson on 5/26/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import "SELLoadContent.h"

@implementation SELLoadContent

@synthesize delegate;

// Main
- (void) showSelfies:(NSUInteger)selectingType hashtag:(NSString*)hashtag  location:(BOOL)filtered objectId:(NSString*)objectId{
    filtered = !filtered;
    
    [[[PFUser currentUser] objectForKey:@"location"] fetchIfNeeded];
    if (![[[[PFUser currentUser] objectForKey:@"location"] objectForKey:@"default"] boolValue]) {
        NSLog(@"global photos shown");
        filtered = NO;
    }
    
    switch (selectingType) {
        case 0:
            [self loadPopular:filtered];
            break;
        case 1:
            [self loadFresh:filtered];
            break;
        case 2:
            [self loadHashtag:hashtag location:filtered];
            break;
        case 3:
            [self loadUserPhotos];
            break;
        case 4:
            [self loadObject:objectId];
            break;
        default:
            break;
    }
}

// load Hashtag
- (void) loadHashtag:(NSString *)hashtag location:(BOOL)location{
    
    PFQuery *hashtagItem = [PFQuery queryWithClassName:@"Selfie"];
    [hashtagItem whereKey:@"hashtags" equalTo:hashtag];
    [hashtagItem whereKey:@"flags" lessThanOrEqualTo:@4];
    [hashtagItem whereKey:@"likes" greaterThan:@(-4)];
    if (([[PFUser currentUser] objectForKey:@"location"]) && location) {
        [hashtagItem whereKey:@"location" equalTo:[[PFUser currentUser] objectForKey:@"location"]];
    }
    
    [hashtagItem orderByDescending:@"createdAt"];
    hashtagItem.limit = 50;
    [hashtagItem findObjectsInBackgroundWithBlock:^(NSArray *selfies, NSError *error) {
        
        if (!error) {

            // Delete Hashtags, with no content //
            if (selfies.count == 0) {
                
                // Hasthag Item
                PFQuery *hashtagItem;
                if (([[PFUser currentUser] objectForKey:@"location"]) && location) {
                    hashtagItem = [PFQuery queryWithClassName:@"Tag"];
                    [hashtagItem whereKey:@"location" equalTo:[[PFUser currentUser] objectForKey:@"location"]];
                }else{
                    hashtagItem = [PFQuery queryWithClassName:@"Hashtag"];
                }
                
                [hashtagItem whereKey:@"name" equalTo:hashtag];
                hashtagItem.limit = 5;
                [hashtagItem findObjectsInBackgroundWithBlock:^(NSArray *hashtagsResults, NSError *error) {
                    if (!error) {
                        if(hashtagsResults.count > 0){
                            
                            PFObject *deleteingHashtag = hashtagsResults[0];
                            deleteingHashtag[@"count"] = @0;
                            deleteingHashtag[@"trending"] = @0;
                            [deleteingHashtag saveInBackground];
                            
                            NSLog(@"Deleteing Hashtag %@", deleteingHashtag);
                        }
                    }else{
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                    }
                }];
            }
        }
        [self.delegate contentLoaded:selfies error:error];
    }];
    
}

// load users photos

- (void) loadUserPhotos{
    
    PFQuery *queryHashtag = [PFQuery queryWithClassName:@"Selfie"];
    [queryHashtag whereKey:@"from" equalTo:[PFUser currentUser]];
    [queryHashtag whereKey:@"flags" lessThanOrEqualTo:@4];
    [queryHashtag whereKey:@"likes" greaterThan:@(-4)];
    
    NSDate *newDate = [[NSDate alloc] initWithTimeInterval:-3600*4
                                                 sinceDate:[NSDate date]];
    
    PFQuery *queryAuto = [PFQuery queryWithClassName:@"Selfie"];
    [queryAuto whereKey:@"from" equalTo:[PFUser currentUser]];
    [queryAuto whereKey:@"createdAt" greaterThan:newDate];
    NSArray *removed = @[@"Admin",
                         @"Delete"];
    [queryAuto whereKey:@"complaint" notContainedIn:removed];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[queryHashtag,queryAuto]];
    [query orderByDescending:@"createdAt"];
    query.limit = 50;
    [query findObjectsInBackgroundWithBlock:^(NSArray *selfies, NSError *error) {
        [self.delegate contentLoaded:selfies error:error];
    }];
}

// load Fresh

- (void) loadFresh:(BOOL)location{
    
    PFQuery *hashtagItem = [PFQuery queryWithClassName:@"Selfie"];
    [hashtagItem whereKey:@"flags" lessThanOrEqualTo:@4];
    [hashtagItem whereKey:@"likes" greaterThan:@(-4)];
    if (([[PFUser currentUser] objectForKey:@"location"]) && location) {
        [hashtagItem whereKey:@"location" equalTo:[[PFUser currentUser] objectForKey:@"location"]];
    }
    NSDate *newDate = [[NSDate alloc] initWithTimeInterval:-3600*4
                                                 sinceDate:[NSDate date]];
    
    PFQuery *queryAuto = [PFQuery queryWithClassName:@"Selfie"];
    [queryAuto whereKey:@"createdAt" greaterThan:newDate];
    [queryAuto whereKey:@"from" equalTo:[PFUser currentUser]];
    NSArray *removed = @[@"Admin",
                         @"Delete"];
    [queryAuto whereKey:@"complaint" notContainedIn:removed];
    if (([[PFUser currentUser] objectForKey:@"location"]) && location) {
        [queryAuto whereKey:@"location" equalTo:[[PFUser currentUser] objectForKey:@"location"]];
    }
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[hashtagItem,queryAuto]];
    [query orderByDescending:@"createdAt"];
    query.limit = 50;
    [query findObjectsInBackgroundWithBlock:^(NSArray *selfies, NSError *error) {
        [self.delegate contentLoaded:selfies error:error];
    }];
}

// load popular

- (void) loadPopular:(BOOL)location{
    
    NSDate *newDate = [[NSDate alloc] initWithTimeInterval:-3600*18
                                                 sinceDate:[NSDate date]];
    PFQuery *hashtagItem = [PFQuery queryWithClassName:@"Selfie"];
    [hashtagItem whereKey:@"createdAt" greaterThan:newDate];
    [hashtagItem whereKey:@"likes" greaterThan:@(0)];
    [hashtagItem whereKey:@"flags" lessThanOrEqualTo:@4];
    if (([[PFUser currentUser] objectForKey:@"location"]) && location) {
        [hashtagItem whereKey:@"location" equalTo:[[PFUser currentUser] objectForKey:@"location"]];
    }
    [hashtagItem orderByDescending:@"likes"];
    hashtagItem.limit = 50;
    [hashtagItem findObjectsInBackgroundWithBlock:^(NSArray *selfies, NSError *error) {
        [self.delegate contentLoaded:selfies error:error];
    }];
}

// load selfie

- (void) loadObject:(NSString*)objectId{
    
    PFQuery *hashtagItem = [PFQuery queryWithClassName:@"Selfie"];
    [hashtagItem getObjectInBackgroundWithId:objectId block:^(PFObject *selfie, NSError *error) {
        NSArray *selfies = nil;
        if (!error) {
            selfies = [NSArray arrayWithObject:selfie];
        }
        [self.delegate contentLoaded:selfies error:error];
    }];
}


@end
