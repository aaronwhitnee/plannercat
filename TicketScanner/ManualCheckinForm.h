//
//  ManualCheckinForm.h
//  TicketScanner
//
//  Created by Aaron Robinson on 3/11/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FXForms.h"

@interface ManualCheckinForm : NSObject <FXForm>

@property(nonatomic) NSArray *fields;
@property(nonatomic, copy) NSString *firstName;
@property(nonatomic, copy) NSString *lastName;
@property(nonatomic, copy) NSString *email;
@property(nonatomic, assign) FXFormOptionSegmentsCell *enrollmentType;

@end
