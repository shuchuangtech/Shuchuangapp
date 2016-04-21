//
//  DetailBottomView.h
//  ShuchuangClient
//
//  Created by 黄建 on 1/20/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailBottomView : UIView
@property (strong, nonatomic) UIButton *button;
- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)img activeImage:(UIImage *)activeImg leftLine:(BOOL)leftLine rightLine:(BOOL)rightLine;
@end
