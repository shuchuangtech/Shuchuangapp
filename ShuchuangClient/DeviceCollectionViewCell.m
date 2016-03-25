//
//  DeviceCollectionViewCell.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/12/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "DeviceCollectionViewCell.h"
#import "UIButton+FillBackgroundImage.h"
#import "SCUtil.h"
@interface DeviceCollectionViewCell()
@property BOOL isEditing;
@property (strong, nonatomic) UIButton *deleteButton;
- (void)onButtonDelete;
@end

@implementation DeviceCollectionViewCell
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.isEditing = NO;
        self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [self.deleteButton setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [self.deleteButton setBackgroundImage:[UIImage imageNamed:@"close_gray"] forState:UIControlStateHighlighted];
        [self.deleteButton addTarget:self action:@selector(onButtonDelete) forControlEvents:UIControlEventTouchUpInside];
        self.deleteButton.hidden = YES;
        [self addSubview:self.deleteButton];
    }
    return self;
}

- (void)layoutSubviews {
    
}

- (void)startEdit:(BOOL)small {
    if (!self.isEditing) {
        self.deleteButton.hidden = NO;
        [self bringSubviewToFront:self.deleteButton];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animation.duration = 0.2;
        animation.repeatCount = HUGE_VALF;
        animation.autoreverses = YES;
        if (small) {
            animation.fromValue = [NSNumber numberWithFloat:0.98];
            animation.toValue = [NSNumber numberWithFloat:1.02];
        }
        else {
            animation.fromValue = [NSNumber numberWithFloat:1.02];
            animation.toValue = [NSNumber numberWithFloat:0.98];
        }
        
        [self.layer addAnimation:animation forKey:@"scale-layer"];
        self.isEditing = YES;
    }
}

- (void)stopEdit {
    if (self.isEditing) {
        [self.layer removeAllAnimations];
        self.deleteButton.hidden = YES;
        self.isEditing = NO;
    }
}

- (void) onButtonDelete {
    UIViewController *vc = nil;
    for (UIView *next = [self superview]; next; next = [next superview]) {
        UIResponder *responder = [next nextResponder];
        if ([responder isKindOfClass:[UIViewController class]]) {
            vc = (UIViewController *)responder;
            break;
        }
    }
    [SCUtil viewController:vc showAlertTitle:@"提示" message:@"确认删除这个设备吗" yesAction:^(UIAlertAction *action) {
        NSDictionary *dict = @{@"devId":self.uuid};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteCompletionNoti" object:nil userInfo:dict];
    } noAction:^(UIAlertAction *action) {
        
    }];
    
}
@end
