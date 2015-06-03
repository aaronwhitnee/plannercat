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
@property(nonatomic, strong) NSMutableURLRequest *request;
@property(nonatomic, strong) NSDictionary *jsonResponse;
@property(nonatomic, strong) NSMutableData *receivedData;
@property(nonatomic) NSURLConnection *connection;

@end

@implementation ServerCommunicator

- (NSMutableData *)receivedData {
    if (!_receivedData) {
        _receivedData = [NSMutableData new];
    }
    return _receivedData;
}

- (NSDictionary *)jsonResponse {
    if (!_jsonResponse) {
        _jsonResponse = [NSDictionary new];
    }
    return _jsonResponse;
}

- (void)performServerRequestType:(NSString *)requestType withData:(NSDictionary *)data
{
    if (self.connection) {
        [self.connection cancel];
    }
    
    // Generate JSON data
    NSError *jsonError;
    NSDictionary *requestData = [NSDictionary dictionaryWithObjects:@[requestType, data] forKeys:@[@"requestType", @"request"]];
    NSData *jsonRequestData = [NSJSONSerialization dataWithJSONObject:requestData
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
    [self.request setValue:[NSString stringWithFormat:@"%lu", jsonRequestData.length] forHTTPHeaderField:@"Content-Length"];
    self.request.HTTPBody = jsonRequestData;
    
    self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"%s: %@", __func__, response);
    self.jsonResponse = nil;
    self.receivedData = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"Received %d bytes of data.", (int)[data length]);
    [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *jsonError;
    NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:self.receivedData options:kNilOptions error:&jsonError];
    NSLog(@"Received data: %@", responseJSON);
    
    if ([self.delegate respondsToSelector:@selector(handleServerResponse:)]) {
        self.jsonResponse = [self generateJSONWithReceivedData];
        if (self.jsonResponse == nil) {
            NSLog(@"No data has been received.");
        }
        [self.delegate performSelector:@selector(handleServerResponse:) withObject:self.jsonResponse];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection Failed: %@", error);
    self.jsonResponse = nil;
    self.receivedData = nil;
}

- (NSDictionary *)generateJSONWithReceivedData {
    if (self.receivedData == nil) {
        return nil;
    }
    NSError *jsonError;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:self.receivedData options:kNilOptions error:&jsonError];
    if (jsonError) {
        NSLog(@"%s: Cannot generate JSON from server response", __func__);
        return nil;
    }
    return json;
}


@end
