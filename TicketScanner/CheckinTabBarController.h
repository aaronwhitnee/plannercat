//
//  CheckinTabBarController.h
//  TicketScanner
//
//  Created by Aaron Robinson on 3/14/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "RSVPListTableViewController.h"
#import "ScannerViewController.h"
#import "ManualCheckinFormViewController.h"

@interface CheckinTabBarController : UITabBarController

-(instancetype) initWithEvent:(Event *)event;

@end
