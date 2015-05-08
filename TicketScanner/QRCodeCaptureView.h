//
//  QRCodeCaptureView.h
//  TicketScanner
//
//  Created by Aaron Robinson on 3/7/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface QRCodeCaptureView : UIView

@property(nonatomic) BOOL isReading;
@property(nonatomic) AVCaptureSession *videoCaptureSession;
@property(nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property(nonatomic, weak) id<AVCaptureMetadataOutputObjectsDelegate> delegate;

-(instancetype) initVideoViewWithFrame:(CGRect)frame;
-(BOOL) startReading;
-(void) stopReading;

@end
