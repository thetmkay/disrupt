//
//  AppDelegate.m
//  stacktimer
//
//  Created by Niket Shah on 18/10/2014.
//  Copyright (c) 2014 Niket Shah. All rights reserved.
//

#import "AppDelegate.h"
#import "MagicalRecord.h"
#import <Parse/Parse.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Parse setApplicationId:@"TpudbmSzk74NMI1GBDfs4FJq4E5Tk4MbJ4kgb5rR"
                  clientKey:@"5XjZBAq5aQMNUoNjGF3BtcDdnCxVjw44FVz76zJ3"];
    // Override point for customization after application launch.
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"STModel.sqlite"];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [MagicalRecord cleanUp];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    NSLog(@"url recieved: %@", url);
    NSLog(@"host: %@", [url host]);
    
    if([[url host] isEqualToString:@"oauth.redirect.yammer"]) {
        if ([[YMLoginController sharedInstance] handleLoginRedirectFromUrl:url sourceApplication:sourceApplication])
            return YES;
    } else if ([[url host] isEqualToString:@"add.timer"]) {
        NSLog(@"add timer called");
        NSString *decoded = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)[url query], CFSTR(""), kCFStringEncodingUTF8);
        NSError *e = nil;
        NSData *jsonData = [decoded dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData: jsonData options: NSJSONReadingMutableContainers error: &e];
        
        NSLog(@"%@",  json);
    }
    
    // If we arrive here it means the login was successful, so now let's get the authToken to be used on all subsequent requests
    
    
    // URL was not a match, or came from an application other than Safari
    return NO;
}

@end
