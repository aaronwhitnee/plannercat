//
//  CheckinTabBarController.m
//  TicketScanner
//
//  Created by Aaron Robinson on 3/14/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import "CheckinTabBarController.h"

@interface CheckinTabBarController ()

@end

@implementation CheckinTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
