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

- (instancetype) initVideoViewWithFrame:(CGRect)frame {
    if ((self = [super init]) == nil) {
        return nil;
    }
    
    self.frame = frame;
    activityIndicatorWidth = frame.size.width;
    self.backgroundColor = [UIColor blackColor];
    
    [self addSubview:self.activityIndicator];
    
    self.isReading = NO;
    
    return self;
}

- (AVCaptureSession *)videoCaptureSession {
    if (!_videoCaptureSession) {
        _videoCaptureSession = [[AVCaptureSession alloc] init];
    }
    return _videoCaptureSession;
}

- (BOOL) startReading {
    self.isReading = YES;
    
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
    
    dispatch_queue_t metadataQueue = dispatch_queue_create("videoQueue", DISPATCH_QUEUE_SERIAL);
    [captureMetadataOutput setMetadataObjectsDelegate:self.delegate queue:metadataQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeQRCode, nil]];
    
    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.videoCaptureSession];
    [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.videoPreviewLayer setFrame:self.layer.bounds];
    [self.layer addSublayer:self.videoPreviewLayer];
    
    [self.videoCaptureSession startRunning];
    
    return YES;
}

- (void) stopReading {
    self.isReading = NO;
    [self.activityIndicator startAnimating];
    [self.videoCaptureSession stopRunning];
    self.videoCaptureSession = nil;
}

- (ActivityIndicatorView *)activityIndicator {
    if(_activityIndicator) {
        return _activityIndicator;
    }
//    CGRect activityIndicatorFrame = CGRectMake(0, 0, activityIndicatorWidth, activityIndicatorWidth);
    _activityIndicator = [[ActivityIndicatorView alloc] initWithFrame:self.frame];
    return _activityIndicator;
}

@end
