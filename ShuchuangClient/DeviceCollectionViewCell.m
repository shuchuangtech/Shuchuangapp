//
//  DeviceCollectionViewCell.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/12/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "DeviceCollectionViewCell.h"
#import "UIButton+FillBackgroundImage.h"

@interface DeviceCollectionViewCell()
@property (nonatomic) BOOL isEditing;
@property (strong, nonatomic) UIButton *deleteButton;
@property (nonatomic) BOOL small;

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
        self.small = small;
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
        animation.delegate = self;
        animation.removedOnCompletion = YES;
        [self.layer addAnimation:animation forKey:@"scale-layer"];
        self.isEditing = YES;
    }
}

- (void)stopEdit {
    if (self.isEditing) {
        self.deleteButton.hidden = YES;
        self.isEditing = NO;
        [self sendSubviewToBack:self.deleteButton];
        [self.layer removeAllAnimations];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSLog(@"%@ anima stop", self.uuid);
    if (self.isEditing == YES && self.deleteButton.hidden == NO) {
        NSLog(@"self editing YES");
        /*
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animation.duration = 0.2;
        animation.repeatCount = HUGE_VALF;
        animation.autoreverses = YES;
        if (self.small) {
            animation.fromValue = [NSNumber numberWithFloat:0.98];
            animation.toValue = [NSNumber numberWithFloat:1.02];
        }
        else {
            animation.fromValue = [NSNumber numberWithFloat:1.02];
            animation.toValue = [NSNumber numberWithFloat:0.98];
        }
        animation.delegate = self;
        animation.removedOnCompletion = YES;
        [self.layer addAnimation:animation forKey:@"scale-layer"];
         */
    }
    else {
        NSLog(@"self editing NO");
        [self.layer removeAllAnimations];
    }
}

- (void)onButtonDelete {
    [self.deleteDelegate onDeleteDevice:self.uuid];
}
@end
