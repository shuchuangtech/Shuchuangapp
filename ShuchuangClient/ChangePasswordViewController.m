//
//  ChangePasswordViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/26/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "UIButton+FillBackgroundImage.h"
#import "SCUtil.h"
#import "SCDeviceClient.h"
#import "SCDeviceManager.h"
#import "MyActivityIndicatorView.h"
#import "SCErrorString.h"
@interface ChangePasswordViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextField *textFieldRepeat;
@property (weak, nonatomic) IBOutlet UITextField *textFieldOldPassword;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) NSString *uuid;
@property (strong, nonatomic) MyActivityIndicatorView *acFrame;
@property (strong, nonatomic) UIImageView *barBg;
@property (strong, nonatomic) UIImageView *bgView;
@property (strong, nonatomic) UIImageView *textFieldBg;
@property (strong, nonatomic) UIImageView *textFieldBg2;
@property (strong, nonatomic) UIImageView *textFieldBg3;

- (void)onLeftButton;
- (void)onNextButton;
- (IBAction)onTextFieldChanged:(id)sender;
- (IBAction)onTextFieldRepeatChanged:(id)sender;
- (IBAction)onTextFieldOldPasswordChanged:(id)sender;
@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UINavigationItem *naviItem = [[UINavigationItem alloc] init];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    [leftButton setTintColor:[UIColor whiteColor]];
    naviItem.leftBarButtonItem = leftButton;
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.naviBar.frame.size.width - 100, self.naviBar.frame.size.height)];
    [titleLab setText:@"修改密码"];
    [titleLab setTextColor:[UIColor whiteColor]];
    [titleLab setFont:[UIFont systemFontOfSize:17.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    naviItem.titleView = titleLab;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    [self.naviBar setBackgroundImage:[UIImage imageNamed:@"barBg"] forBarMetrics:UIBarMetricsCompact];
    
    [self.nextButton setBackgroundImage:[UIImage imageNamed:@"longButtonActive"] forState:UIControlStateNormal];
    [self.nextButton setBackgroundImage:[UIImage imageNamed:@"longButton"] forState:UIControlStateDisabled];
    [self.nextButton addTarget:self action:@selector(onNextButton) forControlEvents:UIControlEventTouchUpInside];
    self.nextButton.layer.cornerRadius = 5.0;
    self.nextButton.layer.opaque = NO;
    self.nextButton.layer.masksToBounds = YES;
    self.nextButton.enabled = NO;
    
    self.textField.delegate = self;
    self.textFieldRepeat.delegate = self;
    self.textFieldOldPassword.delegate = self;
    [self.textField setBackgroundColor:[UIColor clearColor]];
    [self.textFieldRepeat setBackgroundColor:[UIColor clearColor]];
    [self.textFieldOldPassword setBackgroundColor:[UIColor clearColor]];
    
    [self.textField addTarget:self action:@selector(onTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.textFieldRepeat addTarget:self action:@selector(onTextFieldRepeatChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.textFieldOldPassword addTarget:self action:@selector(onTextFieldOldPasswordChanged:) forControlEvents:UIControlEventEditingChanged];
    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];
    
    self.barBg = [[UIImageView alloc] init];
    [self.barBg setImage:[UIImage imageNamed:@"barBg"]];
    [self.view addSubview:self.barBg];
    [self.view bringSubviewToFront:self.naviBar];
    self.bgView = [[UIImageView alloc] init];
    [self.bgView setImage:[UIImage imageNamed:@"background"]];
    [self.view addSubview:self.bgView];
    [self.view sendSubviewToBack:self.bgView];
    
    self.textFieldBg = [[UIImageView alloc] init];
    [self.textFieldBg setImage:[UIImage imageNamed:@"textFieldBg"]];
    [self.textFieldOldPassword addSubview:self.textFieldBg];
    
    self.textFieldBg2 = [[UIImageView alloc] initWithFrame:self.textField.frame];
    [self.textFieldBg2 setImage:[UIImage imageNamed:@"textFieldBg"]];
    [self.textField addSubview:self.textFieldBg2];
    
    self.textFieldBg3 = [[UIImageView alloc] initWithFrame:self.textFieldRepeat.frame];
    [self.textFieldBg3 setImage:[UIImage imageNamed:@"textFieldBg"]];
    [self.textFieldRepeat addSubview:self.textFieldBg3];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.barBg setFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    [self.bgView setFrame:CGRectMake(0, self.barBg.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.barBg.frame.size.height)];
    [self.textFieldBg setFrame:CGRectMake(0, 0, self.textFieldOldPassword.frame.size.width, self.textFieldOldPassword.frame.size.height)];
    [self.textFieldBg2 setFrame:CGRectMake(0, 0, self.textField.frame.size.width, self.textField.frame.size.height)];
    [self.textFieldBg3 setFrame:CGRectMake(0, 0, self.textFieldRepeat.frame.size.width, self.textFieldRepeat.frame.size.height)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onLeftButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onNextButton {
    if ([self.textFieldOldPassword isFirstResponder]) {
        [self.textFieldOldPassword resignFirstResponder];
    }
    if ([self.textField isFirstResponder]) {
        [self.textField resignFirstResponder];
    }
    if ([self.textFieldRepeat isFirstResponder]) {
        [self.textFieldRepeat resignFirstResponder];
    }
    if (![self.textField.text isEqualToString:self.textFieldRepeat.text]) {
        [SCUtil viewController:self showAlertTitle:@"提示" message:@"两次输入的密码不一致" action:nil];
    }
    else {
        if ([self.textField.text length] < 8) {
            [SCUtil viewController:self showAlertTitle:@"提示" message:@"密码长度请大于等于八位" action:nil];
        }
        else {
            SCDeviceClient *client = [[SCDeviceManager instance] getDevice:self.uuid];
            __weak ChangePasswordViewController *weakSelf = self;
            [client changeOldPassword:self.textFieldOldPassword.text newPassword:self.textField.text success:^(NSURLSessionDataTask * task, id response) {
                if ([response[@"result"] isEqualToString:@"good"]) {
                    [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"设备密码修改成功" action:^(UIAlertAction *action) {
                        [weakSelf dismissViewControllerAnimated:YES completion:nil];
                    }];
                }
                else {
                    [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:response[@"detail"] action:^(UIAlertAction *action) {
                        [weakSelf dismissViewControllerAnimated:YES completion:nil];
                    }];
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"网络异常，请稍后再试" action:^(UIAlertAction *action) {
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                }];
            }];
        }
    }
}

- (IBAction)onTextFieldChanged:(id)sender {
    if ([self.textField.text length] > 0 && [self.textFieldRepeat.text length] > 0 && [self.textFieldOldPassword.text length] > 0) {
        self.nextButton.enabled = YES;
    }
    else {
        self.nextButton.enabled = NO;
    }
}

- (IBAction)onTextFieldRepeatChanged:(id)sender {
    if ([self.textFieldRepeat.text length] > 0 && [self.textFieldRepeat.text length] > 0 && [self.textFieldOldPassword.text length] > 0) {
        self.nextButton.enabled = YES;
    }
    else {
        self.nextButton.enabled = NO;
    }
}

- (IBAction)onTextFieldOldPasswordChanged:(id)sender {
    if ([self.textFieldRepeat.text length] > 0 && [self.textFieldRepeat.text length] > 0 && [self.textFieldOldPassword.text length] > 0) {
        self.nextButton.enabled = YES;
    }
    else {
        self.nextButton.enabled = NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if ([textField isEqual:self.textFieldOldPassword]) {
        [self.textField becomeFirstResponder];
    }
    else if ([textField isEqual:self.textField]) {
        [self.textFieldRepeat becomeFirstResponder];
    }
    else {

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
