//
//  CheckinTabBarController.h
//  TicketScanner
//
//  Created by Aaron Robinson on 3/14/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckinTabBarController : UITabBarController

// TODO: this number is set before the view controller is pushed onto the navigation stack
@property(nonatomic) NSInteger eventId;

@end
