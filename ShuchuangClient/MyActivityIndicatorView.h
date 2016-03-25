//
//  MyActivityIndicatorView.h
//  ShuchuangClient
//
//  Created by 黄建 on 1/6/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyActivityIndicatorView : UIView
- (instancetype) initWithFrameInView:(UIView *)view;
- (void) startAc;
- (void) stopAc;
- (BOOL) isAnimating;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) UIView *superView;
@property (strong, nonatomic) UIView *acFrame;
@end
