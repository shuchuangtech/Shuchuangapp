//
//  TimePickerProtocol.h
//  ShuchuangClient
//
//  Created by 黄建 on 3/23/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TimePickerProtocol <NSObject>
- (void)onTimePickerOKHour:(NSInteger)hour minute:(NSInteger)minute;
- (void)onTimePickerCancel;
@end
