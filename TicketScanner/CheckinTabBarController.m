//
//  CheckinTabBarController.m
//  TicketScanner
//
//  Created by Aaron Robinson on 3/14/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import "CheckinTabBarController.h"

@interface CheckinTabBarController ()

@property(nonatomic, strong) RSVPListTableViewController *rsvpListTableViewController;
@property(nonatomic, strong) ScannerViewController *scannerViewController;
@property(nonatomic, strong) RegistrationFormViewController *registrationViewController;

@end

@implementation CheckinTabBarController

- (instancetype) initWithEvent:(Event *)event {
    self = [super init];
    if (self) {
        self.activeEvent = event;
        self.navigationController.navigationBarHidden = YES;
        self.title = [self.activeEvent title];
        self.navigationController.navigationBar.topItem.title = @"";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [self addChildViewController:self.rsvpListTableViewController];
    [self addChildViewController:self.scannerViewController];
    [self addChildViewController:self.registrationViewController];
        
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0 green:100.0/255.0 blue:180.0/255.0 alpha:1.0].CGColor);
    CGContextFillRect(context, rect);
    UIImage *solidColorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.tabBar setBackgroundImage:solidColorImage];
    [self.tabBar setShadowImage:solidColorImage];
    self.tabBar.tintColor = [UIColor whiteColor];
}

#pragma mark - Child View Controllers

- (RSVPListTableViewController *)rsvpListTableViewController {
    if (!_rsvpListTableViewController) {
        _rsvpListTableViewController = [RSVPListTableViewController new];
        UIImage *img = [UIImage imageNamed:@"second"];
        UITabBarItem *tab = [[UITabBarItem alloc] initWithTitle:@"Guest List" image:img selectedImage:img];
        _rsvpListTableViewController.tabBarItem = tab;
    }
    return _rsvpListTableViewController;
}

- (ScannerViewController *)scannerViewController {
    if (!_scannerViewController) {
        _scannerViewController = [ScannerViewController new];
        UIImage *img = [UIImage imageNamed:@"first"];
        UITabBarItem *tab = [[UITabBarItem alloc] initWithTitle:@"Scan Tickets" image:img selectedImage:img];
        _scannerViewController.tabBarItem = tab;
    }
    return _scannerViewController;
}

- (RegistrationFormViewController *)registrationViewController {
    if (!_registrationViewController) {
        _registrationViewController = [RegistrationFormViewController new];
        UIImage *img = [UIImage imageNamed:@"second"];
        UITabBarItem *tab = [[UITabBarItem alloc] initWithTitle:@"Register" image:img selectedImage:img];
        _registrationViewController.tabBarItem = tab;
    }
    return _registrationViewController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
