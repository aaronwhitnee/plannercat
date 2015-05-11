//
//  RSVPListTableViewController.m
//  TicketScanner
//
//  Created by Aaron Robinson on 5/6/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import "RSVPListTableViewController.h"

@interface RSVPListTableViewController ()

@property(nonatomic, strong) GuestsDataSource *guestsDataSource;
@property(nonatomic, strong) ActivityIndicatorView *activityIndicator;

@end

enum {  GUEST_CELL_HEIGHT = 80, GAP_BTWN_VIEWS = 8, USER_IMAGE_WIDTH = 60,
        CHECKIN_BUTTON_WIDTH = 40, CHECKIN_BUTTON_HEIGHT = 30   };

static NSString *GuestCellID = @"guest";

@implementation RSVPListTableViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:GuestCellID];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.activityIndicator];
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refreshTableView:) forControlEvents:UIControlEventValueChanged];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (GuestsDataSource *)guestsDataSource {
    if (!_guestsDataSource) {
        _guestsDataSource = [[GuestsDataSource alloc] initWithGuestsForEvent:8];
        _guestsDataSource.delegate = self;
    }
    return _guestsDataSource;
}

- (void)dataSourceReadyForUse:(GuestsDataSource *)dataSource {
    [self.tableView reloadData];
    [self.activityIndicator stopAnimating];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (! [self.guestsDataSource guestsDataReadyForUse]) {
        [self.activityIndicator startAnimating];
        self.activityIndicator.hidesWhenStopped = YES;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%s: Number of rows in Table View: %d", __func__, (int)[self.guestsDataSource numberOfGuests]);
    return [self.guestsDataSource numberOfGuests];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GuestCellID forIndexPath:indexPath];
    cell = [self guestViewForIndex:[indexPath row] withTableViewCell:cell];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return GUEST_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Guest *selectedGuest = [self.guestsDataSource guestAtIndex:[indexPath row]];
    NSString *guestName = [NSString stringWithFormat:@"%@ %@", [selectedGuest firstName], [selectedGuest lastName]];
    NSLog(@"Selected guest: %@", guestName);
}

- (UITableViewCell *)guestViewForIndex:(NSInteger)rowIndex withTableViewCell:(UITableViewCell *)cell {
    enum {USER_IMAGE_VIEW_TAG = 100, MAIN_VIEW_TAG = 200, USER_LABEL_TAG = 300};
    
    Guest *guest = [self.guestsDataSource guestAtIndex:(int)rowIndex];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [guest setThumbnailFromImage:[guest smallSizeUserImage]];
    });
    
    UIView *mainView = [cell viewWithTag: MAIN_VIEW_TAG];
    
    if ( mainView ) {
        UIImageView *imageView = (UIImageView *)[mainView viewWithTag: USER_IMAGE_VIEW_TAG];
        NSArray *subViews = [imageView subviews];
        for ( UIView *v in subViews )
            [v removeFromSuperview];
        imageView.image = [guest thumbnailImage];
        UILabel *guestLabel = (UILabel *)[mainView viewWithTag: USER_LABEL_TAG];
        guestLabel.attributedText = [guest descriptionForListEntry];
        return cell;
    }
    
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    CGRect viewFrame = CGRectMake(0, 0, bounds.size.width, GUEST_CELL_HEIGHT);
    UIView *thisView = [[UIView alloc] initWithFrame: viewFrame];
    
    UIImage *img = [guest thumbnailImage];
    CGRect imgFrame = CGRectMake(2 * GAP_BTWN_VIEWS, (viewFrame.size.height - USER_IMAGE_WIDTH) / 2, USER_IMAGE_WIDTH, USER_IMAGE_WIDTH );
    UIImageView *iView = [[UIImageView alloc] initWithImage: img];
    iView.tag = USER_IMAGE_VIEW_TAG;
    iView.frame = imgFrame;
    [thisView addSubview: iView];
    
    UILabel *userInfoLabel = [[UILabel alloc]
                               initWithFrame:CGRectMake(USER_IMAGE_WIDTH + 2 * 15, GAP_BTWN_VIEWS,
                                                        viewFrame.size.width - USER_IMAGE_WIDTH - (2 * GAP_BTWN_VIEWS),
                                                        viewFrame.size.height - GAP_BTWN_VIEWS)];
    
    userInfoLabel.tag = USER_LABEL_TAG;
    NSAttributedString *desc = [guest descriptionForListEntry];
    userInfoLabel.attributedText = desc;
    
    userInfoLabel.numberOfLines = 2;
    [thisView addSubview: userInfoLabel];
    
    thisView.tag = MAIN_VIEW_TAG;
    [[cell contentView] addSubview:thisView];
    
    return cell;

}

@end
