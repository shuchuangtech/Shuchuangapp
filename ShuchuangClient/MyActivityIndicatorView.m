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
    self.acFrame.hidden = YES;
    self.hidden = YES;
    self.superView = view;
    [self.superView addSubview:self];
    return self;
}

- (void) startAc {
    self.hidden = NO;
    [self.superView bringSubviewToFront:self];
    self.acFrame.transform = CGAffineTransformMakeScale(0.5, 0.5);
    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.2f];
    self.acFrame.transform = CGAffineTransformMakeScale(1.0, 1.0);
    [UIView commitAnimations];
    self.acFrame.hidden = NO;
    [self.activityIndicator startAnimating];
}

- (void) stopAc {
    [self.activityIndicator stopAnimating];
    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.2f];
    self.acFrame.transform = CGAffineTransformMakeScale(0.5, 0.5);
    [UIView commitAnimations];
    self.acFrame.hidden = YES;
    self.hidden = YES;
    [self.superView sendSubviewToBack:self];
}

- (BOOL)isAnimating {
    return [self.activityIndicator isAnimating];
}

@end
