//
//  UserTableViewCell.m
//  ShuchuangClient
//
//  Created by 黄建 on 3/21/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "UserTableViewCell.h"

@implementation UserTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUsername:(NSString *)username authority:(NSInteger)auth remainOpen:(NSInteger)remainOpen timeOfValidity:(NSString *)time remainOpenInvalid:(BOOL)openInvalid timeInvalid:(BOOL)timeInvalid{
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
    self.usernameLabel.text = username;
    [self.usernameLabel setTextColor:[UIColor colorWithRed:21.0 / 255.0 green:37.0 / 255.0 blue:50.0 / 255.0 alpha:1.0]];
    if (remainOpen >= 0) {
        self.remainOpenLabel.text = [NSString stringWithFormat:@"%ld", (long)remainOpen];
    }
    else {
        self.remainOpenLabel.text = @"不限";
    }
    [self.remainOpenLabel setTextColor:[UIColor colorWithRed:21.0 / 255.0 green:37.0 / 255.0 blue:50.0 / 255.0 alpha:1.0]];
    self.timeOfValidityLabel.text = time;
    [self.timeOfValidityLabel setTextColor:[UIColor colorWithRed:21.0 / 255.0 green:37.0 / 255.0 blue:50.0 / 255.0 alpha:1.0]];
    if (!timeInvalid && !openInvalid) {
        if (auth == 9) {
            self.authLabel.text = @"管理员";
            [self.authLabel setTextColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]];
        }
        else {
            self.authLabel.text = @"普通用户";
            [self.authLabel setTextColor:[UIColor colorWithRed:106.0 / 255.0 green:116.0 / 255.0 blue:123.0 / 255.0 alpha:1.0]];
        }
    }
    else {
        [self.contentView setBackgroundColor:[UIColor colorWithRed:250.0 / 255.0 green:250.0 / 255.0 blue:250.0 / 255.0 alpha:1.0]];
        self.authLabel.text = @"用户已失效";
        NSMutableAttributedString *attrUserName = [[NSMutableAttributedString alloc] initWithString:username];
        [attrUserName addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid|NSUnderlineStyleSingle) range:NSMakeRange(0, username.length)];
        [attrUserName addAttribute:NSStrikethroughColorAttributeName value:[UIColor colorWithRed:191.0 / 255.0 green:197.0 / 255.0 blue:202.0 / 255.0 alpha:1.0] range:NSMakeRange(0, username.length)];
        self.usernameLabel.attributedText = attrUserName;
        [self.usernameLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:197.0 / 255.0 blue:202.0 / 255.0 alpha:1.0]];
        [self.authLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:197.0 / 255.0 blue:202.0 / 255.0 alpha:1.0]];
        [self.remainOpenTag setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:197.0 / 255.0 blue:202.0 / 255.0 alpha:1.0]];
        [self.remainOpenTag2 setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:197.0 / 255.0 blue:202.0 / 255.0 alpha:1.0]];
        [self.timeTag setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:197.0 / 255.0 blue:202.0 / 255.0 alpha:1.0]];
        [self.timeOfValidityLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:197.0 / 255.0 blue:202.0 / 255.0 alpha:1.0]];
        [self.remainOpenLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:197.0 / 255.0 blue:202.0 / 255.0 alpha:1.0]];
        if (timeInvalid) {
            NSMutableAttributedString *attrTime = [[NSMutableAttributedString alloc] initWithString:time];
            [attrTime addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid|NSUnderlineStyleSingle) range:NSMakeRange(0, time.length)];
            [attrTime addAttribute:NSStrikethroughColorAttributeName value:[UIColor colorWithRed:191.0 / 255.0 green:197.0 / 255.0 blue:202.0 / 255.0 alpha:1.0] range:NSMakeRange(0, time.length)];
            self.timeOfValidityLabel.attributedText = attrTime;
        }
        else {
            NSString *remainOpenStr = [NSString stringWithFormat:@"%ld", (long)remainOpen];
            NSMutableAttributedString *attrOpen = [[NSMutableAttributedString alloc] initWithString:remainOpenStr];
            [attrOpen addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid|NSUnderlineStyleSingle) range:NSMakeRange(0, remainOpenStr.length)];
            [attrOpen addAttribute:NSStrikethroughColorAttributeName value:[UIColor colorWithRed:191.0 / 255.0 green:197.0 / 255.0 blue:202.0 / 255.0 alpha:1.0] range:NSMakeRange(0, remainOpenStr.length)];
            self.remainOpenLabel.attributedText = attrOpen;
        }
    }
}
@end
