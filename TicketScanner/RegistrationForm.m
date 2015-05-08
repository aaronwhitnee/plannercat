//
//  RegistrationForm.m
//  TicketScanner
//
//  Created by Aaron Robinson on 3/11/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import "RegistrationForm.h"

@interface RegistrationForm()

@property(nonatomic) NSNumber *currentEventID;
@property(nonatomic, strong) NSDictionary *currentEventInfo;
@property(nonatomic, strong) NSDictionary *registrationFormJSON;
@property(nonatomic, strong) ServerCommunicator *webServer;

@end

@implementation RegistrationForm

-(instancetype) initWithFormForEvent:(NSInteger)eventID {
    self = [super init];
    if (self) {
        self.currentEventID = [NSNumber numberWithInteger:eventID];
        [self.webServer performServerRequestType:@"register" withData:self.currentEventInfo];
    }
    return self;
}


-(NSDictionary *) currentEventInfo {
    if (!_currentEventInfo) {
        _currentEventInfo = [NSDictionary dictionaryWithObjects:@[self.currentEventID] forKeys:@[@"eventID"]];
    }
    return _currentEventInfo;
}

- (ServerCommunicator *) webServer {
    if (!_webServer) {
        _webServer = [[ServerCommunicator alloc] init];
        _webServer.delegate = self;
    }
    return _webServer;
}

# pragma mark - ConnectionFinisehdDelegateMethods

-(void)handleServerResponse:(NSDictionary *)response {
    NSError *jsonError;
    NSString *formJsonString = [response valueForKey:@"eventsJsonString"];
    NSData *eventsData = [formJsonString dataUsingEncoding:NSUTF8StringEncoding];
    self.fields = [NSJSONSerialization JSONObjectWithData:eventsData options:kNilOptions error:&jsonError];
    
    if (jsonError) {
        NSLog(@"%s: Badly formed JSON string. %@", __func__, [jsonError localizedDescription]);
        return;
    }
        
    self.formDataReadyForUse = YES;
    
    if( [self.delegate respondsToSelector:@selector(dataSourceReadyForUse:)]) {
        [self.delegate performSelector:@selector(dataSourceReadyForUse:) withObject:self];
    }
}

//- (NSArray *) fields {
//    
//    NSMutableArray *fieldsArray = [[NSMutableArray alloc] init];
//    
//    [fieldsArray addObject: @{FXFormFieldKey: @"firstName",
//                              FXFormFieldPlaceholder: @"First Name",
//                              FXFormFieldTitle: @"",
//                              FXFormFieldHeader: @"Student Name",
//                              FXFormFieldDefaultValue: @"",
//                              FXFormFieldType: FXFormFieldTypeText,
//                              @"backgroundColor": [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4],
//                              @"textColor": [UIColor whiteColor]}];
//    
//    [fieldsArray addObject: @{FXFormFieldKey: @"lastName",
//                              FXFormFieldPlaceholder: @"Last Name",
//                              FXFormFieldTitle: @"",
//                              FXFormFieldDefaultValue: @"",
//                              FXFormFieldType: FXFormFieldTypeText,
//                              @"backgroundColor": [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]}];
//    
//    [fieldsArray addObject: @{FXFormFieldKey: @"email",
//                              FXFormFieldPlaceholder: @"example@domain.com",
//                              FXFormFieldTitle: @"",
//                              FXFormFieldHeader: @"Email Address",
//                              FXFormFieldDefaultValue: @"",
//                              FXFormFieldType: FXFormFieldTypeEmail,
//                              @"backgroundColor": [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]}];
//    
//    [fieldsArray addObject: @{FXFormFieldKey: @"enrollmentType",
//                              FXFormFieldTitle: @"",
//                              FXFormFieldHeader: @"Freshman or Transfer?",
//                              FXFormFieldOptions: @[@"Freshman", @"Transfer"],
//                              FXFormFieldDefaultValue: @"",
//                              FXFormFieldCell: [FXFormOptionSegmentsCell class],
//                              @"backgroundColor": [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]}];
//    
//    return fieldsArray;
//}

-(NSArray *) extraFields {
    return @[
             @{FXFormFieldTitle: @"SUBMIT",
               FXFormFieldHeader: @"",
               FXFormFieldAction: @"submitRegistrationForm:",
               @"backgroundColor": [UIColor colorWithRed:0 green:100.0/255.0 blue:180.0/255.0 alpha:1.0],
               @"textLabel.font": [UIFont systemFontOfSize:20 weight:1.5],
               @"textLabel.textColor": [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0]}
             ];
}

@end
