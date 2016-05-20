//
//  AnimateLabel.m
//  ShuchuangClient
//
//  Created by 黄建 on 5/8/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "AnimateLabel.h"

@implementation AnimateLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)changeLabelText:(NSMutableAttributedString *)text {
    self.nextText = text;
    CABasicAnimation *opAnima = [CABasicAnimation animation];
    opAnima.keyPath = @"opacity";
    opAnima.fromValue = [NSNumber numberWithDouble:1.0];
    opAnima.toValue = [NSNumber numberWithDouble:0];
    opAnima.duration = 0.3;
    opAnima.removedOnCompletion = NO;
    opAnima.fillMode = kCAFillModeForwards;
    self.animaStep = 0;
    opAnima.delegate = self;
    [self.layer addAnimation:opAnima forKey:nil];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (self.animaStep == 0) {
        self.attributedText = self.nextText;
        CABasicAnimation *opAnima = [CABasicAnimation animation];
        opAnima.keyPath = @"opacity";
        opAnima.fromValue = [NSNumber numberWithDouble:0.0];
        opAnima.toValue = [NSNumber numberWithDouble:1.0];
        opAnima.duration = 0.3;
        opAnima.removedOnCompletion = NO;
        opAnima.fillMode = kCAFillModeForwards;
        self.animaStep = 1;
        opAnima.delegate = self;
        [self.layer addAnimation:opAnima forKey:nil];
    }
    else {
        [self.layer removeAllAnimations];
    }
}

@end
