//
//  ScannerViewController.m
//  TicketScanner
//
//  Created by Aaron Robinson on 2/26/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import "ScannerViewController.h"
#include "ActivityIndicatorView.h"

@interface ScannerViewController ()

@property(nonatomic) NSArray *studentAttributes;

@property(nonatomic) NSURL *postURL;
@property(nonatomic) QRCodeCaptureView *scannerView;
@property(nonatomic) ServerCommunicator *webServer;

@property(nonatomic) UIButton *startStopButton;
@property(nonatomic, strong, readwrite) AVAudioPlayer *whistleSound;
@property(nonatomic, strong) UILabel *firstNameLabel;
@property(nonatomic, strong) UILabel *lastNameLabel;

@end

@implementation ScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect window = [[UIScreen mainScreen] applicationFrame];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
    
    self.postURL = [NSURL URLWithString:@"https://docs.google.com/forms/d/1-q7M81pv8Q_c0XazDr-mrhUxWfN5nvub71VH_pA-JJk/formResponse"];
    
    self.webServer = [ServerCommunicator sharedDatabase];
    
//    CGRect scannerViewFrame = CGRectMake(0, 20, window.size.width, window.size.width);
    CGRect scannerViewFrame = window;
    self.scannerView = [[QRCodeCaptureView alloc] initWithFrame:scannerViewFrame message:@"Tap SCAN Button"];
    self.scannerView.delegate = self;
    [self.view addSubview:self.scannerView];
    
//    self.startStopButton.center = CGPointMake(window.size.width / 2, window.size.height - 120);
//    [self.startStopButton addTarget:self action:@selector(startStopReading) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.startStopButton];
    
    [self.view addSubview:self.firstNameLabel];
    [self.view addSubview:self.lastNameLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (ServerCommunicator *) webServer {
    if (!_webServer) {
        _webServer = [[ServerCommunicator alloc] init];
        _webServer.delegate = self;
    }
    return _webServer;
}

-(UIButton *) startStopButton {
    if (_startStopButton) {
        return _startStopButton;
    }
    CGRect buttonFrame = CGRectMake(0, 0, 100, 100);
    _startStopButton = [[UIButton alloc] initWithFrame:buttonFrame];
    [_startStopButton setTitle:@"SCAN" forState:UIControlStateNormal];
    _startStopButton.titleLabel.textColor = [UIColor whiteColor];
    _startStopButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _startStopButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:1.5];
    _startStopButton.backgroundColor = [UIColor colorWithRed:0 green:100.0/255.0 blue:180.0/255.0 alpha:1.0];
    _startStopButton.clipsToBounds = YES;
    _startStopButton.layer.cornerRadius = buttonFrame.size.width / 2;
    _startStopButton.layer.borderWidth = buttonFrame.size.width * 0.03;
    _startStopButton.layer.borderColor = [UIColor colorWithRed:0 green:136.0/255.0 blue:247.0/255.0 alpha:1.0].CGColor;
    
    return _startStopButton;
}

-(UILabel *) firstNameLabel {
    if (_firstNameLabel) {
        return _firstNameLabel;
    }
    _firstNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    _firstNameLabel.textColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0];
    _firstNameLabel.center = CGPointMake(self.view.frame.size.width / 2.0, CGRectGetMaxY(self.scannerView.frame) + 20);
    _firstNameLabel.textAlignment = NSTextAlignmentCenter;
    _firstNameLabel.font = [UIFont systemFontOfSize:25 weight:1.0];
    
    return _firstNameLabel;
}

-(UILabel *) lastNameLabel {
    if (_lastNameLabel) {
        return _lastNameLabel;
    }
    _lastNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    _lastNameLabel.textColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0];
    _lastNameLabel.center = CGPointMake(self.view.frame.size.width / 2.0, CGRectGetMaxY(self.scannerView.frame) + 50);
    _lastNameLabel.textAlignment = NSTextAlignmentCenter;
    _lastNameLabel.font = [UIFont systemFontOfSize:25 weight:1.0];
    
    return _lastNameLabel;
}

-(void) startStopReading {
    self.webServer.delegate = self;

    if (!self.scannerView.isReading) {
        if ([self.scannerView startReading]) {
            self.startStopButton.alpha = 0.2;
            self.startStopButton.userInteractionEnabled = NO;
        }
    }
    else {
        [self.scannerView stopReading];
        self.startStopButton.alpha = 1.0;
        self.startStopButton.userInteractionEnabled = YES;
    }
}

-(void) studentDataDidFinishUploading {
    [self playWhistleSound];
    [self startStopReading];
    NSLog(@"Scanned data uploaded to database successfully.");
}

-(void) acceptScannedData:(NSArray *)metadataObjects {
    // TODO: play "beep" sound for valid/successful scan here...
    
    // Parse the scanned metadata string, split it into separate objects/strings
    [self serializeScannedMetadata:metadataObjects];
    
    [self.webServer postData:self.studentAttributes toURL:self.postURL];
    
    self.firstNameLabel.text = self.studentAttributes[0];
    self.lastNameLabel.text = self.studentAttributes[1];
}

-(void) serializeScannedMetadata:(NSArray *)metadata {
    // TODO: split scanned data string into separate objects
    NSLog(@"Scanned Data: %@", metadata);
    self.studentAttributes = metadata;
}

- (AVAudioPlayer *)whistleSound {
    if (!_whistleSound) {
        // Prepare audio file to play
        NSString *audioFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"whistle.wav"];
        NSURL *whistleUrl = [NSURL fileURLWithPath:audioFilePath];
        NSError *error;
        
        _whistleSound = [[AVAudioPlayer alloc] initWithContentsOfURL:whistleUrl error:&error];
        NSLog(@"%@", error);
    }
    return _whistleSound;
}

-(void) playWhistleSound {
    [self.whistleSound prepareToPlay];
    [self.whistleSound play];
}

@end
