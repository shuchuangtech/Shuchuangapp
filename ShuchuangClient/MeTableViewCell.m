//
//  MeTableViewCell.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/18/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "MeTableViewCell.h"
@interface MeTableViewCell()
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIImageView *imgView;
@end

@implementation MeTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.label = [[UILabel alloc] init];
    [self.label setFont:[UIFont systemFontOfSize:17.0]];
    [self.label setTextColor:[UIColor darkGrayColor]];
    [self addSubview:self.label];
    self.imgView = [[UIImageView alloc] init];
    [self addSubview:self.imgView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //label
    
    CGSize size = [self.label.text boundingRectWithSize:CGSizeMake(self.frame.size.width, 0) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.label.font} context:nil].size;
    [self.label setFrame:CGRectMake(self.frame.size.width / 8 + 30, self.frame.size.height / 2 - size.height / 2, size.width, size.height)];
    
    //image view
    [self.imgView setFrame:CGRectMake(self.frame.size.width / 8 - 20, self.frame.size.height / 2 - 15, 30, 30)];
}

- (void)setLabelText:(NSString *)text {
    self.label.text = text;
}

- (void)setLeftImage:(UIImage *)img {
    [self.imgView setImage:img];
}
@end
