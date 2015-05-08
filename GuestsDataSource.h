//
//  GuestsDataSource.h
//  TicketScanner
//
//  Created by Aaron Robinson on 5/7/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataSourceReadyForUseDelegate.h"
#import "ServerCommunicator.h"
#import "Guest.h"

@protocol DataSourceReadyForUseDelegate;

@interface GuestsDataSource : NSObject<ConnectionFinishedDelegate>

@property(nonatomic, weak) id<DataSourceReadyForUseDelegate> delegate;
@property(nonatomic) BOOL guestsDataReadyForUse;

-(instancetype) initWithGuestsForEvent:(NSInteger)eventID;
-(NSInteger) numberOfGuests;
-(NSMutableArray *) getAllGuests;
-(Guest *) guestAtIndex:(NSInteger)index;

@end
