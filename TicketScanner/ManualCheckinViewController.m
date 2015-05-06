//
//  ManualCheckinViewController.m
//  TicketScanner
//
//  Created by Aaron Robinson on 2/26/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import "ManualCheckinFormViewController.h"
#import "ActivityIndicatorView.h"

@interface ManualCheckinFormViewController ()

@property(nonatomic) ServerCommunicator *webServer;
@property(nonatomic) UIAlertController *alertController; // iOS 8.0+
@property(nonatomic) UIAlertView *alertView; // iOS < 8.0
@property(nonatomic) ActivityIndicatorView *activityIndicator;
@property(nonatomic, strong, readwrite) AVAudioPlayer *whistleSound;

-(void) displayAlertWithTitle:(NSString *)title;

@end


@implementation ManualCheckinFormViewController

-(void) viewDidLoad {
    [super viewDidLoad];
    
    // TODO: build a dynamic FXForm from JSON (look at dynamic example)
    
    [self.view addSubview:self.activityIndicator];
    
    self.formController.form = [[ManualCheckinForm alloc] init];
    self.formController.tableView = self.tableView;
    
    self.tableView.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
    self.tableView.separatorColor = [UIColor blackColor];
}

// Customize table section headers
-(void) tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView*)view;
    headerView.textLabel.font = [UIFont systemFontOfSize:12 weight:0.5];
    headerView.textLabel.textColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
}

-(void) submitManualCheckinForm:(UITableViewCell<FXFormFieldCell> *)cell {
    self.webServer.delegate = self;

    ManualCheckinForm *form = cell.field.form;
    NSMutableDictionary *fieldValues = [[NSMutableDictionary alloc] init];
    BOOL formIsValid = YES;
        
    for (FXFormField *field in [form fields]) {
        id val = [form valueForKey: [field valueForKey:@"key"]];
        if ( [val length] ) {
            if ( [[field valueForKey:@"key"] isEqual:@"email"] ) {
                formIsValid = [self validateEmailAddress:val];
                if (!formIsValid) {
                    break;
                }
            }
        }
        else {
            formIsValid = NO;
            [self displayAlertWithTitle:@"Please Complete Form"];
            break;
        }
        [fieldValues setObject:val forKey:[field valueForKey:@"key"]];
    }
    if (formIsValid) {
        NSLog(@"%@",fieldValues);
        [self.activityIndicator startAnimating];
        # warning need to submit current eventID along with form values
        [self.webServer performServerRequestType:@"checkinManual" withData:fieldValues];
    }
}

-(BOOL) validateEmailAddress:(NSString *)emailString {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    if (! [emailTest evaluateWithObject:emailString] ) {
        [self displayAlertWithTitle:@"Invalid Email"];
        return NO;
    }
    return YES;
}

-(ActivityIndicatorView *) activityIndicator {
    if(_activityIndicator) {
        return _activityIndicator;
    }
    _activityIndicator = [[ActivityIndicatorView alloc] initWithFrame:self.view.frame];
    _activityIndicator.center = self.view.center;
    return _activityIndicator;
}


-(void) displayAlertWithTitle:(NSString *)title {
    if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
        self.alertView.title = title;
        [self.alertView show];
    }
    else {
        self.alertController.title = title;
        [self presentViewController:self.alertController animated:YES completion:nil];
    }
}

-(UIAlertController *) alertController {
    if (!_alertController) {
        _alertController = [UIAlertController alertControllerWithTitle:nil message:nil
                                                        preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {}];
        [_alertController addAction:defaultAction];
    }
    return _alertController;
}

-(UIAlertView *) alertView {
    if (!_alertView) {
        _alertView = [[UIAlertView alloc] initWithTitle:nil
                                                message:nil
                                               delegate:nil
                                      cancelButtonTitle:nil
                                      otherButtonTitles:@"OK", nil];
    }
    return _alertView;
}

-(void) handleServerResponse:(NSDictionary *)response {
    [self.activityIndicator stopAnimating];
    [self displayAlertWithTitle:@"Check In Successful!"];
}

@end
