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
@property (strong, nonatomic) NSString *uuid;
@property (strong, nonatomic) MyActivityIndicatorView *acFrame;

- (void)onLeftButton;
- (void)onRightButton;
@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UINavigationItem *naviItem = [[UINavigationItem alloc] init];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"  取消" style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    [leftButton setTintColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"完成  " style:UIBarButtonItemStylePlain target:self action:@selector(onRightButton)];
    [rightButton setTintColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]];
    naviItem.leftBarButtonItem = leftButton;
    naviItem.rightBarButtonItem = rightButton;
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.naviBar.frame.size.width - 100, self.naviBar.frame.size.height)];
    [titleLab setText:@"修改设备密码"];
    [titleLab setTextColor:[UIColor colorWithRed:21.0 / 255.0 green:37.0 / 255.0 blue:50.0 / 255.0 alpha:1.0]];
    [titleLab setFont:[UIFont systemFontOfSize:17.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    naviItem.titleView = titleLab;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    
    self.textField.delegate = self;
    self.textFieldRepeat.delegate = self;
    self.textFieldOldPassword.delegate = self;
    [self.textField setBackgroundColor:[UIColor clearColor]];
    [self.textFieldRepeat setBackgroundColor:[UIColor clearColor]];
    [self.textFieldOldPassword setBackgroundColor:[UIColor clearColor]];
    
    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onLeftButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onRightButton {
    if ([self.textFieldOldPassword isFirstResponder]) {
        [self.textFieldOldPassword resignFirstResponder];
    }
    if ([self.textField isFirstResponder]) {
        [self.textField resignFirstResponder];
    }
    if ([self.textFieldRepeat isFirstResponder]) {
        [self.textFieldRepeat resignFirstResponder];
    }
    if ([self.textFieldOldPassword.text length] == 0) {
        [SCUtil viewController:self showAlertTitle:@"提示" message:@"请输入旧密码" action:nil];
        return;
    }
    if ([self.textField.text length] == 0 || [self.textFieldRepeat.text length] == 0) {
        [SCUtil viewController:self showAlertTitle:@"提示" message:@"请输入两次新密码" action:nil];
        return;
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
