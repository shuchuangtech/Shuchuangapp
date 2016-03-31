//
//  MyTimePickerView.m
//  ShuchuangClient
//
//  Created by 黄建 on 3/23/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "MyTimePickerView.h"

@interface MyTimePickerView()
@property (strong, nonatomic) UIPickerView* pickerView;
@property (strong, nonatomic) UIView* pickerSuperView;
@property BOOL showView;
- (void)onPickerOK;
- (void)onPickerCancel;
@end

@implementation MyTimePickerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrameInView:(UIView *)view {
    CGFloat height = view.frame.size.height / 3.0;
    CGFloat width = view.frame.size.width;
    self = [super initWithFrame:CGRectMake(0, 0, width, view.frame.size.height)];
    self.pickerSuperView = [[UIView alloc] initWithFrame:CGRectMake(0, 2.0 * height, width, height)];
    UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height / 6.0)];
    title.text = @"选择时间";
    title.textAlignment = NSTextAlignmentCenter;
    [title setBackgroundColor:[UIColor lightGrayColor]];
    UIButton* leftButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, width / 8.0, height / 6.0)];
    [leftButton setTitle:@"取消" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [leftButton.titleLabel setFont:[UIFont systemFontOfSize:17.0]];
    [leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(onPickerCancel) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* rightButton = [[UIButton alloc] initWithFrame:CGRectMake(width - 5 - width / 8.0, 0, width / 8.0, height / 6.0)];
    [rightButton setTitle:@"确定" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:17.0]];
    [rightButton addTarget:self action:@selector(onPickerOK) forControlEvents:UIControlEventTouchUpInside];
    
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, height / 6.0, width, height * 5.0 / 6.0)];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [self.pickerSuperView addSubview:title];
    [self.pickerSuperView addSubview:leftButton];
    [self.pickerSuperView addSubview:rightButton];
    [self.pickerSuperView addSubview:self.pickerView];
    [self addSubview:self.pickerSuperView];
    [view addSubview:self];
    self.hidden = YES;
    self.showView = NO;
    return self;
}

- (void)onPickerOK {
    NSInteger hour = [self.pickerView selectedRowInComponent:0];
    NSInteger minute = [self.pickerView selectedRowInComponent:1];
    [self.timePickerDelegate onTimePickerOKHour:hour minute:minute];
}

- (void)onPickerCancel {
    [self.timePickerDelegate onTimePickerCancel];
}

- (void)showPicker {
    if (self.showView)
        return;
    CABasicAnimation *anima = [CABasicAnimation animation];
    anima.keyPath = @"position";
    anima.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.pickerSuperView.center.x, self.pickerSuperView.center.y + self.pickerSuperView.frame.size.height)];
    anima.toValue =[NSValue valueWithCGPoint:CGPointMake(self.pickerSuperView.center.x, self.pickerSuperView.center.y)];
    anima.delegate = self;
    self.showView = YES;
    [self.pickerSuperView.layer addAnimation:anima forKey:nil];
}

- (void)hidePicker {
    if (!self.showView)
        return;
    CABasicAnimation *anima = [CABasicAnimation animation];
    anima.keyPath = @"position";
    anima.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.pickerSuperView.center.x, self.pickerSuperView.center.y)];
    anima.toValue =[NSValue valueWithCGPoint:CGPointMake(self.pickerSuperView.center.x, self.pickerSuperView.center.y +  + self.pickerSuperView.frame.size.height)];
    anima.delegate = self;
    self.showView = NO;
    [self.pickerSuperView.layer addAnimation:anima forKey:nil];
}

- (void)animationDidStart:(CAAnimation *)anim {
    if(self.showView) {
        [self.superview bringSubviewToFront:self];
        self.hidden = NO;
    }
    else {
        [self.pickerSuperView.layer setPosition:CGPointMake(self.frame.size.width / 2, self.frame.size.height + self.pickerSuperView.frame.size.height / 2)];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (!self.showView) {
        self.hidden = YES;
        [self.superview sendSubviewToBack:self];
        [self.pickerSuperView.layer setPosition:CGPointMake(self.frame.size.width / 2, self.frame.size.height - self.pickerSuperView.frame.size.height / 2)];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0)
        return 24;
    else
        return 60;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%02ld", row];
}

@end
