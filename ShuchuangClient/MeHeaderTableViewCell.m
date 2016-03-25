//
//  MeHeaderTableViewCell.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/18/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "MeHeaderTableViewCell.h"
#import "UIButton+FillBackgroundImage.h"
@interface MeHeaderTableViewCell()
@property (strong, nonatomic) UIImageView *headImgView;
@property (strong, nonatomic) UIImageView *rightImgView;
@property (strong, nonatomic) UILabel *labelUsername;
@property (strong, nonatomic) UILabel *labelUsernameConst;
@end
@implementation MeHeaderTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.headImgView = [[UIImageView alloc] init];
    [self.headImgView setImage:[UIImage imageNamed:@"header"]];
    [self addSubview:self.headImgView];
    
    self.rightImgView = [[UIImageView alloc] init];
    [self.rightImgView setImage:[UIImage imageNamed:@"meconf"]];
    [self addSubview:self.rightImgView];
    
    self.labelUsername = [[UILabel alloc] init];
    self.labelUsernameConst = [[UILabel alloc] init];
    self.labelUsernameConst.text = @"用户名";
    [self.labelUsername setFont:[UIFont systemFontOfSize:13]];
    [self.labelUsernameConst setFont:[UIFont systemFontOfSize:14]];
    [self.labelUsername setTextColor:[UIColor darkGrayColor]];
    [self.labelUsernameConst setTextColor:[UIColor darkGrayColor]];
    [self addSubview:self.labelUsername];
    [self addSubview:self.labelUsernameConst];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.frame.size.width;
    [self.headImgView setFrame:CGRectMake(w / 16, 20, w / 6, w / 6)];
    
    CGSize sizeConst = [self.labelUsernameConst.text boundingRectWithSize:CGSizeMake(self.frame.size.width, 0) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.labelUsernameConst.font} context:nil].size;
    [self.labelUsernameConst setFrame:CGRectMake(self.headImgView.frame.origin.x + self.headImgView.frame.size.width + 15, self.frame.size.height / 2 - sizeConst.height - 3, sizeConst.width, sizeConst.height)];
    
    CGSize size = [self.labelUsername.text boundingRectWithSize:CGSizeMake(self.frame.size.width, 0) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.labelUsername.font} context:nil].size;
    [self.labelUsername setFrame:CGRectMake(self.headImgView.frame.origin.x + self.headImgView.frame.size.width + 15, self.labelUsernameConst.frame.origin.y + sizeConst.height + 5, size.width, size.height)];
    
    [self.rightImgView setFrame:CGRectMake(self.frame.size.width - 70, self.frame.size.height / 2 - 20, 40, 40)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUserName:(NSString *)username {
    self.labelUsername.text = username;
}
@end
