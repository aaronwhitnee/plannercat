//
//  LoginViewController.h
//  TicketScanner
//
//  Created by Aaron Robinson on 5/3/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerCommunicator.h"
#import "MainMenuTableViewController.h"
#import "ActivityIndicatorView.h"

@interface LoginViewController : UIViewController<ConnectionFinishedDelegate, UITextFieldDelegate>

@property (nonatomic, weak) id delegate;

@end
