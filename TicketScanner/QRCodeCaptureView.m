//
//  QRCodeCaptureView.m
//  TicketScanner
//
//  Created by Aaron Robinson on 3/7/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import "QRCodeCaptureView.h"
#import "ActivityIndicatorView.h"

@interface QRCodeCaptureView() {
    float activityIndicatorWidth;
}

@property(nonatomic) ActivityIndicatorView *activityIndicator;

@end

@implementation QRCodeCaptureView

-(instancetype) initWithFrame:(CGRect)frame message:(NSString *)message{
    if ((self = [super init]) == nil) {
        return nil;
    }
    
    self.frame = frame;
    activityIndicatorWidth = frame.size.width;
    self.backgroundColor = [UIColor blackColor];
    
    [self addSubview:self.activityIndicator];
    
    CGRect messageFrame = CGRectMake(0, 0, frame.size.width * 0.8, 20.0);
    self.scannerMessageLabel = [[UILabel alloc] initWithFrame:messageFrame];
    self.scannerMessageLabel.text = message;
    self.scannerMessageLabel.textColor = [UIColor whiteColor];
    self.scannerMessageLabel.textAlignment = NSTextAlignmentCenter;
    self.scannerMessageLabel.center = CGPointMake(frame.size.width / 2.0, frame.size.height / 2.0);
    
    [self addSubview:self.scannerMessageLabel];
    
    self.isReading = NO;
    self.videoCaptureSession = [[AVCaptureSession alloc] init];
    
    return self;
}

-(BOOL) startReading {
    self.isReading = YES;
    self.scannerMessageLabel.text = @"";
    
    NSError *readingError = [[NSError alloc] init];
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&readingError];
    
    if (!input) {
        NSLog(@"%@", [readingError localizedDescription]);
        return NO;
    }
    
    [self.videoCaptureSession addInput:input];
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.videoCaptureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("videoQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeQRCode, nil]];
    
    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.videoCaptureSession];
    [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.videoPreviewLayer setFrame:self.layer.bounds];
    [self.layer addSublayer:self.videoPreviewLayer];
    
    [self.videoCaptureSession startRunning];
    
//    // Dummy scanned data
//    NSString *firstName = @"Aaron";
//    NSString *lastName = @"Robinson";
//    NSString *email = @"test@test.com";
//    NSString *enrollmentType = @"Transfer";
//    NSArray *dummyObjects = [NSArray arrayWithObjects:firstName, lastName, email, enrollmentType, nil];
//    
//    // Dummy data-capture trigger
//    [self captureOutput:nil didOutputMetadataObjects:dummyObjects fromConnection:nil];
    
    return YES;
}

-(void) stopReading {
    self.isReading = NO;
    [self.activityIndicator stopAnimating];
    self.backgroundColor = [UIColor blackColor];
    self.scannerMessageLabel.text = @"Tap SCAN Button";
}

// Called when the Scanner has successfully read data from the QR code
-(void) captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection {
    
    if (metadataObjects && [metadataObjects count]) {
        // pass scanned metadata (dummy data right now) back to the parent ScannerViewController
        if ([self.delegate respondsToSelector:@selector(acceptScannedData:)]) {
            // show activity indicator AFTER data is scanned and begins its path -> to delegate V.C. -> to database
            [self.activityIndicator startAnimating];
            [self.delegate performSelector:@selector(acceptScannedData:) withObject:metadataObjects];
        }
    }
}

-(ActivityIndicatorView *) activityIndicator {
    if(_activityIndicator) {
        return _activityIndicator;
    }
    CGRect activityIndicatorFrame = CGRectMake(0, 0, activityIndicatorWidth, activityIndicatorWidth);
    _activityIndicator = [[ActivityIndicatorView alloc] initWithFrame:activityIndicatorFrame];
    return _activityIndicator;
}

@end
