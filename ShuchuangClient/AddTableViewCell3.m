//
//  AddTableViewCell3.m
//  ShuchuangClient
//
//  Created by 黄建 on 4/28/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "AddTableViewCell3.h"

@implementation AddTableViewCell3

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.passwordTextField.lineColor = [UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:0.3];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
