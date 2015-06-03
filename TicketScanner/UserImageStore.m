//
//  UserImageStore.m
//  TicketScanner
//
//  Created by Aaron Robinson on 5/13/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import "UserImageStore.h"

@interface UserImageStore()

@property (nonatomic,strong) NSMutableDictionary *imageDictionary;

- (NSString *)imagePathForKey:(NSString *)key;

@end

@implementation UserImageStore

+ (instancetype)sharedStore {
    static UserImageStore *sharedStore;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] initPrivate];
    });
    
    return sharedStore;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[UserImageStore sharedStore]"
                                 userInfo:nil];
    return nil;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        _imageDictionary = [NSMutableDictionary new];
        
        // Clear image cache when memory is low
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearImageCache:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)clearImageCache:(NSNotification *)notification {
    NSLog(@"Erased user images from disk");
    [self.imageDictionary removeAllObjects];
}

- (NSString *)imagePathForKey:(NSString *)key {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingPathComponent:key];
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key {
    self.imageDictionary[key] = image;
    NSString *imagePath = [self imagePathForKey:key];
    
    // Write image to disk as JPEG data
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    [data writeToFile:imagePath atomically:YES];
}

- (UIImage *)imageForKey:(NSString *)key {
    // Attempt to fetch image from dictionary
    UIImage *result = self.imageDictionary[key];
    
    // Attempt to fetch from disk
    if (!result) {
        NSString *imagePath = [self imagePathForKey:key];
        result = [UIImage imageWithContentsOfFile:imagePath];
        if (result) {
            self.imageDictionary[key] = result;
        }
        else {
            // TODO: return a default "error image" instead
            NSLog(@"Error: unable to find %@", imagePath);
        }
    }
    
    // returns nil if not found
    return result;
}

- (void)deleteImageForKey:(NSString *)key {
    if (!key) {
        return;
    }
    [self.imageDictionary removeObjectForKey:key];
    
    NSString *imagePath = [self imagePathForKey:key];
    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
}

@end
