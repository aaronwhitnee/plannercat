//
//  Guest.h
//  TicketScanner
//
//  Created by Aaron Robinson on 5/7/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface Guest : NSObject

@property(nonatomic, strong) UIImage *thumbnailImage;

-(instancetype) initWithDictionary:(NSDictionary *)guestDictionary;

-(void) setThumbnailFromImage:(UIImage *)image;
-(void) addValue:(NSString *)attrVal forAttribute:(NSString *)attrName;
-(id) getValueForAttribute:(NSString *)attribute;

-(NSAttributedString *)descriptionForListEntry;
-(UIImage *) smallSizeUserImage;

-(NSInteger) userID;
-(NSString *) firstName;
-(NSString *) lastName;
-(NSString *) email;
-(NSString *) photoURL;

@end
