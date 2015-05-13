//
//  EventsDataSource.h
//  TicketScanner
//
//  Created by Aaron Robinson on 5/5/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataSourceReadyForUseDelegate.h"
#import "ServerCommunicator.h"
#import "Event.h"

@protocol DataSourceReadyForUseDelegate;

@interface EventsDataSource : NSObject <ConnectionFinishedDelegate>

@property(nonatomic, weak) id <DataSourceReadyForUseDelegate> delegate;
@property(nonatomic) BOOL eventsDataReadyForUse;

+ (instancetype)sharedEventsDataSource;
- (BOOL)saveEventsData;
- (NSInteger)numberOfEvents;
- (Event *)eventAtIndex:(NSInteger)index;

@end
