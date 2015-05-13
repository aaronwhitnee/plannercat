//
//  Guest.m
//  TicketScanner
//
//  Created by Aaron Robinson on 5/7/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import "Guest.h"

@interface Guest()

@property(nonatomic,strong) NSMutableDictionary *guestAttributes;
@property(nonatomic, strong) UIImage *smallSizeUserImage;

@end

enum {SMALL_FONT_SIZE = 12, LARGE_FONT_SIZE = 18, THUMBNAIL_WIDTH = 60};

@implementation Guest

- (instancetype) initWithDictionary:(NSDictionary *)guestDictionary {
    self = [super init];
    if (self) {
        self.guestAttributes = [NSMutableDictionary dictionaryWithDictionary:guestDictionary];
    }
    return self;
}

#pragma mark - NSCoding Archiving methods

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        [aDecoder decodeObjectForKey:@"guestAttributes"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.guestAttributes forKey:@"guestAttributes"];
}

- (UIImage *)thumbnailImage {
    if (!_thumbnailImage) {
        [self generateThumbnailImage];
    }
    return _thumbnailImage;
}

- (void)generateThumbnailImage {
    NSLog(@"began drawing thumbnail image....");

    NSURL *url = [NSURL URLWithString:[self photoURL]];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:imageData];
    
    CGSize originalImageSize = image.size;
    
    // The rectangle of the thumbnail
    CGRect newRect = CGRectMake(0, 0, THUMBNAIL_WIDTH, THUMBNAIL_WIDTH);
    
    // Figure out a scaling ratio to make sure the same aspect ratio is maintained
    float ratio = MAX(newRect.size.width / originalImageSize.width,
                      newRect.size.height / originalImageSize.height);
    
    // Create a transparent bitmap context with a scaling factor equal to that of the screen
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0);
    
    // Create a path that is an inscribed circle
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:newRect];
    
    // Make all subsequent drawing clip to this rounded rectangle
    [path addClip];
    
    // Center the image in the thumbnail rectangle
    CGRect projectRect;
    projectRect.size.width = ratio * originalImageSize.width;
    projectRect.size.height = ratio * originalImageSize.height;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2.0;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2.0;
    
    // Draw the image on it
    [image drawInRect:projectRect];
    
    // Get the image from the image context - save it as the thumbnail
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    self.thumbnailImage = smallImage;
    
    // Cleanup image context resources
    UIGraphicsEndImageContext();
    NSLog(@"finished drawing image.");
}

- (void)addValue:(NSString *)attrVal forAttribute:(NSString *)attrName {
    [self.guestAttributes setObject:attrVal forKey:attrName];
}

- (id)getValueForAttribute:(NSString *)attribute {
    return [self.guestAttributes valueForKey:attribute];
}

#pragma mark - Guest Attributes

- (NSInteger)userID {
    return [[self getValueForAttribute:@"id"] integerValue];
}

- (NSString *)firstName {
    return [self getValueForAttribute:@"firstName"];
}

- (NSString *)lastName {
    return [self getValueForAttribute:@"lastName"];
}

- (NSString *)email {
    return [self getValueForAttribute:@"email"];
}

- (NSString *)photoURL {
    // return [self getValueForAttribute:@"photo_url"];
    // Currently set to a randomly generated cat photo
    return @"http://lorempixel.com/200/200/cats/";
}

#pragma mark - Guest Attributed Strings for List Entry

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
    NSMutableAttributedString *name = [[self nameForListEntry] mutableCopy];
    NSMutableAttributedString *email = [[self emailForListEntry] mutableCopy];
    
    [name replaceCharactersInRange: NSMakeRange(name.length, 0) withString: @"\n"];
    [email replaceCharactersInRange: NSMakeRange(email.length, 0) withString:@"\n"];
    [name appendAttributedString:email];
    
    return name;
}

- (NSAttributedString *)nameForListEntry {
    UIFont *titleFont = [UIFont boldSystemFontOfSize:LARGE_FONT_SIZE];
    UIColor *foregroundColor = [UIColor blackColor];
    
    NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           titleFont, NSFontAttributeName,
                                           foregroundColor, NSForegroundColorAttributeName, nil];
    
    NSString *fullName = [NSString stringWithFormat:@"%@, %@", [self lastName], [self firstName]];
    NSMutableAttributedString *attributedTitleString = [[NSMutableAttributedString alloc] initWithString:fullName attributes:fontAttributes];
    
    return attributedTitleString;
}

- (NSAttributedString *)emailForListEntry {
    NSString *email = [self email];
    return [self compose:email withBoldPrefix:@""];
}

@end
