//
//  AddUserViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 3/22/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "AddUserViewController.h"
#import "MyDatePickerView.h"
#import "SCDeviceClient.h"
#import "SCDeviceManager.h"
#import "SCUtil.h"
#import "MyActivityIndicatorView.h"

@interface AddUserViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonnull) MyDatePickerView *datePicker;
@property (strong, nonatomic) NSDateComponents* dateComp;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextFiled;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *remainOpenTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentController;
@property (copy, nonatomic) NSString* username;
@property (copy, nonatomic) NSString* password;
@property (nonatomic) NSInteger remainopen;
@property (weak, nonatomic) NSString* uuid;
@property (weak, nonatomic) SCDeviceClient* client;
@property (strong, nonnull) MyActivityIndicatorView* acFrame;
@property (strong, nonatomic) UIImageView *bgView;
@property (strong, nonatomic) UIImageView *idFieldBg;
@property (strong, nonatomic) UIImageView *passwordFieldBg;
@property (strong, nonatomic) UIImageView *countsFieldBg;
@property (strong, nonatomic) UIImageView *barBg;

- (void)onLeftButton;
- (void)onRightButton;
- (void)onDateLabel;
- (void)onSegValueChanged;
@end

@implementation AddUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UINavigationItem *naviItem = [[UINavigationItem alloc] init];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(onRightButton)];
    [leftButton setTintColor:[UIColor whiteColor]];
    [rightButton setTintColor:[UIColor whiteColor]];
    naviItem.leftBarButtonItem = leftButton;
    naviItem.rightBarButtonItem = rightButton;
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.naviBar.frame.size.width - 100, self.naviBar.frame.size.height)];
    [titleLab setText:@"添加设备使用者"];
    [titleLab setTextColor:[UIColor whiteColor]];
    [titleLab setFont:[UIFont systemFontOfSize:17.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    naviItem.titleView = titleLab;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    [self.naviBar setBackgroundImage:[UIImage imageNamed:@"barBg"] forBarMetrics:UIBarMetricsCompact];
    
    self.datePicker = [[MyDatePickerView alloc] initWithFrameInView:self.view];
    self.datePicker.datePickerDelegate = self;
    [self.view addSubview:self.datePicker];
    
    self.dateLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDateLabel)];
    [self.dateLabel addGestureRecognizer:gesture];
    
    self.usernameTextFiled.delegate = self;
    self.passwordTextField.delegate = self;
    self.remainOpenTextField.delegate = self;
    [self.usernameTextFiled setBackgroundColor:[UIColor clearColor]];
    [self.passwordTextField setBackgroundColor:[UIColor clearColor]];
    [self.remainOpenTextField setBackgroundColor:[UIColor clearColor]];
    
    
    [self.segmentController addTarget:self action:@selector(onSegValueChanged) forControlEvents:UIControlEventValueChanged];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlag = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
    self.dateComp = [calendar components:unitFlag fromDate:[NSDate date]];
    
    self.dateLabel.text = [NSString stringWithFormat:@"%04ld-%02ld-%02ld", (long)[self.dateComp year], (long)[self.dateComp month], (long)[self.dateComp day]];
    
    self.client = [[SCDeviceManager instance] getDevice:self.uuid];
    
    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];
    
    self.barBg = [[UIImageView alloc] init];
    [self.barBg setImage:[UIImage imageNamed:@"barBg"]];
    [self.view addSubview:self.barBg];
    [self.view bringSubviewToFront:self.naviBar];
    
    self.bgView = [[UIImageView alloc] init];
    [self.bgView setImage:[UIImage imageNamed:@"background"]];
    
    self.idFieldBg = [[UIImageView alloc] init];
    [self.idFieldBg setImage:[UIImage imageNamed:@"textFieldBg"]];
    [self.usernameTextFiled addSubview:self.idFieldBg];
    
    self.passwordFieldBg = [[UIImageView alloc] init];
    [self.passwordFieldBg setImage:[UIImage imageNamed:@"textFieldBg"]];
    [self.passwordTextField addSubview:self.passwordFieldBg];
    
    self.countsFieldBg = [[UIImageView alloc] init];
    [self.countsFieldBg setImage:[UIImage imageNamed:@"textFieldBg_small"]];
    [self.remainOpenTextField addSubview:self.countsFieldBg];
    
    [self.view addSubview:self.bgView];
    [self.view sendSubviewToBack:self.bgView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.barBg setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.naviBar.frame.size.height + self.naviBar.frame.origin.y)];
    [self.bgView setFrame:CGRectMake(0, self.barBg.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.barBg.frame.size.height)];
    [self.idFieldBg setFrame:CGRectMake(0, 0, self.usernameTextFiled.frame.size.width, self.usernameTextFiled.frame.size.height)];
    [self.passwordFieldBg setFrame:CGRectMake(0, 0, self.passwordTextField.frame.size.width, self.passwordTextField.frame.size.height)];
    [self.countsFieldBg setFrame:CGRectMake(0, 0, self.remainOpenTextField.frame.size.width, self.remainOpenTextField.frame.size.height)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onLeftButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onRightButton {
    [self.usernameTextFiled endEditing:YES];
    [self.passwordTextField endEditing:YES];
    [self.remainOpenTextField endEditing:YES];
    if (![SCUtil validateEmail:self.username] && ![SCUtil validateMobile:self.username]) {
        [SCUtil viewController:self showAlertTitle:@"提示" message:@"请输入正确的手机号或邮箱" action:nil];
    }
    else if ([self.password length] < 8)
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
        NSInteger timestamp = [validateDate timeIntervalSince1970] * 1000000;
        NSDictionary *dict = @{@"username":self.username, @"binduser":self.username, @"password":passSHA1, @"authority":[NSNumber numberWithInteger:8], @"remainopen":[NSNumber numberWithInteger:self.remainopen], @"timeofvalidity":[NSNumber numberWithInteger:timestamp]};
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

- (void)onDateLabel {
    [self.datePicker showPicker];
}

- (void)onSegValueChanged {
    if ([self.segmentController selectedSegmentIndex] == 0) {
        self.remainOpenTextField.enabled = YES;
        [self.remainOpenTextField setBackgroundColor:[UIColor clearColor]];
        self.remainopen = 0;
    }
    else {
        self.remainOpenTextField.text = @"";
        self.remainOpenTextField.enabled = NO;
        [self.remainOpenTextField setBackgroundColor:[UIColor lightGrayColor]];
        self.remainopen = -1;
    }
}

- (void)onDatePickerOK:(NSDate*)pickedDate {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlag = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
    self.dateComp = [calendar components:unitFlag fromDate:pickedDate];
    self.dateLabel.text = [NSString stringWithFormat:@"%04ld-%02ld-%02ld", (long)[self.dateComp year], (long)[self.dateComp month], (long)[self.dateComp day]];
    [self.datePicker hidePicker];
}

- (void)onDatePickerCancel {
    [self.datePicker hidePicker];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:self.usernameTextFiled]) {
        self.username = textField.text;
    }
    else if ([textField isEqual:self.passwordTextField]) {
        self.password = textField.text;
    }
    else {
        self.remainopen = [textField.text integerValue];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [textField endEditing:YES];
    if ([textField isEqual:self.usernameTextFiled]) {
        [self.passwordTextField becomeFirstResponder];
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
