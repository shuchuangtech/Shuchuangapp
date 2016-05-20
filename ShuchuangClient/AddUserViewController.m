//
//  AddUserViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 3/22/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "AddUserViewController.h"
#import "SCDeviceClient.h"
#import "SCDeviceManager.h"
#import "SCUtil.h"
#import "MyActivityIndicatorView.h"
#import "SCTextField.h"
#import "SCDatePickerView.h"
@interface AddUserViewController () <FSCalendarDelegate, FSCalendarDataSource>

@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) NSDateComponents* dateComp;
@property (weak, nonatomic) IBOutlet SCTextField *remainOpenTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UIButton *swButton;
@property (weak, nonatomic) IBOutlet UILabel *swLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pickerHeight;

@property (weak, nonatomic) IBOutlet SCDatePickerView *pickerView;

@property (nonatomic) CGFloat pickerOriginHeight;
@property (copy, nonatomic) NSString* username;
@property (copy, nonatomic) NSString* password;
@property (nonatomic) NSInteger remainopen;
@property (weak, nonatomic) NSString* uuid;
@property (weak, nonatomic) SCDeviceClient* client;
@property (strong, nonnull) MyActivityIndicatorView* acFrame;

- (void)showCalendar;
- (void)onDateLabel;
- (void)onSwButton;
@end

@implementation AddUserViewController

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
    [titleLab setText:@"添加设备使用者"];
    [titleLab setTextColor:[UIColor colorWithRed:21.0 / 255.0 green:37.0 / 255.0 blue:50.0 / 255.0 alpha:1.0]];
    [titleLab setFont:[UIFont systemFontOfSize:17.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    naviItem.titleView = titleLab;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.remainOpenTextField.lineColor = [UIColor colorWithRed:191.0 / 255.0 green:197.0 / 255.0 blue:202.0 / 255.0 alpha:1.0];
    
    [self.swButton addTarget:self action:@selector(onSwButton) forControlEvents:UIControlEventTouchUpInside];
    
    self.remainopen = 0;
    
    self.dateLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDateLabel)];
    [self.dateLabel addGestureRecognizer:gesture];
    
    self.remainOpenTextField.delegate = self;
   
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlag = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
    self.dateComp = [calendar components:unitFlag fromDate:[NSDate date]];
    
    self.dateLabel.text = [NSString stringWithFormat:@"%02ld/%02ld/%04ld", (long)[self.dateComp day], (long)[self.dateComp month], (long)[self.dateComp year]];
    
    self.client = [[SCDeviceManager instance] getDevice:self.uuid];
    
    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];
    
    self.pickerView.clipsToBounds = YES;
    self.pickerView.pickDataSource = self;
    self.pickerView.pickDelegate = self;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onLeftButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onRightButton {
    if ([self.usernameTextField isFirstResponder]) {
        [self.usernameTextField resignFirstResponder];
    }
    else if ([self.passwordTextField isFirstResponder]) {
        [self.passwordTextField resignFirstResponder];
    }
    else if ([self.remainOpenTextField isFirstResponder]) {
        [self.remainOpenTextField resignFirstResponder];
    }    
    if (self.username == nil || (![SCUtil validateEmail:self.username] && ![SCUtil validateMobile:self.username])) {
        [SCUtil viewController:self showAlertTitle:@"提示" message:@"请输入正确的手机号或邮箱" action:nil];
    }
    else if (self.password == nil || [self.password length] < 8)
    {
        [SCUtil viewController:self showAlertTitle:@"提示" message:@"密码长度至少需要8位" action:nil];
    }
    else if (self.remainopen == 0 || self.remainopen < -1 || self.remainopen > 999) {
        [SCUtil viewController:self showAlertTitle:@"提示" message:@"请输入有效的开门次数（1～999）" action:nil];
    }
    else {
        NSString* passSHA1 = [SCUtil generateSHA1String:self.password];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDate *validateDate = [calendar dateFromComponents:self.dateComp];
        long long timestamp = [validateDate timeIntervalSince1970] * 1000000;
        NSDictionary *dict = @{@"username":self.username, @"binduser":self.username, @"password":passSHA1, @"authority":[NSNumber numberWithInteger:8], @"remainopen":[NSNumber numberWithInteger:self.remainopen], @"timeofvalidity":[NSNumber numberWithLongLong:timestamp]};
        __weak AddUserViewController* self_block = self;
        [self.acFrame startAc];
        [self.client addUser:dict success:^(NSURLSessionDataTask* task, id response) {
            [self_block.acFrame stopAc];
            if ([response[@"result"] isEqualToString:@"good"]) {
                [self_block dismissViewControllerAnimated:YES completion:nil];
            }
            else {
                [SCUtil viewController:self_block showAlertTitle:@"提示" message:response[@"detail"] action:nil];
            }
        } failure:^(NSURLSessionDataTask* task, NSError* error) {
            [self_block.acFrame stopAc];
            [SCUtil viewController:self_block showAlertTitle:@"提示" message:@"网络错误，请稍后再试" action:nil];
        }];
    }
}

- (void)onSwButton {
    if (self.remainopen >= 0) {
        [self.swButton setImage:[UIImage imageNamed:@"switch_off"] forState:UIControlStateNormal];
        self.swLabel.text = @"不限次数";
        self.remainopen = -1;
        self.remainOpenTextField.enabled = NO;
        self.remainOpenTextField.placeholder = @"无限制";
    }
    else {
        [self.swButton setImage:[UIImage imageNamed:@"switch_on"] forState:UIControlStateNormal];
        self.swLabel.text = @"限制次数";
        self.remainopen = 0;
        self.remainOpenTextField.enabled = YES;
        self.remainOpenTextField.text = @"";
        self.remainOpenTextField.placeholder = @"1~999";
    }
}

- (void)showCalendar {
    [self.pickerView.calendar selectDate:[NSDate date]];
    if (self.pickerHeight.constant == 0.0) {
        [UIView animateWithDuration:0.5 animations:^ {
            [self.pickerHeight setConstant:self.pickerOriginHeight];
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)onDateLabel {
    [self.dateLabel setTextColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]];
    [self showCalendar];
}


- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)pickedDate {
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlag = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
    self.dateComp = [cal components:unitFlag fromDate:pickedDate];
    self.dateLabel.text = [NSString stringWithFormat:@"%02ld/%02ld/%04ld", (long)[self.dateComp day], (long)[self.dateComp month], (long)[self.dateComp year]];
}

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated {
    if (animated) {
        [self.pickerHeight setConstant:CGRectGetHeight(bounds)];
        [self.view layoutIfNeeded];
    }
    else {
        self.pickerOriginHeight = CGRectGetHeight(bounds);
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:self.usernameTextField]) {
        self.username = textField.text;
    }
    else if ([textField isEqual:self.passwordTextField]) {
        self.password = textField.text;
    }
    else if ([textField isEqual:self.remainOpenTextField]) {
        self.remainopen = [textField.text integerValue];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
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
