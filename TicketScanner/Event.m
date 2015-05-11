//
//  Event.m
//  TicketScanner
//
//  Created by Aaron Robinson on 5/5/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import "Event.h"

@interface Event()

@property(nonatomic, strong) NSMutableDictionary *eventAttributes;

@end

enum {SMALL_FONT_SIZE = 12, LARGE_FONT_SIZE = 18};

@implementation Event

- (instancetype)initWithDictionary:(NSDictionary *)eventDictionary {
    self = [super init];
    if (self) {
        self.eventAttributes = [NSMutableDictionary dictionaryWithDictionary:eventDictionary];
    }
    return self;
}

#pragma mark - NSCoding Archiving methods

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _eventAttributes = [aDecoder decodeObjectForKey:@"eventAttributes"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.eventAttributes forKey:@"eventAttributes"];
}

#pragma mark - Event Attributes

- (void)addValue:(NSString *)attrVal forAttribute:(NSString *)attrName {
    [self.eventAttributes setObject:attrVal forKey:attrName];
}

- (id)getValueForAttribute:(NSString *)attribute {
    return [self.eventAttributes valueForKey:attribute];
}

- (NSInteger)eventID {
    return [[self getValueForAttribute:@"id"] integerValue];
}

- (NSString *)title {
    return [self getValueForAttribute:@"event_title"];
}

- (NSString *)venueName {
    return [self getValueForAttribute:@"venue"];
}

- (NSString *)startDate {
    return [self getValueForAttribute:@"start_date"];
}

- (NSString *)endDate {
    return [self getValueForAttribute:@"end_date"];
}

- (NSString *)eventDescription {
    return [self getValueForAttribute:@"description"];
}

- (NSString *)eventType {
    return [self getValueForAttribute:@"event_type"];
}

#pragma mark - Event Attributed Strings for List Entry

- (NSAttributedString *)compose:(NSString *)str withBoldPrefix:(NSString *)prefix {
    NSMutableAttributedString *attributedString = nil;
    
    UIFont *boldFont = [UIFont boldSystemFontOfSize:SMALL_FONT_SIZE];
    UIFont *regularFont = [UIFont systemFontOfSize:SMALL_FONT_SIZE];
    UIFont *italicFont = [UIFont italicSystemFontOfSize:SMALL_FONT_SIZE];
    UIColor *foregroundColor = [UIColor grayColor];
    
    NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  regularFont, NSFontAttributeName,
                                  foregroundColor, NSForegroundColorAttributeName, nil];
    
    NSDictionary *boldAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                               boldFont, NSFontAttributeName, nil];
    
    if ( [prefix isEqualToString: @""] ) {
        [attrs setObject:italicFont forKey:NSFontAttributeName];
        attributedString = [[NSMutableAttributedString alloc] initWithString:str attributes:attrs];
    }
    else {
        NSString *text = [NSString stringWithFormat:@"%@: %@", prefix, str];
        attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attrs];
        NSRange range = NSMakeRange(0, prefix.length);
        [attributedString setAttributes:boldAttrs range:range];
    }
    
    return attributedString;
}

- (NSAttributedString *)descriptionForListEntry {
    NSMutableAttributedString *title = [[self titleForListEntry] mutableCopy];
    NSMutableAttributedString *time = [[self timeForListEntry] mutableCopy];
    NSMutableAttributedString *location = [[self locationForListEntry] mutableCopy];
    
    [title replaceCharactersInRange: NSMakeRange(title.length, 0) withString: @"\n"];
    [time replaceCharactersInRange: NSMakeRange(time.length, 0) withString:@"\n"];
    [title appendAttributedString:time];
    [title appendAttributedString:location];
    
    return title;
}

- (NSAttributedString *)titleForListEntry {
    UIFont *titleFont = [UIFont boldSystemFontOfSize:LARGE_FONT_SIZE];
    UIColor *foregroundColor = [UIColor blackColor];
    
    NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           titleFont, NSFontAttributeName,
                                           foregroundColor, NSForegroundColorAttributeName, nil];
    
    NSMutableAttributedString *attributedTitleString = [[NSMutableAttributedString alloc] initWithString:[self title] attributes:fontAttributes];
    
    return attributedTitleString;
}

- (NSAttributedString *)timeForListEntry {
    NSString *time = [self startDate];
    return [self compose:time withBoldPrefix:@""];
}

- (NSAttributedString *)locationForListEntry {
    NSString *location = [self venueName];
    return [self compose:location withBoldPrefix:@""];
}

@end
