//
//  DataSourceReadyForUseDelegate.h
//  TicketScanner
//
//  Created by Aaron Robinson on 5/5/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#ifndef TicketScanner_DataSourceReadyForUseDelegate_h
#define TicketScanner_DataSourceReadyForUseDelegate_h

#import "ServerCommunicator.h"

@protocol DataSourceReadyForUseDelegate<NSObject>

@required

- (void) dataSourceReadyForUse: (id<ConnectionFinishedDelegate>) dataSource;

@end

#endif
