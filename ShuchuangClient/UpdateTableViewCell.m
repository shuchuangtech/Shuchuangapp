//
//  UpdateTableViewCell.m
//  ShuchuangClient
//
//  Created by 黄建 on 3/29/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "UpdateTableViewCell.h"

@implementation UpdateTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.featureLabel.hidden = YES;
    self.buttonUpdate.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)layoutSubviews {
    if (self.myImageView.image == nil) {
        self.widthConstr.constant = 0.0;
        self.heightConstr.constant = 0.0;
    }
    [super layoutSubviews];
}

@end
