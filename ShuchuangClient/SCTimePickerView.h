//
//  SCTimePickerView.h
//  ShuchuangClient
//
//  Created by 黄建 on 5/13/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCTimePickerView : UIView<UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

- (void)setPickedHour:(NSInteger)hour minute:(NSInteger)minute;
- (NSInteger)getPickedHour;
- (NSInteger)getPickedMinute;
@end
