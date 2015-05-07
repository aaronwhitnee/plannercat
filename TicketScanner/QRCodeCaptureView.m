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

-(instancetype) initVideoViewWithFrame:(CGRect)frame {
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

-(AVCaptureSession *) videoCaptureSession {
    if (!_videoCaptureSession) {
        _videoCaptureSession = [[AVCaptureSession alloc] init];
    }
    return _videoCaptureSession;
}

-(BOOL) startReading {
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
    
    dispatch_queue_t dispatchQueue = dispatch_queue_create("videoQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeQRCode, nil]];
    
    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.videoCaptureSession];
    [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.videoPreviewLayer setFrame:self.layer.bounds];
    [self.layer addSublayer:self.videoPreviewLayer];
    
    [self.videoCaptureSession startRunning];
    
    return YES;
}

-(void) stopReading {
    self.isReading = NO;
    [self.activityIndicator stopAnimating];
    self.videoCaptureSession = nil;
}

// Called when the Scanner has successfully read data from the QR code
-(void) captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection {
    
    if (metadataObjects && [metadataObjects count]) {
        if ([self.delegate respondsToSelector:@selector(acceptScannedData:)]) {
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
