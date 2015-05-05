//
//  DatabaseCommunicator.m
//  TicketScanner
//
//  Created by Aaron Robinson on 3/5/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import "DatabaseCommunicator.h"

@interface DatabaseCommunicator()
@property(nonatomic) NSURL *url;
@property(nonatomic) NSMutableURLRequest *request;
@property(nonatomic) NSURLConnection *connection;

@property(nonatomic) NSString *postDataBody;
@property(nonatomic) NSString *postDataTail;
@property(nonatomic) NSMutableData *receivedData;

@property(nonatomic) NSString *firstNameEntry;
@property(nonatomic) NSString *lastNameEntry;
@property(nonatomic) NSString *enrollmentTypeEntry;
@property(nonatomic) NSString *emailEntry;
@end

@implementation DatabaseCommunicator

+ (DatabaseCommunicator *) sharedDatabase {
    static dispatch_once_t once;
    static id sharedDatabase;
    dispatch_once(&once, ^{
        sharedDatabase = [[self alloc] init];
    });
    return sharedDatabase;
}

-(void) postData:(NSMutableArray *)data toURL:(NSURL *)url {
    // If there is a connection going on, cancel it
    if (_connection) {
        [_connection cancel];
    }
    
    // init new mutable data (we're not receiving any data in this case)
    //  self.receivedData = [[NSMutableData alloc] init];
    
    // Create post data with attributes scanned from QR code
    self.firstNameEntry = [NSString stringWithFormat:@"entry.280111864=%@", data[0]];
    self.lastNameEntry = [NSString stringWithFormat:@"&entry.704921569=%@", data[1]];
    self.emailEntry = [NSString stringWithFormat:@"&entry.1983486187=%@", data[2]];
    self.enrollmentTypeEntry = [NSString stringWithFormat:@"&entry.213545887=%@", data[3]];
    self.postDataTail = @"&draftResponse=[,,\"0\"]&pageHistory=0&fbzx=0";

    // create POST data string
    self.postDataBody = [NSString stringWithFormat:@"%@%@%@%@%@",
                         self.firstNameEntry, self.lastNameEntry,
                        self.emailEntry, self.enrollmentTypeEntry, self.postDataTail];
    
    // init POST URL that will be fetched
    self.url = url;
    
    // init request from POST URL
    self.request = [NSMutableURLRequest requestWithURL:[self.url standardizedURL]];
    
    // set HTTP method
    [self.request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-type"];
    
    // set POST data of request
    self.request.HTTPBody = [self.postDataBody dataUsingEncoding:NSUTF8StringEncoding];
    self.request.HTTPMethod = @"POST";
    
    // init a connection from request
    self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:YES];
    
    // start the connection
    [self.connection start];
}

-(void) connectionDidFinishLoading:(NSURLConnection *) connection {
    NSLog(@"Finished sending %@ bytes.", @([self.request.HTTPBody length]));
    NSString *dataString = [[NSString alloc] initWithData:self.request.HTTPBody encoding:NSUTF8StringEncoding];
    NSLog(@"%@", dataString);
    if ([self.delegate respondsToSelector:@selector(studentDataDidFinishUploading)]) {
        [self.delegate studentDataDidFinishUploading];
    }
    
}

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"Connection Response: %@", response);
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection Failed: %@", error);
    self.request = nil;
}


@end
