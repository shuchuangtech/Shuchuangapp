//
//  MyWelcomeView.m
//  ShuchuangClient
//
//  Created by 黄建 on 4/8/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "MyWelcomeView.h"
@interface MyWelcomeView ()
@property (strong, nonatomic) UIImageView *bg1;
@property (strong, nonatomic) UIImageView *bg2;
@property (strong, nonatomic) UIImageView *bg3;
@property (strong, nonatomic) UIImageView *bg4;
@property (nonatomic) NSInteger animaStep;
@property (nonatomic) BOOL started;
@property (nonatomic) BOOL animating;

- (void)addAnimation;
@end

@implementation MyWelcomeView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrameInView:(UIView *)view {
    CGFloat height = view.frame.size.height;
    CGFloat width = view.frame.size.width;
    CGFloat multiNum = 1.345;
    self.bg1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, multiNum * width, height)];
    self.bg2 = [[UIImageView alloc] initWithFrame:CGRectMake(- (multiNum - 1.0) * width, 0, multiNum * width, height)];
    self.bg3 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, multiNum * width, height)];
    self.bg4 = [[UIImageView alloc] initWithFrame:CGRectMake(- (multiNum - 1.0) * width, 0, multiNum * width, height)];
    [self.bg1 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"welcomeBg1" ofType:@"png"]]];
    [self.bg2 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"welcomeBg2" ofType:@"png"]]];
    [self.bg3 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"welcomeBg3" ofType:@"png"]]];
    [self.bg4 setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"welcomeBg4" ofType:@"png"]]];
    self = [super initWithFrame:CGRectMake(0, 0, width, height)];
    [self addSubview:self.bg4];
    [self addSubview:self.bg3];
    [self addSubview:self.bg2];
    [self addSubview:self.bg1];
    self.animaStep = 0;
    self.started = NO;
    self.animating = NO;
    return self;
}

- (void)dealloc {
    self.bg1 = nil;
    self.bg2 = nil;
    self.bg3 = nil;
    self.bg4 = nil;
}

- (void)startAnimation {
    if (self.started) {
        return;
    }
    self.started = YES;
    [self addAnimation];
}

- (void)stopAnimation {
    self.started = NO;
}

- (void)addAnimation {
    if (self.animating) {
        return;
    }
    self.animating = YES;
    CABasicAnimation *anima = [CABasicAnimation animation];
    CABasicAnimation *opAnima = [CABasicAnimation animation];
    anima.keyPath = @"position";
    opAnima.keyPath = @"opacity";
    opAnima.fromValue = [NSNumber numberWithDouble:1.0];
    opAnima.toValue = [NSNumber numberWithDouble:0];
    opAnima.duration = 8.0;
    anima.removedOnCompletion = NO;
    opAnima.removedOnCompletion = NO;
    anima.fillMode = kCAFillModeForwards;
    opAnima.fillMode = kCAFillModeForwards;
    CGFloat width = self.frame.size.width;
    anima.delegate = self;
    anima.duration = 8.0;
    if (self.animaStep == 0) {
        anima.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.center.x + width * 0.1725, self.center.y)];
        anima.toValue = [NSValue valueWithCGPoint:CGPointMake(self.center.x - width * 0.1725, self.center.y)];
        self.bg1.hidden = NO;
        self.bg2.hidden = NO;
        self.bg3.hidden = YES;
        self.bg4.hidden = YES;
        [self.bg1.layer addAnimation:anima forKey:nil];
        [self.bg1.layer addAnimation:opAnima forKey:nil];
    }
    else if (self.animaStep == 1) {
        anima.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.center.x - width * 0.1725, self.center.y)];
        anima.toValue = [NSValue valueWithCGPoint:CGPointMake(self.center.x + width * 0.1725, self.center.y)];
        self.bg1.hidden = YES;
        self.bg2.hidden = NO;
        self.bg3.hidden = NO;
        self.bg4.hidden = YES;
        [self.bg2.layer addAnimation:anima forKey:nil];
        [self.bg2.layer addAnimation:opAnima forKey:nil];
    }
    else if (self.animaStep == 2) {
        anima.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.center.x + width * 0.1725, self.center.y)];
        anima.toValue = [NSValue valueWithCGPoint:CGPointMake(self.center.x - width * 0.1725, self.center.y)];
        self.bg1.hidden = YES;
        self.bg2.hidden = YES;
        self.bg3.hidden = NO;
        self.bg4.hidden = NO;
        [self.bg3.layer addAnimation:anima forKey:nil];
        [self.bg3.layer addAnimation:opAnima forKey:nil];
    }
    else if (self.animaStep == 3) {
        anima.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.center.x - width * 0.1725, self.center.y)];
        anima.toValue = [NSValue valueWithCGPoint:CGPointMake(self.center.x + width * 0.1725, self.center.y)];
        self.bg1.hidden = NO;
        self.bg2.hidden = YES;
        self.bg3.hidden = YES;
        self.bg4.hidden = NO;
        [self.bg4.layer addAnimation:anima forKey:nil];
        [self.bg4.layer addAnimation:opAnima forKey:nil];
    }
}

- (void)animationDidStart:(CAAnimation *)anim {
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    switch (self.animaStep) {
        case 0:
            [self sendSubviewToBack:self.bg1];
            [self.bg1.layer removeAllAnimations];
            break;
        case 1:
            [self sendSubviewToBack:self.bg2];
            [self.bg2.layer removeAllAnimations];
            break;
        case 2:
            [self sendSubviewToBack:self.bg3];
            [self.bg3.layer removeAllAnimations];
            break;
        case 3:
            [self sendSubviewToBack:self.bg4];
            [self.bg4.layer removeAllAnimations];
            break;
        default:
            break;
    }
    self.animaStep = (self.animaStep + 1)%4;
    self.animating = NO;
    if (self.started) {
        [self addAnimation];
    }
}

@end
