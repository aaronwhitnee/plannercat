//
//  SettingsTableViewController.m
//  TicketScanner
//
//  Created by Aaron Robinson on 5/4/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import "SettingsTableViewController.h"

@interface SettingsTableViewController ()

@property(nonatomic) NSArray *settings;

@end

static NSString *SettingsCellID = @"SettingsCell";

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:SettingsCellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSArray *)settings {
    if (!_settings) {
        _settings = [NSArray arrayWithObjects:@"Log Out", nil];
    }
    return _settings;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.settings count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SettingsCellID forIndexPath:indexPath];
    cell.textLabel.text = [self.settings objectAtIndex:[indexPath row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self.settings objectAtIndex:[indexPath row]] isEqualToString:@"Log Out"]) {
        // Post userLogout notification
        [[NSNotificationCenter defaultCenter] postNotificationName:@"userLogout" object:self];
    }
}

@end
