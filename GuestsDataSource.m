//
//  GuestsDataSource.m
//  TicketScanner
//
//  Created by Aaron Robinson on 5/7/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import "GuestsDataSource.h"

@interface GuestsDataSource()

#warning move currentEventID to external CurrentEventInfo singleton
@property(nonatomic, strong) NSNumber *currentEventID;
@property(nonatomic, strong) NSDictionary *currentEventInfo;

@property(nonatomic, strong) NSDictionary *guestsJSON;
@property(nonatomic, strong) NSMutableArray *allGuests;
@property(nonatomic, strong) ServerCommunicator *webServer;

@end

@implementation GuestsDataSource

- (instancetype) initWithGuestsForEvent:(NSInteger)eventID {
    self = [super init];
    if (self) {
        self.currentEventID = [NSNumber numberWithInteger:eventID];
        self.webServer.delegate = self;
        self.guestsDataReadyForUse = NO;
        [self.webServer performServerRequestType:@"guests" withData:self.currentEventInfo];
    }
    return self;
}

- (NSDictionary *)currentEventInfo {
    if (!_currentEventInfo) {
        _currentEventInfo = [NSDictionary dictionaryWithObjects:@[self.currentEventID] forKeys:@[@"eventID"]];
    }
    return _currentEventInfo;
}

- (NSInteger) numberOfGuests {
    return [self.allGuests count];
}

- (NSMutableArray *)getAllGuests {
    return self.allGuests;
}

- (NSMutableArray *)allGuests {
    if (!_allGuests) {
        _allGuests = [NSMutableArray new];
    }
    return _allGuests;
}

- (Guest *)guestAtIndex:(NSInteger)index {
    if (index >= [self.allGuests count]) {
        return nil;
    }
    return [self.allGuests objectAtIndex:index];
}

- (ServerCommunicator *)webServer {
    if (!_webServer) {
        _webServer = [[ServerCommunicator alloc] init];
        _webServer.delegate = self;
    }
    return _webServer;
}

#pragma mark - ConnectionFinishedDelegate methods

- (void)handleServerResponse:(NSDictionary *)response {
    NSError *jsonError;
    NSString *eventsJSONString = [response valueForKey:@"guestsJsonString"];
    NSData *eventsData = [eventsJSONString dataUsingEncoding:NSUTF8StringEncoding];
    self.guestsJSON = [NSJSONSerialization JSONObjectWithData:eventsData options:kNilOptions error:&jsonError];
    
    if (jsonError) {
        NSLog(@"%s: Badly formed JSON string. %@", __func__, [jsonError localizedDescription]);
        return;
    }
    
    [self processGuestsJSON];
    
    if( [self.delegate respondsToSelector:@selector(dataSourceReadyForUse:)]) {
        [self.delegate performSelector:@selector(dataSourceReadyForUse:) withObject:self];
    }
}

- (void) processGuestsJSON {
    for (NSDictionary *guestTuple in self.guestsJSON) {
        Guest *guest = [[Guest alloc] initWithDictionary:guestTuple];
        [self.allGuests addObject:guest];
    }
    self.guestsJSON = nil;
    self.guestsDataReadyForUse = YES;
}


@end
