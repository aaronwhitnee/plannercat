//
//  QRCodeCaptureView.h
//  TicketScanner
//
//  Created by Aaron Robinson on 3/7/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol ScannedDataReadyForUseDelegate;

@interface QRCodeCaptureView : UIView <AVCaptureMetadataOutputObjectsDelegate>

@property(nonatomic) BOOL isReading;
@property(nonatomic) UILabel *scannerMessageLabel;
@property(nonatomic) AVCaptureSession *videoCaptureSession;
@property(nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property(nonatomic, weak) id<ScannedDataReadyForUseDelegate> delegate;

-(instancetype) initWithFrame:(CGRect)frame message:(NSString *)message;
-(BOOL) startReading;
-(void) stopReading;

@end

@protocol ScannedDataReadyForUseDelegate <NSObject>
@required
-(void) acceptScannedData:(NSArray *)metadataObjects;
@end
