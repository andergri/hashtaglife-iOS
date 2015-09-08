//
//  SELAppDelegate.m
//  selfie
//
//  Created by Griffin Anderson on 7/19/14.
//  Copyright (c) 2014 Griffin Anderson. All rights reserved.
//

#import "SELAppDelegate.h"
#import "GAI.h"
#import "JLNotificationPermission.h"
#import "SELPageViewController.h"
#import "Branch.h"

@implementation SELAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Parse Setup
    [Parse setApplicationId:@"jjcVHlw8UwWC2FkXZhL7JNLqDiXJlyBnKVAIsrbO"
                  clientKey:@"oivL7zqMRzHAv0fBKJkUuxnQch3tNkQ91t3WMJr1"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 20;
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelError];
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-53643197-2"];
    
    Branch *branch = [Branch getInstance];
    [branch initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        // params are the deep linked params associated with the link that the user clicked before showing up.
        NSLog(@"deep link data: %@", [params description]);
    }];
    
    if (application.applicationState != UIApplicationStateBackground) {
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced
        // in iOS 7). In that case, we skip tracking here to avoid double
        // counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    /**
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
    if([PFUser currentUser]){
        if([currentInstallation objectForKey:@"user"] == nil){
            currentInstallation[@"user"] = [PFUser currentUser];
            [currentInstallation saveEventually];
        }
        if ([currentInstallation objectForKey:@"location"] == nil) {
            if ([[PFUser currentUser] objectForKey:@"location"]) {
                currentInstallation.channels = @[ @"global", ((PFObject*)[[PFUser currentUser] objectForKey:@"location"]).objectId ];
                [currentInstallation setObject:[[PFUser currentUser] objectForKey:@"location"] forKey:@"location"];
            }
            [currentInstallation saveEventually];
        }
    }**/
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/** REGISTER PUSH NOTIFICATIONS **/

- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError %@", error);
    
    [[JLNotificationPermission sharedInstance] notificationResult:nil error:error];
}

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken %@", [deviceToken description]);
    [[JLNotificationPermission sharedInstance] notificationResult:deviceToken error:nil];
    
    // Store the deviceToken in the current installation and save it to Parse.
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken");
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    
    if ([PFUser currentUser]) {
        
        currentInstallation[@"user"] = [PFUser currentUser];
        if ([[PFUser currentUser] objectForKey:@"location"]) {
            currentInstallation.channels = @[ @"global", ((PFObject*)[[PFUser currentUser] objectForKey:@"location"]).objectId ];
            [currentInstallation setObject:[[PFUser currentUser] objectForKey:@"location"] forKey:@"location"];
        }
    }
    
    [currentInstallation saveInBackground];
    
}


/** HANDLE PUSH NOTIFICATIONS **/

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //[PFPush handlePush:userInfo];
    
    if (application.applicationState == UIApplicationStateInactive) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler {
    // Push Selfie internal
    
    if (application.applicationState == UIApplicationStateInactive) {
    
        NSString *selfieId = [userInfo objectForKey:@"selfie"];
        if (selfieId != nil) {
            [self performSelector:@selector(postNotificationToPresentPushMessagesVC:)
                       withObject:selfieId afterDelay:.5f];
        }
        
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }else{
        [PFPush handlePush:userInfo];
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        if (currentInstallation.badge != 0) {
            currentInstallation.badge = 0;
            [currentInstallation saveEventually];
        }
    }
    handler(UIBackgroundFetchResultNoData);
}

-(void)postNotificationToPresentPushMessagesVC:(NSString*)selfieId  {
    
    NSDictionary* dict = [NSDictionary dictionaryWithObject:
                          selfieId forKey:@"selfieId"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HAS_PUSH_NOTIFICATION" object:self userInfo:dict];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    [[Branch getInstance] handleDeepLink:url];
    
    NSLog(@"Calling Application Bundle ID: %@", sourceApplication);
    NSLog(@"URL scheme:%@", [url scheme]);
    NSLog(@"URL query: %@", [url query]);
    
    return YES;
}
@end
