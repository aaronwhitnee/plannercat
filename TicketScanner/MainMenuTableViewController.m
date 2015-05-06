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

@end

static NSString *CellID = @"menuItem";
enum {MENU_ITEM_HEIGHT = 90};

@implementation MainMenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellID];
    
    self.navigationItem.rightBarButtonItem = self.settingsBarButton;
    self.navigationItem.hidesBackButton = YES;
}

- (NSArray *) menuItemLabels {
    if (!_menuItemLabels) {
        _menuItemLabels = [NSArray arrayWithObjects:@"My Events", @"My Tickets", nil];
    }
    return _menuItemLabels;
}

- (UIBarButtonItem *) settingsBarButton {
    if (!_settingsBarButton) {
        _settingsBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(didTapSettingsBarButton:)];
    }
    return _settingsBarButton;
}

- (void) didTapSettingsBarButton:(UIBarButtonItem *)sender {
    NSLog(@"tapped settings button");
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

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return MENU_ITEM_HEIGHT;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self.menuItemLabels objectAtIndex:[indexPath row]] isEqualToString:@"My Events"]) {
        ManagedEventsTableViewController *myEvents = [[ManagedEventsTableViewController alloc] init];
        [self.navigationController pushViewController:myEvents animated:YES];
    }
    else if ([[self.menuItemLabels objectAtIndex:[indexPath row]] isEqualToString:@"My Tickets"]) {
        TicketsTableViewController *myTickets = [[TicketsTableViewController alloc] init];
        [self.navigationController pushViewController:myTickets animated:YES];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end