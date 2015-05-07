//
//  CheckinTabBarController.m
//  TicketScanner
//
//  Created by Aaron Robinson on 3/14/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import "CheckinTabBarController.h"

@interface CheckinTabBarController ()

@property(nonatomic, strong) Event *currentEvent;
@property(nonatomic, strong) RSVPListTableViewController *rsvpListTableViewController;
@property(nonatomic, strong) ScannerViewController *scannerViewController;
@property(nonatomic, strong) ManualCheckinFormViewController *manualCheckinViewController;

@end

@implementation CheckinTabBarController

- (instancetype) initWithEvent:(Event *)event {
    self = [super init];
    if (self) {
        self.currentEvent = event;
        self.navigationController.navigationBarHidden = YES;
    }
    return self;
}

#pragma mark - Child View Controllers

-(ScannerViewController *) scannerViewController {
    if (!_scannerViewController) {
        _scannerViewController = [[ScannerViewController alloc] init];
        UIImage *img1 = [UIImage imageNamed:@"first"];
        UITabBarItem *firstTab = [[UITabBarItem alloc] initWithTitle:@"Scan Ticket" image:img1 selectedImage:img1];
        _scannerViewController.tabBarItem = firstTab;
    }
    return _scannerViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self addChildViewController:self.rsvpListTableViewController];
    [self addChildViewController:self.scannerViewController];
    [self addChildViewController:self.manualCheckinViewController];
    
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.tabBar setBackgroundImage:transparentImage];
    [self.tabBar setShadowImage:transparentImage];
    self.tabBar.tintColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
