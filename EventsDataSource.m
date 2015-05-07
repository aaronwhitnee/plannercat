//
//  EventsDataSource.m
//  TicketScanner
//
//  Created by Aaron Robinson on 5/5/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import "EventsDataSource.h"

@interface EventsDataSource()

@property(nonatomic) NSNumber *currentUserID;
@property(nonatomic, strong) NSDictionary *currentUserInfo;
@property(nonatomic, strong) NSDictionary *eventsJSON;
@property(nonatomic, strong) NSMutableArray *allEvents;
@property(nonatomic, strong) ServerCommunicator *webServer;

@end

@implementation EventsDataSource

- (instancetype) initWithEventsManagedByUser:(NSInteger)userID {
    self = [super init];
    if (self) {
        self.currentUserID = [NSNumber numberWithInteger:userID];
        self.webServer.delegate = self;
        self.eventsDataReadyForUse = NO;
        [self.webServer performServerRequestType:@"events" withData:self.currentUserInfo];
    }
    return self;
}

- (NSDictionary *) currentUserInfo {
    if (!_currentUserInfo) {
        _currentUserInfo = [NSDictionary dictionaryWithObjects:@[self.currentUserID] forKeys:@[@"userID"]];
    }
    return _currentUserInfo;
}

- (NSInteger) numberOfEvents {
    return [self.allEvents count];
}

- (NSMutableArray *) allEvents {
    if (!_allEvents) {
        _allEvents = [NSMutableArray new];
    }
    return _allEvents;
}

- (NSMutableArray *) getAllEvents {
    return self.allEvents;
}

- (Event *) eventAtIndex:(NSInteger)index {
    if (index >= [self.allEvents count]) {
        return nil;
    }
    return [self.allEvents objectAtIndex:index];
}

- (ServerCommunicator *) webServer {
    if (!_webServer) {
        _webServer = [[ServerCommunicator alloc] init];
        _webServer.delegate = self;
    }
    return _webServer;
}

#pragma mark - ConnectionFinishedDelegate methods

-(void) handleServerResponse:(NSDictionary *)response {
    NSError *jsonError;
    NSString *eventsJSONString = [response valueForKey:@"eventsJsonString"];
    NSData *eventsData = [eventsJSONString dataUsingEncoding:NSUTF8StringEncoding];
    self.eventsJSON = [NSJSONSerialization JSONObjectWithData:eventsData options:kNilOptions error:&jsonError];
    
    if (jsonError) {
        NSLog(@"%s: Badly formed JSON string. %@", __func__, [jsonError localizedDescription]);
        return;
    }
    
    [self processEventsJSON];
    
    self.eventsDataReadyForUse = YES;

    if( [self.delegate respondsToSelector:@selector(dataSourceReadyForUse:)]) {
        [self.delegate performSelector:@selector(dataSourceReadyForUse:) withObject:self];
    }
}

-(void) processEventsJSON {
    for (NSDictionary *eventTuple in self.eventsJSON) {
        Event *event = [[Event alloc] initWithDictionary:eventTuple];
        [self.allEvents addObject:event];
    }
    self.eventsJSON = nil;
    if ([self.delegate respondsToSelector:@selector(dataSourceReadyForUse:)]) {
        [self.delegate performSelector:@selector(dataSourceReadyForUse:) withObject:self];
    }
}

@end
