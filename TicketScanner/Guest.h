//
//  Guest.h
//  TicketScanner
//
//  Created by Aaron Robinson on 5/7/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface Guest : NSObject <NSCoding>

@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, copy) NSString *userKey;

- (instancetype)initWithDictionary:(NSDictionary *)guestDictionary;

- (BOOL)thumbnailImageHasRendered;
- (UIImage *)thumbnailImageWithSize:(CGSize)desiredSize;
- (NSAttributedString *)descriptionForListEntry;

- (NSInteger)userID;
- (NSString *)firstName;
- (NSString *)lastName;
- (NSString *)email;
- (NSString *)photoURL;

@end
