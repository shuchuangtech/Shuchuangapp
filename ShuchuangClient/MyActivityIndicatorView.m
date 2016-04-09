//
//  MyActivityIndicatorView.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/6/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "MyActivityIndicatorView.h"

@implementation MyActivityIndicatorView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype) initWithFrameInView:(UIView *)view {
    self = [super initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
    self.acFrame = [[UIView alloc] initWithFrame:CGRectMake(view.frame.size.width / 2 - 40, 200, 80, 80)];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(20, 14, 40, 40)];
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [self.acFrame addSubview:self.activityIndicator];
    self.activityIndicator.hidesWhenStopped = YES;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 60, 52, 16)];
    [label setTextColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
    [label setFont:[UIFont systemFontOfSize:13.0]];
    label.text = @"请稍等...";
    label.textAlignment = NSTextAlignmentCenter;
    [self.acFrame addSubview:label];
    self.acFrame.layer.cornerRadius = 5.0;
    [self.acFrame setBackgroundColor:[UIColor colorWithWhite:0.15 alpha:1.0]];
    [self addSubview:self.acFrame];
    [self setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:0.4]];
    self.hidden = YES;
    self.mySuperView = view;
    return self;
}

- (void) startAc {
    [self.mySuperView addSubview:self];
    [self.mySuperView bringSubviewToFront:self];
    self.hidden = NO;
    [self.activityIndicator startAnimating];
}

- (void) stopAc {
    [self removeFromSuperview];
    [self.activityIndicator stopAnimating];
    self.hidden = YES;
}

- (BOOL)isAnimating {
    return [self.activityIndicator isAnimating];
}

@end
