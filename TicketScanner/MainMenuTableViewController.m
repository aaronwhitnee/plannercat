//
//  MainMenuTableViewController.m
//  TicketScanner
//
//  Created by Aaron Robinson on 5/4/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import "MainMenuTableViewController.h"

@interface MainMenuTableViewController ()

@property(nonatomic) NSArray *menuItemLabels;
@property(nonatomic) UIBarButtonItem *settingsBarButton;
@property(nonatomic, strong) ManagedEventsTableViewController *userEventsTableView;
@property(nonatomic, strong) TicketsTableViewController *userTicketsTableView;

@end

static NSString *CellID = @"menuItem";
enum {MENU_ITEM_HEIGHT = 90, MENU_FONT_SIZE = 20};

@implementation MainMenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellID];
    
    self.navigationItem.rightBarButtonItem = self.settingsBarButton;
    self.navigationItem.hidesBackButton = YES;
}

- (ManagedEventsTableViewController *)userEventsTableView {
    if (!_userEventsTableView) {
        _userEventsTableView = [ManagedEventsTableViewController new];
    }
    return _userEventsTableView;
}

- (TicketsTableViewController *)userTicketsTableView {
    if (!_userTicketsTableView) {
        _userTicketsTableView = [TicketsTableViewController new];
    }
    return _userTicketsTableView;
}

- (NSArray *)menuItemLabels {
    if (!_menuItemLabels) {
        _menuItemLabels = [NSArray arrayWithObjects:@"My Events", @"My Tickets", nil];
    }
    return _menuItemLabels;
}

// TODO: create a new settingsBarButton class to be shared by all views that want it
- (UIBarButtonItem *)settingsBarButton {
    if (!_settingsBarButton) {
        _settingsBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(didTapSettingsBarButton:)];
    }
    return _settingsBarButton;
}

- (void)didTapSettingsBarButton:(UIBarButtonItem *)sender {
    SettingsTableViewController *settingsViewController = [[SettingsTableViewController alloc] init];
    [self.navigationController pushViewController:settingsViewController animated: YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.menuItemLabels count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID forIndexPath:indexPath];
    cell.textLabel.text = [self.menuItemLabels objectAtIndex:[indexPath row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return MENU_ITEM_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self.menuItemLabels objectAtIndex:[indexPath row]] isEqualToString:@"My Events"]) {
        [self.navigationController pushViewController:self.userEventsTableView animated:YES];
    }
    else if ([[self.menuItemLabels objectAtIndex:[indexPath row]] isEqualToString:@"My Tickets"]) {
        [self.navigationController pushViewController:self.userTicketsTableView animated:YES];
    }
}

@end
