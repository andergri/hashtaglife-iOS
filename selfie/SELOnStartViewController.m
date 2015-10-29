//
//  SELOnStartViewController.m
//  #life
//
//  Created by Griffin Anderson on 3/22/15.
//  Copyright (c) 2015 Griffin Anderson. All rights reserved.
//

#import "SELOnStartViewController.h"
#import "SELUserViewController.h"
#import "SELBannedViewController.h"
#import "SELLocationViewController.h"
#import "SELExtraViewController.h"
#import "SELPushNotificationViewController.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

@interface SELOnStartViewController ()

@end

@implementation SELOnStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) checkForPremissions{
    AVAuthorizationStatus audioAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    AVAuthorizationStatus videoAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(videoAuthorizationStatus == AVAuthorizationStatusAuthorized &&
       audioAuthorizationStatus == AVAuthorizationStatusAuthorized){
        return YES;
    }
    return NO;
}

- (void) runOnStart:(SELColorPicker*)color{
    
    [self checkForUser:color];
    [self checkBannedData];
    [self checkIPAddress];
    [self checkLocationData:color];
    
    self.view.hidden = YES;
}


/**
 [[[PFUser currentUser] objectForKey:@"location" ] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
 BOOL locationdefault = [[[[PFUser currentUser] objectForKey:@"location"] objectForKey:@"default"] boolValue];
 if (locationdefault) {
 filteredByLocation = NO;
 self.locationButton.tag = 0;
 }else{
 filteredByLocation = YES;
 self.locationButton.tag = 1;
 }
 [self locationTouched:nil];
 }];
**/


// Check for usersignup
- (void) checkForUser:color{
    
    [[PFUser currentUser] fetchInBackground];
    PFUser *user = [PFUser currentUser];
    if (!user) {
        SELUserViewController *userVC = [[SELUserViewController alloc] init];
        userVC.color = color;
        [self presentViewController:userVC animated:YES completion:^{
        }];
    }
}

// Check for Location Data
- (void) checkLocationData:(SELColorPicker*)color {
    
    if ([PFUser currentUser]) {
        NSLog(@"check location Data");
      
        if (![[PFUser currentUser] objectForKey:@"location"]) {
        
            /**
            SELExtraViewController *extra = [[SELExtraViewController alloc] init];
            extra.color = color;
            [self presentViewController:extra animated:YES completion:^{
            }];
            **/
                
            SELLocationViewController *location = [[SELLocationViewController alloc] init];
            location.color = color;
            location.selecting = YES;
            [self presentViewController:location animated:YES completion:^{
                }];
        }
    }
}

// Check for Notification Data
- (void) checkNotificationData:(SELColorPicker*)color {
    
    if ([PFUser currentUser]) {
            
        SELPushNotificationViewController *notification = [[SELPushNotificationViewController alloc] init];
        notification.color = color;
        
        notification.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        notification.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        if(notification.shouldAskForNotifications){
            [self presentViewController:notification animated:YES completion:^{
            }];
        }
    }
}


- (void) checkBannedData{
    
    if ([PFUser currentUser]) {
        
        PFObject *object = [[PFUser currentUser] objectForKey:@"banned"];
        if (object && ![object isEqual:@""]) {
            SELBannedViewController *banned = [[SELBannedViewController alloc] init];
            [self presentViewController:banned animated:YES completion:^{
            }];
        }
    }
}

- (void) checkIPAddress{
        // set users ip address
    if ([PFUser currentUser]) {
        @try {
            
            NSArray *searchArray = @[ IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ];
            NSDictionary *addresses = [self getIPAddresses];
            
            __block NSString *address;
            NSMutableArray *uniqueAddress = [[NSMutableArray alloc] initWithObjects:nil];
            [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
             {
                 address = addresses[key];
                 if (address) {
                     [uniqueAddress addObject:address];
                 }
             }];
            [[PFUser currentUser] addUniqueObjectsFromArray:uniqueAddress forKey:@"ipAddress"];
            [[PFUser currentUser] saveInBackground];
        }
        @catch (NSException *exception) {
            NSLog(@"Failed to get Ip address");
        }
        @finally {
        }
    }
}

- (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}
@end
