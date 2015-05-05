//
//  LoginViewController.m
//  TicketScanner
//
//  Created by Aaron Robinson on 5/3/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property(nonatomic, strong) UIButton *submitButton;
@property(nonatomic, strong) UITextField *userEmailField;
@property(nonatomic, strong) UITextField *userPasswordField;

@end

static float FIELD_WIDTH = 250;
static float FIELD_HEIGHT = 60;

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationController.navigationBarHidden = YES;
    
    [self.view addSubview:self.userEmailField];
    [self.view addSubview:self.userPasswordField];
    
    [self.view addSubview:self.submitButton];
    [self.submitButton addTarget:self action:@selector(didTapSubmitButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) didTapSubmitButton:(id) sender
{
    // Generate test JSON data
    NSError *jsonError;
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjects:@[@"1", @"test@test.com", @"runnitt"] forKeys:@[@"id", @"email", @"password"]];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataDict
                                                       options:kNilOptions
                                                         error:&jsonError];
    if (jsonError) {
        NSLog(@"Error generating JSON: %@", jsonError);
        return;
    }
    
    // setting up the POST request
    NSURL *url = [NSURL URLWithString:@"http://marshall.bpwebdesign.com/ios/login.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url standardizedURL]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", jsonData.length] forHTTPHeaderField:@"Content-Length"];
    request.HTTPBody = jsonData;
    
    // send the request asynchronously
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if ([data length] > 0 && !error) {
            NSError *jsonError;
            NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
            // Update UI after successful login on main queue
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleLoginResponse:responseJSON];
            });
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%s:\n RESPONSE JSON:\n %@", __func__, responseString);
        }
        else if ([data length] == 0 && !error) {
            NSLog(@"%s: Empty response.", __func__);
        }
        else if (error) {
            NSLog(@"%s: ", __func__);
        }
    }];
}

- (void) handleLoginResponse:(NSDictionary *)response {
    if ([[response valueForKey:@"status"] isEqualToString:@"error"]) {
        NSLog(@"Server error: cannot process request.");
    }
    // Take user to main menu on successful login
    else if ([[response valueForKey:@"valid"] integerValue] == 1) {
        NSLog(@"Login successful!");
        NSInteger userId = [[response valueForKey:@"id"] integerValue];
        NSString *userEmail = [response valueForKey:@"email"];
        [[NSUserDefaults standardUserDefaults] setValue:@(userId) forKey:@"userId"];
        [[NSUserDefaults standardUserDefaults] setValue:userEmail forKey:@"userEmail"];
        MainMenuTableViewController *mainMenu = [[MainMenuTableViewController alloc] init];
        [self.navigationController pushViewController:mainMenu animated:YES];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    else {
        NSLog(@"Invalid login.");
    }
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
