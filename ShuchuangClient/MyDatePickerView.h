//
//  MyDatePickerView.h
//  ShuchuangClient
//
//  Created by 黄建 on 3/22/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatePickerProtocol.h"
@interface MyDatePickerView : UIView
@property (retain, nonatomic) id<DatePickerProtocol> datePickerDelegate;
- (instancetype) initWithFrameInView:(UIView *)view;
- (void)showPicker;
- (void)hidePicker;
- (void)setDate:(NSDate *)date;
@end
