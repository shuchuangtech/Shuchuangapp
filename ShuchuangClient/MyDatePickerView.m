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
@property (strong, nonatomic) UIView* pickerView;
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
    self.pickerView = [[UIView alloc] initWithFrame:CGRectMake(0, 2.0 * height, width, height)];;
    UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height / 6.0)];
    title.text = @"选择日期";
    title.textAlignment = NSTextAlignmentCenter;
    [title setBackgroundColor:[UIColor lightGrayColor]];
    UIButton* leftButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, width / 8.0, height / 6.0)];
    [leftButton setTitle:@"取消" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [leftButton.titleLabel setFont:[UIFont systemFontOfSize:17.0]];
    [leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(onDatePickerCancel) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* rightButton = [[UIButton alloc] initWithFrame:CGRectMake(width - 5 - width / 8.0, 0, width / 8.0, height / 6.0)];
    [rightButton setTitle:@"确定" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:17.0]];
    [rightButton addTarget:self action:@selector(onDatePickerOK) forControlEvents:UIControlEventTouchUpInside];
    
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, height / 6.0, width, height * 5.0 / 6.0)];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    NSCalendar* calender = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents* minDateComp = [[NSDateComponents alloc] init];
    NSDate* minDate = [calender dateFromComponents:minDateComp];
    [minDateComp setYear:2010];
    [minDateComp setMonth:1];
    [minDateComp setDay:1];
    [self.datePicker setMinimumDate:minDate];
    NSDateComponents* maxDateComp = [[NSDateComponents alloc] init];
    [maxDateComp setYear:2050];
    [maxDateComp setMonth:1];
    [maxDateComp setDay:1];
    NSDate* maxDate = [calender dateFromComponents:maxDateComp];
    [self.datePicker setMaximumDate:maxDate];
    [self.datePicker setBackgroundColor:[UIColor whiteColor]];
    [self.pickerView addSubview:title];
    [self.pickerView addSubview:leftButton];
    [self.pickerView addSubview:rightButton];
    [self.pickerView addSubview:self.datePicker];
    [self addSubview:self.pickerView];
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
    anima.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.pickerView.center.x, self.pickerView.center.y  + self.pickerView.frame.size.height)];
    anima.toValue =[NSValue valueWithCGPoint:CGPointMake(self.pickerView.center.x, self.pickerView.center.y)];
    anima.delegate = self;
    self.showView = YES;
    [self.pickerView.layer addAnimation:anima forKey:nil];
}

- (void)hidePicker {
    if (!self.showView)
        return;
    CABasicAnimation *anima = [CABasicAnimation animation];
    anima.keyPath = @"position";
    anima.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.pickerView.center.x, self.pickerView.center.y)];
    anima.toValue =[NSValue valueWithCGPoint:CGPointMake(self.pickerView.center.x, self.pickerView.center.y + self.pickerView.frame.size.height)];
    anima.delegate = self;
    self.showView = NO;
    [self.pickerView.layer addAnimation:anima forKey:nil];
}

- (void)animationDidStart:(CAAnimation *)anim {
    if(self.showView) {
        [self.superview bringSubviewToFront:self];
        self.hidden = NO;
    }
    else {
        [self.pickerView.layer setPosition:CGPointMake(self.frame.size.width / 2, self.frame.size.height + self.pickerView.frame.size.height / 2)];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (!self.showView) {
        self.hidden = YES;
        [self.superview sendSubviewToBack:self];
        [self.pickerView.layer setPosition:CGPointMake(self.frame.size.width / 2, self.frame.size.height -self.pickerView.frame.size.height / 2)];
    }
}


@end
