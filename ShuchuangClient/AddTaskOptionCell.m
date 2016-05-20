//
//  AddTaskOptionCell.m
//  ShuchuangClient
//
//  Created by 黄建 on 5/13/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "AddTaskOptionCell.h"
@interface AddTaskOptionCell()
@property (nonatomic) NSInteger option;
- (void)onSwButton;
@end
@implementation AddTaskOptionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.swButton addTarget:self action:@selector(onSwButton) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)onSwButton {
    if (self.option == 0) {
        self.swLabel.text = @"定时开启";
        [self.swButton setImage:[UIImage imageNamed:@"switch_off"] forState:UIControlStateNormal];
        self.option = 1;
    }
    else {
        self.swLabel.text = @"定时关闭";
        [self.swButton setImage:[UIImage imageNamed:@"switch_on"] forState:UIControlStateNormal];
        self.option = 0;
    }
    if (self.editDelegate != nil && [self.editDelegate respondsToSelector:@selector(optionChangedTo:)]) {
        [self.editDelegate optionChangedTo:self.option];
    }
}

- (void)initCellOption:(NSInteger)option {
    self.option = option;
    if (option == 0) {
        self.swLabel.text = @"定时关闭";
        [self.swButton setImage:[UIImage imageNamed:@"switch_on"] forState:UIControlStateNormal];
    }
    else {
        self.swLabel.text = @"定时开启";
        [self.swButton setImage:[UIImage imageNamed:@"switch_off"] forState:UIControlStateNormal];
    }
}

@end
