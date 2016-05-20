//
//  TaskListTableViewCell.m
//  ShuchuangClient
//
//  Created by 黄建 on 2/25/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "TaskListTableViewCell.h"
@interface TaskListTableViewCell()
@property (weak, nonatomic) IBOutlet UIButton *swButton;
@property (weak, nonatomic) IBOutlet UIImageView *timeImg;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *optionLabel;
@property (weak, nonatomic) IBOutlet UILabel *sundayLabel;
@property (weak, nonatomic) IBOutlet UILabel *mondayLabel;
@property (weak, nonatomic) IBOutlet UILabel *tuesdayLabel;
@property (weak, nonatomic) IBOutlet UILabel *wednesdayLabel;
@property (weak, nonatomic) IBOutlet UILabel *thursdayLabel;
@property (weak, nonatomic) IBOutlet UILabel *fridayLabel;
@property (weak, nonatomic) IBOutlet UILabel *saturdayLabel;

@property (nonatomic) BOOL isActive;
@property (nonatomic) NSInteger repeatDay;
@property (nonatomic) NSInteger hour;
- (void)setCellActive;
- (void)setCellInactive;
- (void)onSwButton;
@end
@implementation TaskListTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.swButton addTarget:self action:@selector(onSwButton) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setCellActive {
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
    [self.swButton setImage:[UIImage imageNamed:@"switch_on"] forState:UIControlStateNormal];
    [self.timeLabel setTextColor:[UIColor colorWithRed:21.0 / 255.0 green:37.0 / 255.0 blue:50.0 / 255.0 alpha:1.0]];
    [self.optionLabel setTextColor:[UIColor colorWithRed:106.0 / 255.0 green:116.0 / 255.0 blue:123.0 / 255.0 alpha:1.0]];
    //sun
    if (self.hour < 12 && self.hour >= 0) {
        [self.timeImg setImage:[UIImage imageNamed:@"sun_highlight"]];
    }
    //moon
    else {
        [self.timeImg setImage:[UIImage imageNamed:@"moon_highlight"]];
    }
    NSInteger mask = 0x40;
    //sunday
    if (0 != (mask & self.repeatDay)) {
        [self.sundayLabel setTextColor:[UIColor colorWithRed:21.0 / 255.0 green:37.0 / 255.0 blue:50.0 / 255.0 alpha:1.0]];
    }
    else {
        [self.sundayLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:197.0 / 255.0 blue:202.0 / 255.0 alpha:1.0]];
    }
    //monday
    if (0 != ((mask >> 1) & self.repeatDay)) {
        [self.mondayLabel setTextColor:[UIColor colorWithRed:21.0 / 255.0 green:37.0 / 255.0 blue:50.0 / 255.0 alpha:1.0]];
    }
    else {
        [self.mondayLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:197.0 / 255.0 blue:202.0 / 255.0 alpha:1.0]];
    }
    //tuesday
    if (0 != ((mask >> 2) & self.repeatDay)) {
        [self.tuesdayLabel setTextColor:[UIColor colorWithRed:21.0 / 255.0 green:37.0 / 255.0 blue:50.0 / 255.0 alpha:1.0]];
    }
    else {
        [self.tuesdayLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:197.0 / 255.0 blue:202.0 / 255.0 alpha:1.0]];
    }
    //wednesday
    if (0 != ((mask >> 3) & self.repeatDay)) {
        [self.wednesdayLabel setTextColor:[UIColor colorWithRed:21.0 / 255.0 green:37.0 / 255.0 blue:50.0 / 255.0 alpha:1.0]];
    }
    else {
        [self.wednesdayLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:197.0 / 255.0 blue:202.0 / 255.0 alpha:1.0]];
    }
    //thursday
    if (0 != ((mask >> 4) & self.repeatDay)) {
        [self.thursdayLabel setTextColor:[UIColor colorWithRed:21.0 / 255.0 green:37.0 / 255.0 blue:50.0 / 255.0 alpha:1.0]];
    }
    else {
        [self.thursdayLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:197.0 / 255.0 blue:202.0 / 255.0 alpha:1.0]];
    }
    //friday
    if (0 != ((mask >> 5) & self.repeatDay)) {
        [self.fridayLabel setTextColor:[UIColor colorWithRed:21.0 / 255.0 green:37.0 / 255.0 blue:50.0 / 255.0 alpha:1.0]];
    }
    else {
        [self.fridayLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:197.0 / 255.0 blue:202.0 / 255.0 alpha:1.0]];
    }
    //saturday
    if (0 != ((mask >> 6) & self.repeatDay)) {
        [self.saturdayLabel setTextColor:[UIColor colorWithRed:21.0 / 255.0 green:37.0 / 255.0 blue:50.0 / 255.0 alpha:1.0]];
    }
    else {
        [self.saturdayLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:197.0 / 255.0 blue:202.0 / 255.0 alpha:1.0]];
    }
}

- (void)setCellInactive {
    [self.contentView setBackgroundColor:[UIColor colorWithRed:250.0 / 255.0 green:250.0 / 255.0 blue:250.0 / 255.0 alpha:1.0]];
    [self.swButton setImage:[UIImage imageNamed:@"switch_off"] forState:UIControlStateNormal];
    [self.swButton setImage:[UIImage imageNamed:@"switch_off"] forState:UIControlStateNormal];
    [self.timeLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:197.0 / 255.0 blue:202.0 / 255.0 alpha:1.0]];
    [self.optionLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:197.0 / 255.0 blue:202.0 / 255.0 alpha:1.0]];
    //sun
    if (self.hour < 12 && self.hour >= 0) {
        [self.timeImg setImage:[UIImage imageNamed:@"sun"]];
    }
    //moon
    else {
        [self.timeImg setImage:[UIImage imageNamed:@"moon"]];
    }
    [self.sundayLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:197.0 / 255.0 blue:202.0 / 255.0 alpha:1.0]];
    [self.mondayLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:197.0 / 255.0 blue:202.0 / 255.0 alpha:1.0]];
    [self.tuesdayLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:197.0 / 255.0 blue:202.0 / 255.0 alpha:1.0]];
    [self.wednesdayLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:197.0 / 255.0 blue:202.0 / 255.0 alpha:1.0]];
    [self.thursdayLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:197.0 / 255.0 blue:202.0 / 255.0 alpha:1.0]];
    [self.fridayLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:197.0 / 255.0 blue:202.0 / 255.0 alpha:1.0]];
    [self.saturdayLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:197.0 / 255.0 blue:202.0 / 255.0 alpha:1.0]];
}

- (void)onSwButton {
    if (self.isActive) {
        [self setCellInactive];
    }
    else {
        [self setCellActive];
    }
    self.isActive = !self.isActive;
    [self.modifyDelegate setTask:self.taskIndex active:self.isActive];
}

- (void)setTaskActive:(BOOL)active {
    self.isActive = active;
    if (active) {
        [self setCellActive];
    }
    else {
        [self setCellInactive];
    }
}

- (void)setTaskHour:(NSInteger)hour minute:(NSInteger)minute repeatDay:(NSInteger)repeat option:(NSInteger)option active:(NSInteger)active {
    self.isActive = (active == 1);
    self.hour = hour;
    self.repeatDay = repeat;
    self.timeLabel.text = [NSString stringWithFormat:@"%ld:%02ld", (long)hour, (long)minute];
    if (option == 0) {
        self.optionLabel.text = @"定时关闭";
    }
    else {
        self.optionLabel.text = @"定时开启";
    }
    if (active) {
        [self setCellActive];
    }
    else {
        [self setCellInactive];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
