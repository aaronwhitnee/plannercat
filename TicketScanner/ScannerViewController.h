//
//  ScannerViewController.h
//  TicketScanner
//
//  Created by Aaron Robinson on 2/26/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerCommunicator.h"
#import "QRCodeCaptureView.h"

@interface ScannerViewController : UIViewController <ConnectionFinishedDelegate, AVCaptureMetadataOutputObjectsDelegate>


@end

