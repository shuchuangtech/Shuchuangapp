//
//  MyDatePickerView.m
//  ShuchuangClient
//
//  Created by 黄建 on 3/22/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "MyDatePickerView.h"
@interface MyDatePickerView()
@property (strong, nonatomic) UIDatePicker* datePicker;
@property BOOL showView;
- (void)onDatePickerOK;
- (void)onDatePickerCancel;
@end


@implementation MyDatePickerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype) initWithFrameInView:(UIView *)view{
    CGFloat height = view.frame.size.height / 3.0;
    CGFloat width = view.frame.size.width;
    self = [super initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
    UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(0, 2.0 * height, width, height / 6.0)];
    title.text = @"选择日期";
    title.textAlignment = NSTextAlignmentCenter;
    [title setBackgroundColor:[UIColor lightGrayColor]];
    UIButton* leftButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 2.0 * height, width / 8.0, height / 6.0)];
    [leftButton setTitle:@"取消" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [leftButton.titleLabel setFont:[UIFont systemFontOfSize:17.0]];
    [leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(onDatePickerCancel) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* rightButton = [[UIButton alloc] initWithFrame:CGRectMake(width - 5 - width / 8.0, 2.0 * height, width / 8.0, height / 6.0)];
    [rightButton setTitle:@"确定" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:17.0]];
    [rightButton addTarget:self action:@selector(onDatePickerOK) forControlEvents:UIControlEventTouchUpInside];
    
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 13.0 * height / 6.0, width, height * 5.0 / 6.0)];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    [self.datePicker setMinimumDate:[NSDate date]];
    NSDateComponents* maxDateComp = [[NSDateComponents alloc] init];
    [maxDateComp setYear:2050];
    [maxDateComp setMonth:1];
    [maxDateComp setDay:1];
    NSCalendar* calender = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDate* maxDate = [calender dateFromComponents:maxDateComp];
    [self.datePicker setMaximumDate:maxDate];
    [self.datePicker setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:title];
    [self addSubview:leftButton];
    [self addSubview:rightButton];
    [self addSubview:self.datePicker];
    [view addSubview:self];
    self.showView = NO;
    self.hidden = YES;
    return self;
}

- (void)setDate:(NSDate*)date {
    [self.datePicker setDate:date];
}

- (void)onDatePickerOK {
    [self.datePickerDelegate onDatePickerOK:[self.datePicker date]];
}

- (void)onDatePickerCancel {
    [self.datePickerDelegate onDatePickerCancel];
}

- (void)showPicker {
    if (self.showView)
        return;
    CABasicAnimation *anima = [CABasicAnimation animation];
    anima.keyPath = @"position";
    anima.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.frame.size.width / 2, self.frame.size.height * 5 / 6)];
    anima.toValue =[NSValue valueWithCGPoint:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)];
    anima.delegate = self;
    self.showView = YES;
    [self.layer addAnimation:anima forKey:nil];
}

- (void)hidePicker {
    if (!self.showView)
        return;
    CABasicAnimation *anima = [CABasicAnimation animation];
    anima.keyPath = @"position";
    anima.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)];
    anima.toValue =[NSValue valueWithCGPoint:CGPointMake(self.frame.size.width / 2, self.frame.size.height * 5 / 6)];
    anima.delegate = self;
    self.showView = NO;
    [self.layer addAnimation:anima forKey:nil];
}

- (void)animationDidStart:(CAAnimation *)anim {
    if(self.showView) {
        [self.superview bringSubviewToFront:self];
        self.hidden = NO;
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (!self.showView) {
        [self.superview sendSubviewToBack:self];
        self.hidden = YES;
    }
}


@end
