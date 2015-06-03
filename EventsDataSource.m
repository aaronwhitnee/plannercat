//
//  EventsDataSource.m
//  TicketScanner
//
//  Created by Aaron Robinson on 5/5/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import "EventsDataSource.h"

@interface EventsDataSource()

@property(nonatomic, strong) NSDictionary *currentUserInfo;
@property(nonatomic, strong) NSDictionary *eventsJSON;
@property(nonatomic, strong) NSMutableArray *allEvents;
@property(nonatomic, strong) ServerCommunicator *webServer;

@end

@implementation EventsDataSource

+ (instancetype)sharedEventsDataSource {
    static EventsDataSource *sharedEvents;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEvents = [[self alloc] initPrivate];
    });
    
    return sharedEvents;
}

// Never call init!
- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[EventsDataSource sharedEventsDataSource]"
                                 userInfo:nil];
    return nil;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        // Attempt to fetch events data from disk
        NSString *path = [self eventsArchivePath];
        _allEvents = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        // If archive is empty, init a new array and download new data
        if (!_allEvents) {
            NSLog(@"Downloading new events data...");
            _allEvents = [NSMutableArray new];
            _eventsDataReadyForUse = NO;
            [self.webServer performServerRequestType:@"events" withData:self.currentUserInfo];
        }
        // If array was unarchived, it's now ready for use
        else {
            NSLog(@"Fetched events data from disk...");
            _eventsDataReadyForUse = YES;
        }
        
        // Save events data to disk when entering background
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(saveEventsData)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    
    return self;
}

#pragma mark - Archiving

- (BOOL)saveEventsData {
    NSLog(@"saving user events data to disk...");
    NSString *path = [self eventsArchivePath];
    return [NSKeyedArchiver archiveRootObject:self.allEvents toFile:path];
}

- (NSString *)eventsArchivePath {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingPathComponent:@"events.archive"];
}

- (NSDictionary *)currentUserInfo {
    if (!_currentUserInfo) {
        NSNumber *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"appUserID"];
        _currentUserInfo = [NSDictionary dictionaryWithObjects:@[userID] forKeys:@[@"userID"]];
    }
    return _currentUserInfo;
}

- (NSInteger)numberOfEvents {
    return [self.allEvents count];
}

- (Event *)eventAtIndex:(NSInteger)index {
    if (index >= [self.allEvents count]) {
        return nil;
    }
    return [self.allEvents objectAtIndex:index];
}

- (ServerCommunicator *)webServer {
    if (!_webServer) {
        _webServer = [[ServerCommunicator alloc] init];
        _webServer.delegate = self;
    }
    return _webServer;
}

#pragma mark - ConnectionFinishedDelegate method

- (void)handleServerResponse:(NSDictionary *)response {
    NSError *jsonError;
    NSString *eventsJSONString = [response valueForKey:@"eventsJsonString"];
    NSData *eventsData = [eventsJSONString dataUsingEncoding:NSUTF8StringEncoding];
    self.eventsJSON = [NSJSONSerialization JSONObjectWithData:eventsData options:kNilOptions error:&jsonError];
    
    if (jsonError) {
        NSLog(@"%s: Badly formed JSON string. %@", __func__, [jsonError localizedDescription]);
        return;
    }
    
    [self generateEventsFromJSON];
    
    self.eventsDataReadyForUse = YES;

    if( [self.delegate respondsToSelector:@selector(dataSourceReadyForUse:)]) {
        [self.delegate performSelector:@selector(dataSourceReadyForUse:) withObject:self];
    }
}

- (void)generateEventsFromJSON {
    for (NSDictionary *eventTuple in self.eventsJSON) {
        Event *event = [[Event alloc] initWithDictionary:eventTuple];
        [self.allEvents addObject:event];
    }
    self.eventsJSON = nil;
}

@end
