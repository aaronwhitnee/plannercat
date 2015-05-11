//
//  ServerCommunicator.h
//  TicketScanner
//
//  Created by Aaron Robinson on 3/5/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ConnectionFinishedDelegate;

@interface ServerCommunicator : NSObject<NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property(nonatomic, weak) id<ConnectionFinishedDelegate> delegate;

- (void) performServerRequestType:(NSString *)requestType
                         withData:(NSDictionary *)data;

@end

@protocol ConnectionFinishedDelegate <NSObject>
@required
- (void) handleServerResponse:(NSDictionary *)response;
@end

