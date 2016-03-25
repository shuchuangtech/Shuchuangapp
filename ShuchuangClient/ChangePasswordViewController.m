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
    UINavigationItem *naviItem = [[UINavigationItem alloc] initWithTitle:@"修改密码"];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    [leftButton setTintColor:[UIColor colorWithRed:1.0 green:129.0 / 255.0 blue:0 alpha:1]];
    naviItem.leftBarButtonItem = leftButton;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    
    [self.nextButton setBackgroundImage:[UIButton imageWithColor:[UIButton getColorFromHex:0xffba73 Alpha:1.0]] forState:UIControlStateNormal];
    [self.nextButton setBackgroundImage:[UIButton imageWithColor:[UIButton getColorFromHex:0xc0c0c0 Alpha:1.0]] forState:UIControlStateDisabled];
    [self.nextButton setBackgroundImage:[UIButton imageWithColor:[UIButton getColorFromHex:0xff8100 Alpha:1.0]] forState:UIControlStateHighlighted];
    [self.nextButton addTarget:self action:@selector(onNextButton) forControlEvents:UIControlEventTouchUpInside];
    self.nextButton.layer.cornerRadius = 5.0;
    self.nextButton.layer.opaque = NO;
    self.nextButton.layer.masksToBounds = YES;
    self.nextButton.enabled = NO;
    
    self.textField.delegate = self;
    self.textFieldRepeat.delegate = self;
    self.textFieldOldPassword.delegate = self;
    [self.textField addTarget:self action:@selector(onTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.textFieldRepeat addTarget:self action:@selector(onTextFieldRepeatChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.textFieldOldPassword addTarget:self action:@selector(onTextFieldOldPasswordChanged:) forControlEvents:UIControlEventEditingChanged];
    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];
    
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
            [client changeOldPassword:self.textFieldOldPassword.text newPassword:self.textField.text success:^(NSURLSessionDataTask * task, id response) {
                if ([response[@"result"] isEqualToString:@"good"]) {
                    [SCUtil viewController:self showAlertTitle:@"提示" message:@"设备密码修改成功" action:^(UIAlertAction *action) {
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }];
                }
                else {
                    [SCUtil viewController:self showAlertTitle:@"提示" message:response[@"detail"] action:^(UIAlertAction *action) {
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }];
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [SCUtil viewController:self showAlertTitle:@"提示" message:@"网络异常，请稍后再试" action:^(UIAlertAction *action) {
                    [self dismissViewControllerAnimated:YES completion:nil];
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
