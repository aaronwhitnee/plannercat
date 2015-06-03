//
//  GuestsDataSource.m
//  TicketScanner
//
//  Created by Aaron Robinson on 5/7/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import "GuestsDataSource.h"

@interface GuestsDataSource()

@property(nonatomic, strong) NSNumber *currentEventID;
@property(nonatomic, strong) NSDictionary *currentEventInfo;

@property(nonatomic, strong) NSDictionary *guestsJSON;
@property(nonatomic, strong) NSMutableArray *allGuests;
@property(nonatomic, strong) ServerCommunicator *webServer;

@end

@implementation GuestsDataSource

- (instancetype)initWithGuestsForEvent:(NSInteger)eventID {
    self = [super init];
    if (self) {
        _currentEventID = [NSNumber numberWithInteger:eventID];

        NSString *path = [self guestsArchivePath];
        _allGuests = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        // If archive is empty, init a new array with new downloaded data
        if (!_allGuests) {
            NSLog(@"Downloading guests data for event %@...", self.currentEventID);
            _allGuests = [NSMutableArray new];
            _guestsDataReadyForUse = NO;
            [self.webServer performServerRequestType:@"guests" withData:self.currentEventInfo];
        }
        else {
            NSLog(@"Fetched from disk: guests data for event %@...", self.currentEventID);
            _guestsDataReadyForUse = YES;
        }
        // Save guests data to disk when app enters background
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(saveGuestsData)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        // Unregister for notifications and clear cache upon logout
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userLogout:)
                                                     name:@"userLogout"
                                                   object:nil];
    }
    
    return self;
}

- (void)userLogout:(NSNotification *)notification {
    NSLog(@"Unregistering GuestsDataSource for UIApplicationDidEnterBackgroundNotification...");
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    [self clearGuestsData];
}

- (BOOL)saveGuestsData {
    NSLog(@"saving guests data for event %@...", self.currentEventID);
    NSString *path = [self guestsArchivePath];
    return [NSKeyedArchiver archiveRootObject:self.allGuests toFile:path];
}

- (BOOL)clearGuestsData {
    NSLog(@"deleting from disk: guests data for event %@...", self.currentEventID);
    NSString *path = [self guestsArchivePath];
    return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (NSString *)guestsArchivePath {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    NSString *path = [NSString stringWithFormat:@"guests%@.archive", self.currentEventID];
    
    return [documentDirectory stringByAppendingPathComponent:path];
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
//        dispatch_queue_t generateThumbnailQueue = dispatch_queue_create("Create Thumbnail Image", NULL);
//        dispatch_async(generateThumbnailQueue, ^{
//            [guest generateThumbnailImage];
//        });
        [self.allGuests addObject:guest];
    }
    self.guestsJSON = nil;
    self.guestsDataReadyForUse = YES;
}


@end
