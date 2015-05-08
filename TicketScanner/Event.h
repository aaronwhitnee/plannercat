//
//  Event.h
//  TicketScanner
//
//  Created by Aaron Robinson on 5/5/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface Event : NSObject

-(instancetype) initWithDictionary:(NSDictionary *) eventDictionary;

-(void) addValue:(NSString *)attrVal forAttribute:(NSString *)attrName;
-(id) getValueForAttribute:(NSString *)attribute;

-(NSAttributedString *)descriptionForListEntry;

-(NSInteger) eventID;
-(NSString *) title;
-(NSString *) venueName;
-(NSString *) startDate;
-(NSString *) endDate;
-(NSString *) description;
-(NSString *) eventType;

@end
