//
//  RSVPListTableViewController.m
//  TicketScanner
//
//  Created by Aaron Robinson on 5/6/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import "RSVPListTableViewController.h"
#import "UserImageStore.h"

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
        _guestsDataSource = [[GuestsDataSource alloc] initWithGuestsForEvent:12];
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
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
    
    // reusing the cell's subviews if they exist
    UIView *mainView = [cell viewWithTag: MAIN_VIEW_TAG];
    if (mainView) {
        UIImageView *imageView = (UIImageView *)[mainView viewWithTag:USER_IMAGE_VIEW_TAG];
        NSArray *subViews = [imageView subviews];
        for ( UIView *v in subViews )
            [v removeFromSuperview];
        imageView.image = [guest thumbnailImageWithSize:CGSizeMake(USER_IMAGE_WIDTH, USER_IMAGE_WIDTH)];
        UILabel *guestLabel = (UILabel *)[mainView viewWithTag:USER_LABEL_TAG];
        guestLabel.attributedText = [guest descriptionForListEntry];
        return cell;
    }
    else {
        // main cell view
        CGRect bounds = [[UIScreen mainScreen] applicationFrame];
        CGRect mainViewFrame = CGRectMake(0, 0, bounds.size.width, GUEST_CELL_HEIGHT);
        mainView = [[UIView alloc] initWithFrame:mainViewFrame];
        mainView.tag = MAIN_VIEW_TAG;
        
        // user info label view
        UILabel *userInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(USER_IMAGE_WIDTH + 2 * 15, GAP_BTWN_VIEWS,
                                                                           mainViewFrame.size.width - USER_IMAGE_WIDTH - (2 * GAP_BTWN_VIEWS),
                                                                           mainViewFrame.size.height - GAP_BTWN_VIEWS)];
        userInfoLabel.tag = USER_LABEL_TAG;
        NSAttributedString *desc = [guest descriptionForListEntry];
        userInfoLabel.attributedText = desc;
        userInfoLabel.numberOfLines = 2;
        [mainView addSubview:userInfoLabel];
        
        // user thumbnail image view
        CGRect thumbnailFrame = CGRectMake(2 * GAP_BTWN_VIEWS, (mainViewFrame.size.height - USER_IMAGE_WIDTH) / 2,
                                           USER_IMAGE_WIDTH, USER_IMAGE_WIDTH );
        UIImage *thumbnail = [[UserImageStore sharedStore] imageForKey:guest.userKey];
        // best case scenario - fetch from cache
        if (thumbnail) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:thumbnail];
            imageView.tag = USER_IMAGE_VIEW_TAG;
            imageView.frame = thumbnailFrame;
            [mainView addSubview:imageView];
            [[cell contentView] addSubview:mainView];
        }
        else {
            // okay scenario - fetch from guest attributes ??? not possible, just skip to rendering it ???
            if ([guest thumbnailImageHasRendered]) {
                thumbnail = [guest thumbnailImageWithSize:CGSizeMake(USER_IMAGE_WIDTH, USER_IMAGE_WIDTH)];
                UIImageView *imageView = [[UIImageView alloc] initWithImage:thumbnail];
                imageView.tag = USER_IMAGE_VIEW_TAG;
                imageView.frame = thumbnailFrame;
                [mainView addSubview:imageView];
                [[cell contentView] addSubview:mainView];
            }
            // worst case - render in background
            else {
                dispatch_queue_t thumbnailQueue = dispatch_queue_create("", NULL);
                dispatch_async(thumbnailQueue, ^{
                    UIImage *thumbnail = [guest thumbnailImageWithSize:CGSizeMake(USER_IMAGE_WIDTH, USER_IMAGE_WIDTH)];
                    UIImageView *imageView = [[UIImageView alloc] initWithImage:thumbnail];
                    imageView.tag = USER_IMAGE_VIEW_TAG;
                    imageView.frame = thumbnailFrame;
                    
                    // update cell on main thread
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UITableViewCell *cellToUpdate = cell;
                        if (cellToUpdate) {
                            [mainView addSubview:imageView];
                            [[cellToUpdate contentView] addSubview:mainView];
                        }
                    });
                });
            }
            // TODO: use a placeholder image until user image finishes rendering
        }
    }
    
    return cell;
}

@end
