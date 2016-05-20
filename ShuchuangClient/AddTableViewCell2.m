//
//  AddTableViewCell2.m
//  ShuchuangClient
//
//  Created by 黄建 on 4/28/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "AddTableViewCell2.h"

@implementation AddTableViewCell2

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.authority = 0;
    [self.authButton addTarget:self action:@selector(onAuthButton) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)onAuthButton {
    if (self.authority == 0) {
        self.authority = 1;
        self.authLabel.text = @"普通用户";
        [self.authButton setImage:[UIImage imageNamed:@"switch_off"] forState:UIControlStateNormal];
    }
    else {
        self.authority = 0;
        self.authLabel.text = @"管理员";
        [self.authButton setImage:[UIImage imageNamed:@"switch_on"] forState:UIControlStateNormal];
    }
    [self.authDelegate authChangedTo:self.authority];
}

@end
