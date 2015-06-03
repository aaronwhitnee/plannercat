//
//  AppDelegate.m
//  TicketScanner
//
//  Created by Aaron Robinson on 2/26/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import "AppDelegate.h"
#import "EventsDataSource.h"
#import "LoginViewController.h"
#import "MainMenuTableViewController.h"

@interface AppDelegate()
@property(nonatomic, strong) UINavigationController *mainNavigation;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLogout:)
                                                 name:@"userLogout"
                                               object:nil];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    
    // Set the navigation controller as the app's root view controller
    MainMenuTableViewController *mainMenu = [[MainMenuTableViewController alloc] init];
    self.mainNavigation = [[UINavigationController alloc] initWithRootViewController:mainMenu];
    self.window.rootViewController = self.mainNavigation;
    
    // Styling the nav bar
    [self.mainNavigation.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.mainNavigation.navigationBar.shadowImage = [UIImage new];
    self.mainNavigation.navigationBar.translucent = NO;
    
    // Display login screen if no user is currently logged in
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"appUserID"] == nil) {
        __strong LoginViewController *loginScreen = [[LoginViewController alloc] init];
        loginScreen.delegate = self.mainNavigation;
        [self.mainNavigation presentViewController:loginScreen animated:NO completion:nil];
    }
    
    return YES;
}

- (void)userLogout:(UIResponder *)application {
    NSLog(@"Logging out...");
    
    // Remove user defaults (user ID and email)
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    // Display login screen
    __strong LoginViewController *loginScreen = [[LoginViewController alloc] init];
    loginScreen.delegate = self.mainNavigation;
    loginScreen.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.mainNavigation presentViewController:loginScreen animated:YES completion:^{
        [self.mainNavigation popViewControllerAnimated:NO];
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
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
}

@end
