//
//  LoginViewController.m
//  TicketScanner
//
//  Created by Aaron Robinson on 5/3/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property(nonatomic, strong) ActivityIndicatorView *activityIndicator;
@property(nonatomic, strong) UIButton *submitButton;
@property(nonatomic, strong) UITextField *userEmailField;
@property(nonatomic, strong) UITextField *userPasswordField;
@property(nonatomic, strong) ServerCommunicator *webServer;

@end

static float FIELD_WIDTH = 250;
static float FIELD_HEIGHT = 60;

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // you ain't goin' nowhere till you login first!
    self.navigationController.navigationBarHidden = YES;
    
    [self.view addSubview: self.activityIndicator];
    [self.view addSubview:self.userEmailField];
    [self.view addSubview:self.userPasswordField];
    
    [self.view addSubview:self.submitButton];
    [self.submitButton addTarget:self action:@selector(didTapSubmitButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void) viewDidAppear:(BOOL)animated {
    [self.userPasswordField becomeFirstResponder];
    [self.userEmailField becomeFirstResponder];
}

- (void) didTapSubmitButton:(id) sender{
    // Show pretty spinny thingy while waiting for response from server
    [self.activityIndicator startAnimating];
    self.submitButton.alpha = 0.5;
    
    // Initialize data for server request
    NSString *reqType = @"login";
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[@"admin@plannercat.com", @"runnitt"]
                                                         forKeys:@[@"email", @"password"]];
    
    // Post login information to server
    [self.webServer performServerRequestType:reqType withData:userInfo];
}

#pragma mark - ConnectionFinishedDelegate protocol method

// Inspects response for valid login
-(void) handleServerResponse:(NSDictionary *)response {
    self.submitButton.alpha = 1.0;

    // Take user to main menu on successful login
    if ([[response valueForKey:@"valid"] integerValue] == 1 &&
        [[response valueForKey:@"status"] isEqualToString:@"ok"]) {
        NSLog(@"Login successful!");
        NSInteger userId = [[response valueForKey:@"userID"] integerValue];
        NSString *userEmail = [response valueForKey:@"email"];
        [[NSUserDefaults standardUserDefaults] setValue:@(userId) forKey:@"appUserID"];
        [[NSUserDefaults standardUserDefaults] setValue:userEmail forKey:@"appUserEmail"];
        
        [self.activityIndicator stopAnimating];
        MainMenuTableViewController *mainMenu = [[MainMenuTableViewController alloc] init];
        [self.navigationController pushViewController:mainMenu animated:YES];
    }
    // Valid login, but with server error
    else if ([[response valueForKey:@"valid"] integerValue] == 1 &&
             [[response valueForKey:@"status"] isEqualToString:@"error"]) {
        NSLog(@"Error logging in.");
    }
    else {
        NSLog(@"Invalid login.");
    }
}

- (ServerCommunicator *) webServer {
    if (!_webServer) {
        _webServer = [[ServerCommunicator alloc] init];
        _webServer.delegate = self;
    }
    return _webServer;
}

- (ActivityIndicatorView *)activityIndicator {
    if (!_activityIndicator) {
        _activityIndicator = [[ActivityIndicatorView alloc] initWithFrame:self.view.frame];
    }
    return _activityIndicator;
}

- (UITextField *) userEmailField {
    if (!_userEmailField) {
        CGRect frame = CGRectMake(0, 0, FIELD_WIDTH, FIELD_HEIGHT);
        _userEmailField = [[UITextField alloc] initWithFrame:frame];
        _userEmailField.center = CGPointMake(self.view.frame.size.width / 2.0,
                                                   self.view.frame.size.height / 2.0);
        _userEmailField.borderStyle = UITextBorderStyleBezel;
        _userEmailField.backgroundColor = [UIColor clearColor];
        
        _userEmailField.placeholder = @"Email";
        _userEmailField.textAlignment = NSTextAlignmentCenter;
    }
    return _userEmailField;
}

- (UITextField *) userPasswordField {
    if (!_userPasswordField) {
        CGRect frame = CGRectMake(0, 0, FIELD_WIDTH, FIELD_HEIGHT);
        _userPasswordField = [[UITextField alloc] initWithFrame:frame];
        _userPasswordField.center = CGPointMake(self.view.frame.size.width / 2.0,
                                             (self.view.frame.size.height / 2.0) + 80);
        _userPasswordField.borderStyle = UITextBorderStyleBezel;
        _userPasswordField.backgroundColor = [UIColor clearColor];
        
        _userPasswordField.placeholder = @"Password";
        _userPasswordField.textAlignment = NSTextAlignmentCenter;
        _userPasswordField.keyboardType = UIKeyboardTypeEmailAddress;
        _userPasswordField.secureTextEntry = YES;
    }
    return _userPasswordField;
}

- (UIButton *) submitButton {
    if (!_submitButton) {
        CGRect buttonFrame = CGRectMake((self.view.frame.size.width - FIELD_WIDTH) / 2.0, CGRectGetMaxY(self.userPasswordField.frame) + 20,
                                        FIELD_WIDTH, 40);
        _submitButton = [[UIButton alloc] initWithFrame: buttonFrame];
        _submitButton.backgroundColor = [UIColor blueColor];
        [_submitButton setTitle:@"Login" forState:UIControlStateNormal];
        _submitButton.titleLabel.textColor = [UIColor whiteColor];
    }
    return _submitButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
