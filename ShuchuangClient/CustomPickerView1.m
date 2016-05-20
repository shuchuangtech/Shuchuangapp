//
//  CustomPickerView1.m
//  ShuchuangClient
//
//  Created by 黄建 on 5/13/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "CustomPickerView1.h"
@interface CustomPickerView1()
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *img;

@end
@implementation CustomPickerView1

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)timeBeforeNoon:(BOOL)flag {
    if (flag) {
        [self.img setImage:[UIImage imageNamed:@"sun_highlight"]];
        self.label.text = @"上午";
    }
    else {
        [self.img setImage:[UIImage imageNamed:@"moon_highlight"]];
        self.label.text = @"下午";
    }
}

@end
