//
//  UserDetailViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 3/24/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "UserDetailViewController.h"
#import "SCDeviceClient.h"
#import "SCDeviceManager.h"
#import "MyActivityIndicatorView.h"
#import "SCUtil.h"
#import "SCDatePickerView.h"
#import "SCTextField.h"

@interface UserDetailViewController () <UITextFieldDelegate, FSCalendarDelegate, FSCalendarDataSource>
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet SCTextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *swButton;
@property (weak, nonatomic) IBOutlet UILabel *swLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pickerHeight;
@property (weak, nonatomic) IBOutlet SCDatePickerView *pickerView;
@property (copy, nonatomic) NSDictionary* userInfo;
@property (strong, nonatomic) NSMutableDictionary *modifyUserInfo;
@property (weak, nonatomic) NSString* uuid;
@property (weak,  nonatomic) SCDeviceClient* client;
@property (strong, nonatomic) MyActivityIndicatorView* acFrame;
@property (strong, nonatomic) NSDateComponents* dateComp;
@property (nonatomic) CGFloat pickerOriginHeight;

- (void)onDeleteButton;
- (void)onDateLabel;
- (void)onSwButton;
- (void)showPicker;
@end

@implementation UserDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UINavigationItem *naviItem = [[UINavigationItem alloc] init];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"  取消" style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"完成  " style:UIBarButtonItemStylePlain target:self action:@selector(onRightButton)];
    [leftButton setTintColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]];
    [rightButton setTintColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]];
    naviItem.leftBarButtonItem = leftButton;
    naviItem.rightBarButtonItem = rightButton;
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.naviBar.frame.size.width - 100, self.naviBar.frame.size.height)];
    [titleLab setText:@"修改用户"];
    [titleLab setTextColor:[UIColor colorWithRed:21.0 /255.0 green:37.0 / 255.0 blue:50.0 / 255.0 alpha:1.0]];
    [titleLab setFont:[UIFont systemFontOfSize:17.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    naviItem.titleView = titleLab;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    
    self.textField.delegate = self;
    [self.textField setBackgroundColor:[UIColor clearColor]];
    [self.textField setLineColor:[UIColor colorWithRed:191.0 / 255.0 green:197.0 / 255.0 blue:202.0 / 255.0 alpha:1.0]];
    if ([[self.userInfo objectForKey:@"remainopen"] integerValue] == -1) {
        [self.swButton setImage:[UIImage imageNamed:@"switch_off"] forState:UIControlStateNormal];
        self.swLabel.text = @"无限制";
        self.textField.text = @"无限制";
        self.textField.enabled = NO;
    }
    else {
        [self.swButton setImage:[UIImage imageNamed:@"switch_on"] forState:UIControlStateNormal];
        self.swLabel.text = @"限制次数";
        self.textField.enabled = YES;
        self.textField.text = [NSString stringWithFormat:@"%ld", (long)[[self.userInfo objectForKey:@"remainopen"] integerValue]];
        
    }
    self.modifyUserInfo = [[NSMutableDictionary alloc] initWithDictionary:self.userInfo];
    
    [self.deleteButton addTarget:self action:@selector(onDeleteButton) forControlEvents:UIControlEventTouchUpInside];
    
    self.client = [[SCDeviceManager instance] getDevice:self.uuid];
    
    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];
    
    self.dateLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDateLabel)];
    [self.dateLabel addGestureRecognizer:tap];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlag = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
    long long timestamp = [[self.userInfo objectForKey:@"timeofvalidity"] longLongValue];
    NSDate* userDate = [NSDate dateWithTimeIntervalSince1970:timestamp / 1000000.0];
    self.dateComp = [calendar components:unitFlag fromDate:userDate];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[self.userInfo objectForKey:@"timestring"]];
    [attrStr addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle|NSUnderlinePatternSolid) range:NSMakeRange(0, [attrStr length])];
    self.dateLabel.attributedText = attrStr;
    
    self.pickerView.clipsToBounds = YES;
    self.pickerView.pickDelegate = self;
    self.pickerView.pickDataSource = self;
    self.usernameLabel.text = [self.userInfo objectForKey:@"binduser"];
    
    [self.swButton addTarget:self action:@selector(onSwButton) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showPicker {
    if (self.pickerHeight.constant == 0.0) {
        [UIView animateWithDuration:0.5 animations:^ {
            [self.pickerHeight setConstant:self.pickerOriginHeight];
            NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDate *date = [cal dateFromComponents:self.dateComp];
            [self.pickerView.calendar selectDate:date];
            [self.pickerView.calendar setCurrentPage:date animated:YES];
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date {
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlag = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
    self.dateComp = [cal components:unitFlag fromDate:date];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%02ld/%02ld/%04ld", (long)[self.dateComp day], (long)[self.dateComp month], (long)[self.dateComp year]]];
    [attrStr addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle|NSUnderlinePatternSolid) range:NSMakeRange(0, [attrStr length])];
    self.dateLabel.attributedText = attrStr;
    [self.modifyUserInfo setValue:self.dateLabel.text forKey:@"timestring"];
    long long timestamp = [date timeIntervalSince1970] * 1000000;
    [self.modifyUserInfo setValue:[NSNumber numberWithLongLong:timestamp] forKey:@"timeofvalidity"];
}

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated    {
    if (animated) {
        [self.pickerHeight setConstant:CGRectGetHeight(bounds)];
        [self.view layoutIfNeeded];
    }
    else {
        self.pickerOriginHeight = CGRectGetHeight(bounds);
    }
}

- (void)onSwButton {
    if (self.textField.enabled) {
        [self.swButton setImage:[UIImage imageNamed:@"switch_off"] forState:UIControlStateNormal];
        self.swLabel.text = @"无限制";
        self.textField.enabled = NO;
        self.textField.text = @"无限制";
    }
    else {
        [self.swButton setImage:[UIImage imageNamed:@"switch_on"] forState:UIControlStateNormal];
        self.swLabel.text = @"限制次数";
        self.textField.enabled = YES;
        if ([[self.modifyUserInfo objectForKey:@"remainopen"] integerValue] <= 0) {
            self.textField.text = @"";
        }
        else {
            self.textField.text = [NSString stringWithFormat:@"%ld", (long)[[self.modifyUserInfo objectForKey:@"remainopen"] integerValue]];
        }
    }
}

- (void)onLeftButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onRightButton {
    NSInteger remainopen;
    if ([self.textField isFirstResponder]) {
        [self.textField resignFirstResponder];
    }
    if (self.textField.enabled) {
        remainopen = [self.modifyUserInfo[@"remainopen"] integerValue];
    }
    else {
        remainopen = -1;
    }
    NSDictionary *dict = @{@"username":self.modifyUserInfo[@"username"], @"remainopen":[NSNumber numberWithInteger:remainopen], @"timeofvalidity":self.modifyUserInfo[@"timeofvalidity"]};
    [self.acFrame startAc];
    __weak UserDetailViewController *weakSelf = self;
    [self.client topupUser:dict success:^(NSURLSessionDataTask* task, id response) {
        [weakSelf.acFrame stopAc];
        if ([response[@"result"] isEqualToString:@"good"]) {
            [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"修改用户门禁使用权限成功" action:^(UIAlertAction* action) {
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }];
        }
        else {
            [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:response[@"detail"] action:^(UIAlertAction* action) {
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }];
        }
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        [weakSelf.acFrame stopAc];
        [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"网络错误，请稍后再试" action:nil];
    }];
}

- (void)onDateLabel {
    if ([self.textField isFirstResponder]) {
        [self.textField resignFirstResponder];
    }
    [self.dateLabel setTextColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]];
    [self showPicker];
}

- (void)onDeleteButton {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否删除该用户" preferredStyle:UIAlertControllerStyleAlert];
    __weak UserDetailViewController *weakSelf = self;
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action) {
        [weakSelf.acFrame startAc];
        [weakSelf.client deleteUser:[weakSelf.userInfo objectForKey:@"username"] success:^(NSURLSessionDataTask* task, id response) {
            [weakSelf.acFrame stopAc];
            if ([response[@"result"] isEqualToString:@"good"]) {
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }
            else {
                [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:response[@"detail"] action:nil];
            }
        } failure:^(NSURLSessionDataTask* task, NSError* error) {
            [weakSelf.acFrame stopAc];
            [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"网络出错，请稍后再试" action:nil];
        }];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField.text.length != 0) {
        NSInteger remainopen = [textField.text integerValue];
        [self.modifyUserInfo setValue:[NSNumber numberWithInteger:remainopen] forKey:@"remainopen"];
    }
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
