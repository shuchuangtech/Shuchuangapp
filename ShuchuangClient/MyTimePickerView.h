//
//  MyTimePickerView.h
//  ShuchuangClient
//
//  Created by 黄建 on 3/23/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimePickerProtocol.h"
@interface MyTimePickerView : UIView <UIPickerViewDelegate, UIPickerViewDataSource>
@property (retain, nonatomic) id<TimePickerProtocol> timePickerDelegate;

- (instancetype) initWithFrameInView:(UIView *)view;
- (void)showPicker;
- (void)hidePicker;
@end
