//
//  TableViewCell.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/21/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "TableViewCell.h"
@interface TableViewCell()
@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UILabel *label;
@end
@implementation TableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.icon = [[UIImageView alloc] init];
    self.label = [[UILabel alloc] init];
    [self.label setFont:[UIFont systemFontOfSize:13.0]];
    [self.label setTextColor:[UIColor whiteColor]];
    [self addSubview:self.icon];
    [self addSubview:self.label];
    return  self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [self.icon setFrame:CGRectMake(self.frame.size.width / 9 - 6, self.frame.size.height / 2 - 10, 20, 20)];
    [self.label setFrame:CGRectMake(self.frame.size.width / 9 + 18, self.frame.size.height / 2 - 10, self.frame.size.width * 8 / 9 - 22, 20)];
}

- (void)setImage:(UIImage *)image labelText:(NSString *)text {
    [self.icon setImage:image];
    self.label.text = text;
}
@end
