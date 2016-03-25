//
//  DatePickerProtocol.h
//  ShuchuangClient
//
//  Created by 黄建 on 3/22/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol DatePickerProtocol <NSObject>
- (void)onDatePickerOK:(NSDate*)pickedDate;
- (void)onDatePickerCancel;

@end
