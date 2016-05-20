//
//  TaskListTableViewCell.h
//  ShuchuangClient
//
//  Created by 黄建 on 2/25/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModifyTaskProtocol.h"
@interface TaskListTableViewCell : UITableViewCell
- (void)setTaskHour:(NSInteger)hour minute:(NSInteger)minute repeatDay:(NSInteger)repeat option:(NSInteger)option active:(NSInteger)active;
- (void)setTaskActive:(BOOL)active;
@property (weak, nonatomic) id<ModifyTaskProtocol> modifyDelegate;
@property NSInteger taskId;
@property NSInteger taskIndex;
@end
