//
//  ManagedEventsTableViewController.m
//  TicketScanner
//
//  Created by Aaron Robinson on 5/4/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import "ManagedEventsTableViewController.h"

@interface ManagedEventsTableViewController ()

@property(nonatomic, strong) EventsDataSource *eventsDataSource;
@property(nonatomic, strong) ActivityIndicatorView *activityIndicator;
@property(nonatomic, strong) CheckinTabBarController *eventController;

@end

@implementation ManagedEventsTableViewController

static NSString *EventCellID = @"event";
enum { EVENT_CELL_HEIGHT = 100, GAP_BTWN_VIEWS = 5, IMAGE_HEIGHT = 0, IMAGE_WIDTH = 0 };

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.topItem.title = @"";
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:EventCellID];
    
    [self.view addSubview:self.activityIndicator];
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refreshTableView:) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CheckinTabBarController *)eventController {
    if (!_eventController) {
        _eventController = [[CheckinTabBarController alloc] init];
    }
    return _eventController;
}

- (ActivityIndicatorView *)activityIndicator {
    if (!_activityIndicator) {
        _activityIndicator = [[ActivityIndicatorView alloc] initWithFrame:self.view.frame];
    }
    return _activityIndicator;
}

- (void)refreshTableView:(UIRefreshControl *)sender {
    [self.tableView reloadData];
    [sender endRefreshing];
}

#pragma mark - Table view data source

- (EventsDataSource *)eventsDataSource {
    if (!_eventsDataSource) {
        _eventsDataSource = [[EventsDataSource alloc] init];
        _eventsDataSource.delegate = self;
    }
    return _eventsDataSource;
}

- (void)dataSourceReadyForUse:(EventsDataSource *)dataSource {
    [self.tableView reloadData];
    [self.activityIndicator stopAnimating];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (! [self.eventsDataSource eventsDataReadyForUse]) {
        [self.activityIndicator startAnimating];
        self.activityIndicator.hidesWhenStopped = YES;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%s: Number of rows in Table View: %d", __func__, (int)[self.eventsDataSource numberOfEvents]);
    return [self.eventsDataSource numberOfEvents];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EventCellID forIndexPath:indexPath];
    cell = [self eventViewForIndex:[indexPath row] withTableViewCell:cell];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return EVENT_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.navigationController pushViewController:self.eventController animated:YES];
}

- (UITableViewCell *)eventViewForIndex:(NSInteger)rowIndex withTableViewCell:(UITableViewCell *)cell {
    enum {MAIN_VIEW_TAG = 100, EVENT_LABEL_TAG = 200};
    
    Event *event = [self.eventsDataSource eventAtIndex:(int)rowIndex];
    UIView *view = [cell viewWithTag: MAIN_VIEW_TAG];
    
    if (view) {
        // TODO: create a background imageView for the cell, using the event's image attribute
        //        UIImageView *iv = (UIImageView *)[view viewWithTag: IMAGE_VIEW_TAG];
        //        NSArray *views = [iv subviews];
        //        for( UIView *v in views )
        //            [v removeFromSuperview];
        //        iv.image = [theater imageForListEntry];
        UILabel *eventLabel = (UILabel *)[view viewWithTag: EVENT_LABEL_TAG];
        eventLabel.attributedText = [event descriptionForListEntry];
        return cell;
    }
    
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    CGRect viewFrame = CGRectMake(0, 0, bounds.size.width, EVENT_CELL_HEIGHT);
    UIView *thisView = [[UIView alloc] initWithFrame: viewFrame];
        
    UILabel *eventInfoLabel = [[UILabel alloc]
                                 initWithFrame:CGRectMake(IMAGE_WIDTH + 2 * 10, 5,
                                                          viewFrame.size.width - IMAGE_WIDTH - 10,
                                                          viewFrame.size.height - 5)];
    
    eventInfoLabel.numberOfLines = 3;
    eventInfoLabel.tag = EVENT_LABEL_TAG;
    eventInfoLabel.attributedText = [event descriptionForListEntry];
    [thisView addSubview: eventInfoLabel];
    thisView.tag = MAIN_VIEW_TAG;
    [[cell contentView] addSubview:thisView];
    
    return cell;
}

@end
