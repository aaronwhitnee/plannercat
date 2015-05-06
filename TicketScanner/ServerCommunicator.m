//
//  ServerCommunicator.m
//  TicketScanner
//
//  Created by Aaron Robinson on 3/5/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import "ServerCommunicator.h"

@interface ServerCommunicator()

@property(nonatomic) NSURL *url;
@property(nonatomic) NSMutableURLRequest *request;
@property(nonatomic) NSDictionary *jsonResponse;
@property(nonatomic) NSMutableData *receivedData;
@property(nonatomic) NSURLConnection *connection;

@end

@implementation ServerCommunicator

- (NSMutableData *) receivedData {
    return _receivedData;
}

- (void)performServerRequestType:(NSString *)requestType withData:(NSDictionary *)data
{
    if (self.connection) {
        [self.connection cancel];
    }
    
    // Generate JSON data
    NSError *jsonError;
    NSDictionary *requestData = [NSDictionary dictionaryWithObjects:@[requestType, data] forKeys:@[@"reqType", @"request"]];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requestData
                                                       options:kNilOptions
                                                         error:&jsonError];
    if (jsonError) {
        NSLog(@"Error generating JSON: %@", jsonError);
        return;
    }
    
    // setting up the POST request
    self.url = [NSURL URLWithString:@"http://marshall.bpwebdesign.com/ios/db-interface.php"];
    self.request = [NSMutableURLRequest requestWithURL:[self.url standardizedURL]];
    self.request.HTTPMethod = @"POST";
    [self.request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [self.request setValue:[NSString stringWithFormat:@"%lu", jsonData.length] forHTTPHeaderField:@"Content-Length"];
    self.request.HTTPBody = jsonData;
    
    self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:YES];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    if ([self.delegate respondsToSelector:@selector(handleServerResponse:)]) {
        self.jsonResponse = [self generateJSONWithReceivedData];
        [self.delegate handleServerResponse:self.jsonResponse];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection Failed: %@", error);
    self.jsonResponse = nil;
    self.receivedData = nil;
}

-(NSDictionary *) generateJSONWithReceivedData {
    NSError *jsonError;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:self.receivedData options:kNilOptions error:&jsonError];
    if (jsonError) {
        NSLog(@"%s: Cannot generate JSON from server response", __func__);
        return nil;
    }
    return json;
}


@end
