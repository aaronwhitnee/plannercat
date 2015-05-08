//
//  ManualCheckinViewController.m
//  TicketScanner
//
//  Created by Aaron Robinson on 2/26/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "FXForms.h"
#import "RegistrationForm.h"
#import "ServerCommunicator.h"

@interface RegistrationFormViewController : FXFormViewController <DataSourceReadyForUseDelegate>

- (instancetype) initWithEventID:(NSInteger)eventID;

@end