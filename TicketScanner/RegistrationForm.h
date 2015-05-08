//
//  RegistrationForm.h
//  TicketScanner
//
//  Created by Aaron Robinson on 3/11/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FXForms.h"
#import "ServerCommunicator.h"
#import "DataSourceReadyForUseDelegate.h"

@protocol DataSourceReadyForUseDelegate;

@interface RegistrationForm : NSObject <FXForm, ConnectionFinishedDelegate>

@property(nonatomic, weak) id<DataSourceReadyForUseDelegate> delegate;
@property(nonatomic) BOOL formDataReadyForUse;

@property(nonatomic) NSArray *fields;
@property(nonatomic, assign) FXFormOptionSegmentsCell *enrollmentType;

@end
