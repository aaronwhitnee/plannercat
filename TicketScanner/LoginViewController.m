//
//  LoginViewController.m
//  TicketScanner
//
//  Created by Aaron Robinson on 5/3/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) ActivityIndicatorView *activityIndicator;
@property(nonatomic) UIAlertController *alertController; // iOS 8.0+
@property(nonatomic) UIAlertView *alertView; // iOS < 8.0
@property(nonatomic, strong) UIButton *submitButton;
@property(nonatomic, strong) UITextField *activeField;
@property(nonatomic, strong) UITextField *userEmailField;
@property(nonatomic, strong) UITextField *userPasswordField;
@property(nonatomic, strong) ServerCommunicator *webServer;

@end

enum {FIELD_WIDTH = 250, FIELD_HEIGHT = 60, BUTTON_FONT_SIZE = 16, TITLE_FONT_SIZE = 50};

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0 green:100.0/255.0 blue:180.0/255.0 alpha:1.0];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    
    [self.scrollView addSubview: self.activityIndicator];
    [self.scrollView addSubview: self.userEmailField];
    [self.scrollView addSubview: self.userPasswordField];

    [self.scrollView addSubview:self.submitButton];
    [self.submitButton addTarget:self action:@selector(didTapSubmitButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.scrollView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self registerForKeyboardNotifications];
    [self clearTextFields];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self deregisterFromKeyboardNotifications];
    [super viewWillDisappear:animated];
}

- (void)didTapSubmitButton:(id)sender{
    // Show pretty spinny thingy while waiting for response from server
    [self.activityIndicator startAnimating];
    self.submitButton.alpha = 0.5;
    self.submitButton.userInteractionEnabled = NO;
    
    // Initialize data for server request
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[self.userEmailField.text, self.userPasswordField.text]
                                                         forKeys:@[@"email", @"password"]];
    
    // Post login information to server
    [self.webServer performServerRequestType:@"login" withData:userInfo];
}

#pragma mark - ConnectionFinishedDelegate protocol method

// Check response for valid login
- (void) handleServerResponse:(NSDictionary *)response {
    [self.activityIndicator stopAnimating];
    self.submitButton.alpha = 1.0;
    self.submitButton.userInteractionEnabled = YES;

    // Take user to main menu on successful login
    if ([[response valueForKey:@"valid"] integerValue] == 1 &&
        [[response valueForKey:@"status"] isEqualToString:@"ok"]) {
        NSLog(@"Login successful!");
        NSInteger userID = [[response valueForKey:@"userID"] integerValue];
        NSString *userEmail = [response valueForKey:@"email"];
        [[NSUserDefaults standardUserDefaults] setValue:@(userID) forKey:@"appUserID"];
        [[NSUserDefaults standardUserDefaults] setValue:userEmail forKey:@"appUserEmail"];
        
        [self clearTextFields];
        
        [self.navigationController popViewControllerAnimated:NO];
        if ([self.delegate respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
            [self.delegate dismissViewControllerAnimated:YES completion:nil];
        }
    }
    // Valid login, but with server error
    else if ([[response valueForKey:@"valid"] integerValue] == 1 &&
             [[response valueForKey:@"status"] isEqualToString:@"error"]) {
        NSLog(@"Error logging in.");
    }
    else {
        NSLog(@"Invalid login.");
        [self displayAlertWithTitle:@"Invalid Login"];
    }
}

- (ServerCommunicator *)webServer {
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

# pragma mark - UI Alerts

- (void)displayAlertWithTitle:(NSString *)title {
    if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
        self.alertView.title = title;
        [self.alertView show];
    }
    else {
        self.alertController.title = title;
        [self presentViewController:self.alertController animated:YES completion:nil];
    }
}

- (UIAlertController *)alertController {
    if (!_alertController) {
        _alertController = [UIAlertController alertControllerWithTitle:nil message:nil
                                                        preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {}];
        [_alertController addAction:defaultAction];
    }
    return _alertController;
}

- (UIAlertView *)alertView {
    if (!_alertView) {
        _alertView = [[UIAlertView alloc] initWithTitle:nil
                                                message:nil
                                               delegate:nil
                                      cancelButtonTitle:nil
                                      otherButtonTitles:@"OK", nil];
    }
    return _alertView;
}

# pragma mark - UITextFields and UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil;
    [textField resignFirstResponder];
}

- (void)clearTextFields {
    self.userEmailField.text = nil;
    self.userPasswordField.text = nil;
    if (self.activeField) {
        [self.activeField resignFirstResponder];
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userEmailField) {
        [self.userPasswordField becomeFirstResponder];
    }
    return NO;
}

- (UITextField *)userEmailField {
    if (!_userEmailField) {
        CGRect frame = CGRectMake(0, 0, FIELD_WIDTH, FIELD_HEIGHT);
        _userEmailField = [[UITextField alloc] initWithFrame:frame];
        _userEmailField.center = CGPointMake(self.view.frame.size.width / 2.0,
                                                   self.view.frame.size.height / 2.0);
        _userEmailField.borderStyle = UITextBorderStyleRoundedRect;
        _userEmailField.backgroundColor = [UIColor clearColor];
        
        UIColor *color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.4];
        _userEmailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email"
                                                                                   attributes:@{NSForegroundColorAttributeName:color}];
        _userEmailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _userEmailField.textColor = [UIColor whiteColor];
        _userEmailField.textAlignment = NSTextAlignmentLeft;
        _userEmailField.keyboardType = UIKeyboardTypeEmailAddress;
        _userEmailField.delegate = self;
    }
    return _userEmailField;
}

- (UITextField *)userPasswordField {
    if (!_userPasswordField) {
        CGRect frame = CGRectMake(0, 0, FIELD_WIDTH, FIELD_HEIGHT);
        _userPasswordField = [[UITextField alloc] initWithFrame:frame];
        _userPasswordField.center = CGPointMake(self.view.frame.size.width / 2.0,
                                             (self.view.frame.size.height / 2.0) + 80);
        _userPasswordField.borderStyle = UITextBorderStyleRoundedRect;
        _userPasswordField.backgroundColor = [UIColor clearColor];
        
        UIColor *color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.4];
        _userPasswordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password"
                                                                                   attributes:@{NSForegroundColorAttributeName:color}];
        _userPasswordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _userPasswordField.textColor = [UIColor whiteColor];
        _userPasswordField.textAlignment = NSTextAlignmentLeft;
        _userPasswordField.secureTextEntry = YES;
        _userPasswordField.delegate = self;
    }
    return _userPasswordField;
}

- (UIButton *)submitButton {
    if (!_submitButton) {
        CGRect buttonFrame = CGRectMake((self.view.frame.size.width - FIELD_WIDTH) / 2.0, CGRectGetMaxY(self.userPasswordField.frame) + 20,
                                        FIELD_WIDTH, 40);
        _submitButton = [[UIButton alloc] initWithFrame: buttonFrame];
        _submitButton.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.2];
        [_submitButton setTitle:@"Login" forState:UIControlStateNormal];
        _submitButton.titleLabel.textColor = [UIColor whiteColor];
        _submitButton.titleLabel.font = [UIFont systemFontOfSize:BUTTON_FONT_SIZE];
    }
    return _submitButton;
}

# pragma mark - Managing the Keyboard

- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)deregisterFromKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)keyboardWasShown:(NSNotification *)notification {
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGPoint buttonOrigin = self.submitButton.frame.origin;
    CGFloat buttonHeight = self.submitButton.frame.size.height;
    CGRect visibleRect = self.view.frame;
    visibleRect.size.height -= keyboardSize.height;
    if (!CGRectContainsPoint(visibleRect, buttonOrigin)){
        CGPoint scrollPoint = CGPointMake(0.0, buttonOrigin.y - visibleRect.size.height + buttonHeight + 10);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
