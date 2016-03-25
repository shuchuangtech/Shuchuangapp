//
//  AddTaskViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 3/2/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "AddTaskViewController.h"
#import "UIButton+FillBackgroundImage.h"
#import "SCDeviceManager.h"
#import "SCDeviceClient.h"
#import "MyActivityIndicatorView.h"
#import "SCUtil.h"
#import "MyTimePickerView.h"
@interface AddTaskViewController ()
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (strong, nonatomic) NSString *uuid;
@property (strong, nonatomic) NSDictionary *modifyTask;
@property NSInteger modifyIndex;
@property NSInteger pickerHour;
@property NSInteger pickerMinute;
@property NSInteger weekday;
@property NSInteger option;
@property (weak, nonatomic) IBOutlet UIButton *buttonSunday;
@property (weak, nonatomic) IBOutlet UIButton *buttonMonday;
@property (weak, nonatomic) IBOutlet UIButton *buttonTuesday;
@property (weak, nonatomic) IBOutlet UIButton *buttonWednesday;
@property (weak, nonatomic) IBOutlet UIButton *buttonThursday;
@property (weak, nonatomic) IBOutlet UIButton *buttonFriday;
@property (weak, nonatomic) IBOutlet UIButton *buttonSaturday;
@property (strong, nonatomic) SCDeviceClient *client;
@property (strong, nonatomic) MyActivityIndicatorView *acFrame;
@property (weak, nonatomic) IBOutlet UISegmentedControl *taskSegControl;
@property (strong, nonnull) MyTimePickerView* timePicker;

- (void)onWeekdayButton:(id)sender;
- (IBAction)onSegamentChanged:(id)sender;
- (void)onLeftButton;
- (void)onRightButton;
- (void)onButtonSetTime:(id)sender;
@end

@implementation AddTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //navi bar
    UINavigationItem *naviItem;
    if (self.modifyTask == nil) {
        naviItem = [[UINavigationItem alloc] initWithTitle:@"添加任务"];
    }
    else {
        naviItem = [[UINavigationItem alloc] initWithTitle:@"修改任务"];
    }
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(onRightButton)];
    [leftButton setTintColor:[UIColor colorWithRed:1.0 green:129.0 / 255.0 blue:0 alpha:1]];
    [rightButton setTintColor:[UIColor colorWithRed:1.0 green:129.0 / 255.0 blue:0 alpha:1]];
    naviItem.leftBarButtonItem = leftButton;
    naviItem.rightBarButtonItem = rightButton;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    
    //task info variables
    if (self.modifyTask) {
        self.option = [self.modifyTask[@"option"] integerValue];
        self.pickerHour = [self.modifyTask[@"hour"] integerValue];
        self.pickerMinute = [self.modifyTask[@"minute"] integerValue];
        self.weekday = [self.modifyTask[@"weekday"] integerValue];
    }
    else {
        self.option = 0;
        self.pickerHour = 0;
        self.pickerMinute = 0;
        self.weekday = 0;
    }
    
    [self.taskSegControl setSelectedSegmentIndex:self.option];
    //time label
    self.timeLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onButtonSetTime:)];
    [self.timeLabel addGestureRecognizer:labelTapGestureRecognizer];
    self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", self.pickerHour, self.pickerMinute];
    
    //picker view
    self.timePicker = [[MyTimePickerView alloc] initWithFrameInView:self.view];
    self.timePicker.timePickerDelegate = self;
    
    //weekday button
    if ((self.weekday & 0x40) == 0) {
        [self.buttonSunday setBackgroundImage:[UIImage imageNamed:@"repeatday2"] forState:UIControlStateNormal];
    }
    else {
        [self.buttonSunday setBackgroundImage:[UIImage imageNamed:@"repeatday1"] forState:UIControlStateNormal];
    }
    if ((self.weekday & 0x20) == 0) {
        [self.buttonMonday setBackgroundImage:[UIImage imageNamed:@"repeatday2"] forState:UIControlStateNormal];
    }
    else {
        [self.buttonMonday setBackgroundImage:[UIImage imageNamed:@"repeatday1"] forState:UIControlStateNormal];
    }
    if ((self.weekday & 0x10) == 0) {
        [self.buttonTuesday setBackgroundImage:[UIImage imageNamed:@"repeatday2"] forState:UIControlStateNormal];
    }
    else {
        [self.buttonTuesday setBackgroundImage:[UIImage imageNamed:@"repeatday1"] forState:UIControlStateNormal];
    }
    if ((self.weekday & 0x08) == 0) {
        [self.buttonWednesday setBackgroundImage:[UIImage imageNamed:@"repeatday2"] forState:UIControlStateNormal];
    }
    else {
        [self.buttonWednesday setBackgroundImage:[UIImage imageNamed:@"repeatday1"] forState:UIControlStateNormal];
    }
    if ((self.weekday & 0x04) == 0) {
        [self.buttonThursday setBackgroundImage:[UIImage imageNamed:@"repeatday2"] forState:UIControlStateNormal];
    }
    else {
        [self.buttonThursday setBackgroundImage:[UIImage imageNamed:@"repeatday1"] forState:UIControlStateNormal];
    }
    if ((self.weekday & 0x02) == 0) {
        [self.buttonFriday setBackgroundImage:[UIImage imageNamed:@"repeatday2"] forState:UIControlStateNormal];
    }
    else {
        [self.buttonFriday setBackgroundImage:[UIImage imageNamed:@"repeatday1"] forState:UIControlStateNormal];
    }
    if ((self.weekday & 0x01) == 0) {
        [self.buttonSaturday setBackgroundImage:[UIImage imageNamed:@"repeatday2"] forState:UIControlStateNormal];
    }
    else {
        [self.buttonSaturday setBackgroundImage:[UIImage imageNamed:@"repeatday1"] forState:UIControlStateNormal];
    }
    [self.buttonSunday addTarget:self action:@selector(onWeekdayButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonMonday addTarget:self action:@selector(onWeekdayButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonTuesday addTarget:self action:@selector(onWeekdayButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonWednesday addTarget:self action:@selector(onWeekdayButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonThursday addTarget:self action:@selector(onWeekdayButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonFriday addTarget:self action:@selector(onWeekdayButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonSaturday addTarget:self action:@selector(onWeekdayButton:) forControlEvents:UIControlEventTouchUpInside];
    
    //SCDeviceClient
    self.client = [[SCDeviceManager instance] getDevice:self.uuid];
    
    //ac frame
    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onLeftButton {
    [self.addTaskDelegate cancelAdd];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onRightButton {
    if (self.weekday == 0) {
        [SCUtil viewController:self showAlertTitle:@"提示" message:@"请选择任务重复时间" action:nil];
        return;
    }
    if (self.modifyTask == nil) {
        NSDictionary *task = @{@"option" : [NSNumber numberWithInteger:self.option], @"hour" : [NSNumber numberWithInteger:self.pickerHour], @"minute" : [NSNumber numberWithInteger:self.pickerMinute], @"weekday" : [NSNumber numberWithInteger:self.weekday], @"active" : [NSNumber numberWithInt:0]};
        [self.acFrame startAc];
        __block AddTaskViewController *blockSelf = self;
        [self.client addTask:task success:^(NSURLSessionDataTask *task, id response) {
            [blockSelf.acFrame stopAc];
            if (![response[@"result"] isEqualToString:@"good"]) {
                [SCUtil viewController:blockSelf showAlertTitle:@"提示" message:response[@"detail"] action:^(UIAlertAction *action) {
                    [blockSelf dismissViewControllerAnimated:YES completion:nil];
                }];
            }
            else {
                [blockSelf.addTaskDelegate finishAdd];
                [blockSelf dismissViewControllerAnimated:YES completion:nil];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [blockSelf.acFrame stopAc];
            [SCUtil viewController:blockSelf showAlertTitle:@"提示" message:@"网络错误，请稍后再试" action:^(UIAlertAction *action) {
                [blockSelf dismissViewControllerAnimated:YES completion:nil];
            }];
        }];
    }
    else {
        NSDictionary *task = @{@"id":self.modifyTask[@"id"], @"option" : [NSNumber numberWithInteger:self.option], @"hour" : [NSNumber numberWithInteger:self.pickerHour], @"minute" : [NSNumber numberWithInteger:self.pickerMinute], @"weekday" : [NSNumber numberWithInteger:self.weekday], @"active" : [NSNumber numberWithInt:0]};
        [self.acFrame startAc];
        __block AddTaskViewController *blockSelf = self;
        [self.client updateTask:task atIndex:self.modifyIndex success:^(NSURLSessionDataTask *task, id response) {
            [blockSelf.acFrame stopAc];
            if (![response[@"result"] isEqualToString:@"good"]) {
                [SCUtil viewController:blockSelf showAlertTitle:@"提示" message:response[@"detail"] action:^(UIAlertAction *action) {
                    [blockSelf dismissViewControllerAnimated:YES completion:nil];
                }];
            }
            else {
                [blockSelf.addTaskDelegate finishAdd];
                [blockSelf dismissViewControllerAnimated:YES completion:nil];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [blockSelf.acFrame stopAc];
            [SCUtil viewController:blockSelf showAlertTitle:@"提示" message:@"网络错误，请稍后再试" action:^(UIAlertAction *action) {
                [blockSelf dismissViewControllerAnimated:YES completion:nil];
            }];
        }];
    }
}

- (void)onWeekdayButton:(id)sender {
    if ([sender isEqual:self.buttonSunday]) {
        if ((self.weekday & 0x40) != 0) {
            self.weekday &= (~0x40);
            [self.buttonSunday setBackgroundImage:[UIImage imageNamed:@"repeatday2"] forState:UIControlStateNormal];
        }
        else {
            self.weekday |= 0x40;
            [self.buttonSunday setBackgroundImage:[UIImage imageNamed:@"repeatday1"] forState:UIControlStateNormal];
        }
    }
    else if ([sender isEqual:self.buttonMonday]) {
        if ((self.weekday & 0x20) != 0) {
            self.weekday &= (~0x20);
            [self.buttonMonday setBackgroundImage:[UIImage imageNamed:@"repeatday2"] forState:UIControlStateNormal];
        }
        else {
            self.weekday |= 0x20;
            [self.buttonMonday setBackgroundImage:[UIImage imageNamed:@"repeatday1"] forState:UIControlStateNormal];
        }
    }
    else if ([sender isEqual:self.buttonTuesday]) {
        if ((self.weekday & 0x10) != 0) {
            self.weekday &= (~0x10);
            [self.buttonTuesday setBackgroundImage:[UIImage imageNamed:@"repeatday2"] forState:UIControlStateNormal];
        }
        else {
            self.weekday |= 0x10;
            [self.buttonTuesday setBackgroundImage:[UIImage imageNamed:@"repeatday1"] forState:UIControlStateNormal];
        }
    }
    else if ([sender isEqual:self.buttonWednesday]) {
        if ((self.weekday & 0x08) != 0) {
            self.weekday &= (~0x08);
            [self.buttonWednesday setBackgroundImage:[UIImage imageNamed:@"repeatday2"] forState:UIControlStateNormal];
        }
        else {
            self.weekday |= 0x08;
            [self.buttonWednesday setBackgroundImage:[UIImage imageNamed:@"repeatday1"] forState:UIControlStateNormal];
        }
    }
    else if ([sender isEqual:self.buttonThursday]) {
        if ((self.weekday & 0x04) != 0) {
            self.weekday &= (~0x04);
            [self.buttonThursday setBackgroundImage:[UIImage imageNamed:@"repeatday2"] forState:UIControlStateNormal];
        }
        else {
            self.weekday |= 0x04;
            [self.buttonThursday setBackgroundImage:[UIImage imageNamed:@"repeatday1"] forState:UIControlStateNormal];
        }
    }
    else if ([sender isEqual:self.buttonFriday]) {
        if ((self.weekday & 0x02) != 0) {
            self.weekday &= (~0x02);
            [self.buttonFriday setBackgroundImage:[UIImage imageNamed:@"repeatday2"] forState:UIControlStateNormal];
        }
        else {
            self.weekday |= 0x02;
            [self.buttonFriday setBackgroundImage:[UIImage imageNamed:@"repeatday1"] forState:UIControlStateNormal];
        }
    }
    else if ([sender isEqual:self.buttonSaturday]) {
        if ((self.weekday & 0x01) != 0) {
            self.weekday &= (~0x01);
            [self.buttonSaturday setBackgroundImage:[UIImage imageNamed:@"repeatday2"] forState:UIControlStateNormal];
        }
        else {
            self.weekday |= 0x01;
            [self.buttonSaturday setBackgroundImage:[UIImage imageNamed:@"repeatday1"] forState:UIControlStateNormal];
        }
    }
}

- (void)onButtonSetTime:(id)sender {
    [self.timePicker showPicker];
}

- (void)onTimePickerCancel {
    [self.timePicker hidePicker];
}

- (void)onTimePickerOKHour:(NSInteger)hour minute:(NSInteger)minute {
    self.pickerHour = hour;
    self.pickerMinute = minute;
    self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", hour, minute];
    [self.timePicker hidePicker];
}

#pragma mark - picker datasource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return 24;
    }
    else if(component == 1){
        return 60;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%02ld", row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        self.pickerHour = row;
    }
    else {
        self.pickerMinute = row;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onSegamentChanged:(id)sender {
    UISegmentedControl *seg = (UISegmentedControl *)sender;
    self.option = [seg selectedSegmentIndex];
}
@end
