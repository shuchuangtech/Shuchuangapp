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
@property (retain, nonatomic) id<ModifyTaskProtocol> modifyDelegate;
@property (weak, nonatomic) IBOutlet UILabel *excuteTime;
@property (weak, nonatomic) IBOutlet UILabel *optionLabel;
@property NSInteger taskId;
@property (weak, nonatomic) IBOutlet UILabel *repeatDay;
@property (weak, nonatomic) IBOutlet UISwitch *taskSwitch;
@property NSInteger taskIndex;
@end
