//
//  ManagedEventsTableViewController.h
//  TicketScanner
//
//  Created by Aaron Robinson on 5/4/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventsDataSource.h"
#import "ActivityIndicatorView.h"
#import "CheckinTabBarController.h"

@interface ManagedEventsTableViewController : UITableViewController<DataSourceReadyForUseDelegate,UITableViewDelegate,UITableViewDataSource>

@end
