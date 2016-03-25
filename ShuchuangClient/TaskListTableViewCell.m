//
//  TaskListTableViewCell.m
//  ShuchuangClient
//
//  Created by 黄建 on 2/25/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "TaskListTableViewCell.h"
@interface TaskListTableViewCell()

- (void)onSwitchTouchInsideUp:(id)sender;
@end
@implementation TaskListTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.taskSwitch addTarget:self action:@selector(onSwitchTouchInsideUp:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)onSwitchTouchInsideUp:(id)sender {
    [self.modifyDelegate setTask:self.taskIndex active:[self.taskSwitch isOn]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
