//
//  ManualCheckinForm.m
//  TicketScanner
//
//  Created by Aaron Robinson on 3/11/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import "ManualCheckinForm.h"

@implementation ManualCheckinForm

- (NSArray *) fields {
    
    NSMutableArray *fieldsArray = [[NSMutableArray alloc] init];
    
    [fieldsArray addObject: @{FXFormFieldKey: @"firstName",
                              FXFormFieldPlaceholder: @"First Name",
                              FXFormFieldTitle: @"",
                              FXFormFieldHeader: @"Student Name",
                              FXFormFieldDefaultValue: @"",
                              FXFormFieldType: FXFormFieldTypeText,
                              @"backgroundColor": [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4],
                              @"textColor": [UIColor whiteColor]}];
    
    [fieldsArray addObject: @{FXFormFieldKey: @"lastName",
                              FXFormFieldPlaceholder: @"Last Name",
                              FXFormFieldTitle: @"",
                              FXFormFieldDefaultValue: @"",
                              FXFormFieldType: FXFormFieldTypeText,
                              @"backgroundColor": [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]}];
    
    [fieldsArray addObject: @{FXFormFieldKey: @"email",
                              FXFormFieldPlaceholder: @"example@domain.com",
                              FXFormFieldTitle: @"",
                              FXFormFieldHeader: @"Email Address",
                              FXFormFieldDefaultValue: @"",
                              FXFormFieldType: FXFormFieldTypeEmail,
                              @"backgroundColor": [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]}];
    
    [fieldsArray addObject: @{FXFormFieldKey: @"enrollmentType",
                              FXFormFieldTitle: @"",
                              FXFormFieldHeader: @"Freshman or Transfer?",
                              FXFormFieldOptions: @[@"Freshman", @"Transfer"],
                              FXFormFieldDefaultValue: @"",
                              FXFormFieldCell: [FXFormOptionSegmentsCell class],
                              @"backgroundColor": [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]}];
    
    return fieldsArray;
}

-(NSArray *) extraFields {
    return @[
             @{FXFormFieldTitle: @"SUBMIT",
               FXFormFieldHeader: @"",
               FXFormFieldAction: @"submitManualCheckinForm:",
               @"backgroundColor": [UIColor colorWithRed:0 green:100.0/255.0 blue:180.0/255.0 alpha:1.0],
               @"textLabel.font": [UIFont systemFontOfSize:20 weight:1.5],
               @"textLabel.textColor": [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0]}
             ];
}

@end
