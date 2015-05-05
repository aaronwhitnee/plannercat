//
//  ActivityIndicatorView.m
//  TicketScanner
//
//  Created by Aaron Robinson on 3/13/15.
//  Copyright (c) 2015 SSU. All rights reserved.
//

#import "ActivityIndicatorView.h"

@interface ActivityIndicatorView()
@property(nonatomic) UIView *boundingBoxView;
@end

@implementation ActivityIndicatorView

- (instancetype) initWithFrame:(CGRect)frame{
    if ((self = [super initWithFrame:frame]) == nil) {
        return nil;
    }
    self.frame = frame;
    self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    self.hidesWhenStopped = YES;
    return self;
}

-(UIView *) boundingBoxView {
    if (_boundingBoxView) {
        return _boundingBoxView;
    }
    _boundingBoxView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    _boundingBoxView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    _boundingBoxView.layer.cornerRadius = 10.0;
    _boundingBoxView.clipsToBounds = YES;
    return _boundingBoxView;
}

@end
