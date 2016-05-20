//
//  AddTaskRepeatCell.m
//  ShuchuangClient
//
//  Created by 黄建 on 5/13/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "AddTaskRepeatCell.h"
@interface AddTaskRepeatCell()
@property (weak, nonatomic) IBOutlet UIButton *buttonSunday;
@property (weak, nonatomic) IBOutlet UIButton *buttonMonday;
@property (weak, nonatomic) IBOutlet UIButton *buttonTuesday;
@property (weak, nonatomic) IBOutlet UIButton *buttonWednesday;
@property (weak, nonatomic) IBOutlet UIButton *buttonThursday;
@property (weak, nonatomic) IBOutlet UIButton *buttonFriday;
@property (weak, nonatomic) IBOutlet UIButton *buttonSaturday;
@property (nonatomic) NSInteger repeatDay;

- (void)onWeekdayButton:(id)sender;
- (void)setWeekdayButton:(UIButton *)button selected:(BOOL)selected;
@end
@implementation AddTaskRepeatCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.buttonSunday.layer.cornerRadius = 5.0;
    [self.buttonSunday.layer setBorderColor:[[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0] CGColor]];
    self.buttonSunday.layer.borderWidth = 1.0;
    [self.buttonSunday setTitleColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0] forState:UIControlStateNormal];
    
    self.buttonMonday.layer.cornerRadius = 5.0;
    [self.buttonMonday.layer setBorderColor:[[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0] CGColor]];
    self.buttonMonday.layer.borderWidth = 1.0;
    [self.buttonMonday setTitleColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0] forState:UIControlStateNormal];
    
    self.buttonTuesday.layer.cornerRadius = 5.0;
    [self.buttonTuesday.layer setBorderColor:[[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0] CGColor]];
    self.buttonTuesday.layer.borderWidth = 1.0;
    [self.buttonTuesday setTitleColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0] forState:UIControlStateNormal];
    
    self.buttonWednesday.layer.cornerRadius = 5.0;
    [self.buttonWednesday.layer setBorderColor:[[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0] CGColor]];
    self.buttonWednesday.layer.borderWidth = 1.0;
    [self.buttonWednesday setTitleColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0] forState:UIControlStateNormal];
    
    self.buttonThursday.layer.cornerRadius = 5.0;
    [self.buttonThursday.layer setBorderColor:[[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0] CGColor]];
    self.buttonThursday.layer.borderWidth = 1.0;
    [self.buttonThursday setTitleColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0] forState:UIControlStateNormal];
    
    self.buttonFriday.layer.cornerRadius = 5.0;
    [self.buttonFriday.layer setBorderColor:[[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0] CGColor]];
    self.buttonFriday.layer.borderWidth = 1.0;
    [self.buttonFriday setTitleColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0] forState:UIControlStateNormal];
    
    self.buttonSaturday.layer.cornerRadius = 5.0;
    [self.buttonSaturday.layer setBorderColor:[[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0] CGColor]];
    self.buttonSaturday.layer.borderWidth = 1.0;
    [self.buttonSaturday setTitleColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0] forState:UIControlStateNormal];
    
    [self.buttonSunday addTarget:self action:@selector(onWeekdayButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonMonday addTarget:self action:@selector(onWeekdayButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonTuesday addTarget:self action:@selector(onWeekdayButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonWednesday addTarget:self action:@selector(onWeekdayButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonThursday addTarget:self action:@selector(onWeekdayButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonFriday addTarget:self action:@selector(onWeekdayButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonSaturday addTarget:self action:@selector(onWeekdayButton:) forControlEvents:UIControlEventTouchUpInside];
    self.repeatDay = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initCellRepeatDay:(NSInteger)repeat {
    if ((repeat & 0x40) == 0) {
        [self setWeekdayButton:self.buttonSunday selected:NO];
    }
    else {
        [self setWeekdayButton:self.buttonSunday selected:YES];
    }
    if ((repeat & 0x20) == 0) {
        [self setWeekdayButton:self.buttonMonday selected:NO];
    }
    else {
        [self setWeekdayButton:self.buttonMonday selected:YES];
    }
    if ((repeat & 0x10) == 0) {
        [self setWeekdayButton:self.buttonTuesday selected:NO];
    }
    else {
        [self setWeekdayButton:self.buttonTuesday selected:YES];
    }
    if ((repeat & 0x08) == 0) {
        [self setWeekdayButton:self.buttonWednesday selected:NO];
    }
    else {
        [self setWeekdayButton:self.buttonWednesday selected:YES];
    }
    if ((repeat & 0x04) == 0) {
        [self setWeekdayButton:self.buttonThursday selected:NO];
    }
    else {
        [self setWeekdayButton:self.buttonThursday selected:YES];
    }
    if ((repeat & 0x02) == 0) {
        [self setWeekdayButton:self.buttonFriday selected:NO];
    }
    else {
        [self setWeekdayButton:self.buttonFriday selected:YES];
    }
    if ((repeat & 0x01) == 0) {
        [self setWeekdayButton:self.buttonSaturday selected:NO];
    }
    else {
        [self setWeekdayButton:self.buttonSaturday selected:YES];
    }
    self.repeatDay = repeat;
}

- (void)onWeekdayButton:(id)sender {
    if ([sender isEqual:self.buttonSunday]) {
        if ((self.repeatDay & 0x40) != 0) {
            self.repeatDay &= (~0x40);
            [self setWeekdayButton:self.buttonSunday selected:NO];
        }
        else {
            self.repeatDay |= 0x40;
            [self setWeekdayButton:self.buttonSunday selected:YES];
        }
    }
    else if ([sender isEqual:self.buttonMonday]) {
        if ((self.repeatDay & 0x20) != 0) {
            self.repeatDay &= (~0x20);
            [self setWeekdayButton:self.buttonMonday selected:NO];
        }
        else {
            self.repeatDay |= 0x20;
            [self setWeekdayButton:self.buttonMonday selected:YES];
        }
    }
    else if ([sender isEqual:self.buttonTuesday]) {
        if ((self.repeatDay & 0x10) != 0) {
            self.repeatDay &= (~0x10);
            [self setWeekdayButton:self.buttonTuesday selected:NO];
        }
        else {
            self.repeatDay |= 0x10;
            [self setWeekdayButton:self.buttonTuesday selected:YES];
        }
    }
    else if ([sender isEqual:self.buttonWednesday]) {
        if ((self.repeatDay & 0x08) != 0) {
            self.repeatDay &= (~0x08);
            [self setWeekdayButton:self.buttonWednesday selected:NO];
        }
        else {
            self.repeatDay |= 0x08;
            [self setWeekdayButton:self.buttonWednesday selected:YES];
        }
    }
    else if ([sender isEqual:self.buttonThursday]) {
        if ((self.repeatDay & 0x04) != 0) {
            self.repeatDay &= (~0x04);
            [self setWeekdayButton:self.buttonThursday selected:NO];
        }
        else {
            self.repeatDay |= 0x04;
            [self setWeekdayButton:self.buttonThursday selected:YES];
        }
    }
    else if ([sender isEqual:self.buttonFriday]) {
        if ((self.repeatDay & 0x02) != 0) {
            self.repeatDay &= (~0x02);
            [self setWeekdayButton:self.buttonFriday selected:NO];
        }
        else {
            self.repeatDay |= 0x02;
            [self setWeekdayButton:self.buttonFriday selected:YES];
        }
    }
    else if ([sender isEqual:self.buttonSaturday]) {
        if ((self.repeatDay & 0x01) != 0) {
            self.repeatDay &= (~0x01);
            [self setWeekdayButton:self.buttonSaturday selected:NO];
        }
        else {
            self.repeatDay |= 0x01;
            [self setWeekdayButton:self.buttonSaturday selected:YES];
        }
    }
    if (self.editDelegate != nil && [self.editDelegate respondsToSelector:@selector(repeatChangedTo:)]) {
        [self.editDelegate repeatChangedTo:self.repeatDay];
    }
}

- (void)setWeekdayButton:(UIButton *)button selected:(BOOL)selected {
    if (selected) {
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]];
    }
    else {
        [button setTitleColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor whiteColor]];
    }
}

@end
