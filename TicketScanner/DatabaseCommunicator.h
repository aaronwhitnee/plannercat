//
//  DatabaseCommunicator.h
//  TicketScanner
//
//  Created by Aaron Robinson on 3/5/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ConnectionFinishedDelegate;

@interface DatabaseCommunicator : NSObject <NSURLConnectionDelegate>

@property(nonatomic, weak) id<ConnectionFinishedDelegate> delegate;

+ (DatabaseCommunicator *) sharedDatabase;
- (void) postData:(NSArray *)data toURL:(NSURL *)url;

@end

@protocol ConnectionFinishedDelegate <NSObject>
@required
-(void) studentDataDidFinishUploading;
@end

