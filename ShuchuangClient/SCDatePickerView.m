//
//  SCDatePickerView.m
//  ShuchuangClient
//
//  Created by 黄建 on 5/13/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "SCDatePickerView.h"

@implementation SCDatePickerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        UIView *containerView = [[[UINib nibWithNibName:@"SCDatePickerView" bundle:[NSBundle mainBundle]] instantiateWithOwner:self options:nil] objectAtIndex:0];
        CGRect newFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [containerView setFrame:newFrame];
        [self addSubview:containerView];
        self.calendar.showsPlaceholders = NO;
        self.calendar.delegate = self;
        self.calendar.dataSource = self;
        CGSize iOSDeviceScreenSize = [UIScreen mainScreen].bounds.size;
        if (iOSDeviceScreenSize.height == 480) {
            self.calendar.scope = FSCalendarScopeWeek;
        }
        else {
            self.calendar.scope = FSCalendarScopeMonth;
        }
        [self.leftArrow addTarget:self action:@selector(onLeftArrow) forControlEvents:UIControlEventTouchUpInside];
        [self.rightArrow addTarget:self action:@selector(onRightArrow) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)onLeftArrow {
    NSDate *prevMonth = [self.calendar dateBySubstractingMonths:1 fromDate:self.calendar.currentPage];
    [self.calendar setCurrentPage:prevMonth animated:YES];

}

- (void)onRightArrow {
    NSDate *nextMonth = [self.calendar dateByAddingMonths:1 toDate:self.calendar.currentPage];
    [self.calendar setCurrentPage:nextMonth animated:YES];
}

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date  {
    if (self.pickDelegate != nil && [self.pickDelegate respondsToSelector:@selector(calendar:shouldSelectDate:)]) {
        return [self.pickDelegate calendar:calendar shouldSelectDate:date];
    }
    else {
        return YES;
    }
}

- (BOOL)calendar:(FSCalendar *)calendar shouldDeselectDate:(NSDate *)date {
    if (self.pickDelegate != nil && [self.pickDelegate respondsToSelector:@selector(calendar:shouldDeselectDate:)]) {
        return [self.pickDelegate calendar:calendar shouldDeselectDate:date];
    }
    else {
        return YES;
    }
}

- (void)calendar:(FSCalendar *)calendar didDeselectDate:(NSDate *)date {
    if (self.pickDelegate != nil && [self.pickDelegate respondsToSelector:@selector(calendar:didDeselectDate:)]) {
        [self.pickDelegate calendar:calendar didDeselectDate:date];
    }
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date {
    if (self.pickDelegate != nil && [self.pickDelegate respondsToSelector:@selector(calendar:didSelectDate:)]) {
        [self.pickDelegate calendar:calendar didSelectDate:date];
    }
}

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated {
    [self.calendarHeight setConstant:CGRectGetHeight(bounds)];
    bounds.size.height = bounds.size.height + 2.0;
    if (self.pickDelegate != nil && [self.pickDelegate respondsToSelector:@selector(calendar:boundingRectWillChange:animated:)]) {
        [self.pickDelegate calendar:calendar boundingRectWillChange:bounds animated:animated];
    }
}

@end
