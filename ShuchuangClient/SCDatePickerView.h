//
//  SCDatePickerView.h
//  ShuchuangClient
//
//  Created by 黄建 on 5/13/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCalendar.h"
@interface SCDatePickerView : UIView<FSCalendarDataSource, FSCalendarDelegate>
@property (weak, nonatomic) IBOutlet FSCalendar *calendar;
@property (weak, nonatomic) IBOutlet UIButton *rightArrow;
@property (weak, nonatomic) IBOutlet UIButton *leftArrow;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarHeight;
@property (weak, nonatomic) id<FSCalendarDelegate> pickDelegate;
@property (weak, nonatomic) id<FSCalendarDataSource> pickDataSource;
@end
