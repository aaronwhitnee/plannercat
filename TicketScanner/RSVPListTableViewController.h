//
//  RSVPListTableViewController.h
//  TicketScanner
//
//  Created by Aaron Robinson on 5/6/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "GuestsDataSource.h"
#import "ActivityIndicatorView.h"
#import "CheckinTabBarController.h"

@interface RSVPListTableViewController : UITableViewController<DataSourceReadyForUseDelegate,UITableViewDelegate,UITableViewDataSource>

- (instancetype) initWithEventID:(NSInteger)eventID;

@end
