//
//  SCTimePickerView.m
//  ShuchuangClient
//
//  Created by 黄建 on 5/13/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "SCTimePickerView.h"
#import "CustomPickerView1.h"
@implementation SCTimePickerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        UIView *containerView = [[[UINib nibWithNibName:@"SCTimePickerView" bundle:[NSBundle mainBundle]] instantiateWithOwner:self options:nil] objectAtIndex:0];
        CGRect newFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [containerView setFrame:newFrame];
        [self addSubview:containerView];
        self.pickerView.delegate = self;
        self.pickerView.dataSource = self;
    }
    return self;
}

- (void)setPickedHour:(NSInteger)hour minute:(NSInteger)minute {
    [self.pickerView selectRow:hour inComponent:1 animated:NO];
    [self.pickerView selectRow:minute inComponent:2 animated:NO];
    if (hour < 12) {
        [self.pickerView selectRow:0 inComponent:0 animated:NO];
    }
    else {
        [self.pickerView selectRow:1 inComponent:0 animated:NO];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return 2;
    }
    else if (component == 1) {
        return 24;
    }
    else {
        return 60;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (component == 0) {
        return 130.0;
    }
    else {
        return 50.0;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40.0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    if (view != nil) {
        return view;
    }
    if (component == 0) {
        NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"CustomPickerView1" owner:self options:nil];
        CustomPickerView1 *customPickerView = [nib objectAtIndex:0];
        [customPickerView setFrame:CGRectMake(0, 0, 130.0, 40.0)];
        //[customPickerView setBackgroundColor:[UIColor greenColor]];
        if (row == 0) {
            [customPickerView timeBeforeNoon:YES];
            return customPickerView;
        }
        else {
            [customPickerView timeBeforeNoon:NO];
            return customPickerView;
        }
    }
    else if (component == 1) {
        UILabel *hourLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60.0, 40.0)];
        hourLabel.text = [NSString stringWithFormat:@"%ld", (long)row];
        [hourLabel setTextColor:[UIColor colorWithRed:21.0 / 255.0 green:37.0 / 255.0 blue:50.0 / 255.0 alpha:1.0]];
        hourLabel.textAlignment = NSTextAlignmentCenter;
        //[hourLabel setBackgroundColor:[UIColor redColor]];
        return hourLabel;
    }
    else {
        UILabel *minuteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60.0, 40.0)];
        minuteLabel.text = [NSString stringWithFormat:@"%ld", (long)row];
        [minuteLabel setTextColor:[UIColor colorWithRed:21.0 / 255.0 green:37.0 / 255.0 blue:50.0 / 255.0 alpha:1.0]];
        minuteLabel.textAlignment = NSTextAlignmentCenter;
        //[minuteLabel setBackgroundColor:[UIColor blueColor]];
        return minuteLabel;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        if ((row == 0) && ([pickerView selectedRowInComponent:1] >= 12)) {
            [pickerView selectRow:0 inComponent:1 animated:YES];
        }
        else if ((row == 1) && ([pickerView selectedRowInComponent:1] < 12)){
            [pickerView selectRow:12 inComponent:1 animated:YES];
        }
    }
    else if (component == 1) {
        if ((row < 12) && ([pickerView selectedRowInComponent:0] == 1)) {
            [pickerView selectRow:0 inComponent:0 animated:YES];
        }
        else if((row >= 12) && ([pickerView selectedRowInComponent:0] == 0)) {
            [pickerView selectRow:1 inComponent:0 animated:YES];
        }
    }
}

- (NSInteger)getPickedHour {
    return [self.pickerView selectedRowInComponent:1];
}

- (NSInteger)getPickedMinute {
    return [self.pickerView selectedRowInComponent:2];
}
@end
