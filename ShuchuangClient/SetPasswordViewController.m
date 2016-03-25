//
//  SetPasswordViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/6/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "SetPasswordViewController.h"
#import "MyActivityIndicatorView.h"
#import "Bmob.h"
#import "UIButton+FillBackgroundImage.h"
#import "MobileVerifyViewController.h"
#import "SCUtil.h"

@interface SetPasswordViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *naviItem;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPass;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPassRepeat;
@property (weak, nonatomic) IBOutlet UIButton *btnRegister;
@property (strong, nonatomic) MyActivityIndicatorView *acFrame;

- (void) leftBarBtnClicked;
- (IBAction)onButtonRegister:(id)sender;
@end

@implementation SetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // activity frame
    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];
    
    //text field
    self.textFieldPass.delegate = self;
    self.textFieldPassRepeat.delegate = self;
    
    //navigation bar
    UIBarButtonItem * leftBarBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(leftBarBtnClicked)];
    [leftBarBtn setTintColor:[UIColor colorWithRed:1.0 green:129.0/255.0 blue:0.0 alpha:1.0]];
    self.naviItem.leftBarButtonItem = leftBarBtn;
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    if (self.registerNewUser) {
        [titleLab setText:@"注册"];
        [self.btnRegister setTitle:@"注册成功" forState:UIControlStateNormal];
        [self.btnRegister setTitle:@"注册成功" forState:UIControlStateDisabled];
        [self.btnRegister setTitle:@"注册成功" forState:UIControlStateHighlighted];
    }
    else {
        [titleLab setText:@"设置新密码"];
        [self.btnRegister setTitle:@"修改密码" forState:UIControlStateNormal];
        [self.btnRegister setTitle:@"修改密码" forState:UIControlStateDisabled];
        [self.btnRegister setTitle:@"修改密码" forState:UIControlStateHighlighted];
    }
    [titleLab setTextColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
    [titleLab setFont:[UIFont systemFontOfSize:15.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    self.naviItem.titleView = titleLab;
    
    //button register
    [self.btnRegister setBackgroundImage:[UIButton imageWithColor:[UIButton getColorFromHex:0xffba73 Alpha:1.0]] forState:UIControlStateNormal];
    [self.btnRegister setBackgroundImage:[UIButton imageWithColor:[UIButton getColorFromHex:0xc0c0c0 Alpha:1.0]] forState:UIControlStateDisabled];
    [self.btnRegister setBackgroundImage:[UIButton imageWithColor:[UIButton getColorFromHex:0xff8100 Alpha:1.0]] forState:UIControlStateHighlighted];
    self.btnRegister.layer.cornerRadius = 5.0;
    self.btnRegister.layer.opaque = NO;
    self.btnRegister.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) leftBarBtnClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [textField endEditing:YES];
    if ([textField isEqual:self.textFieldPass]) {
        [self.textFieldPassRepeat becomeFirstResponder];
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

- (IBAction)onButtonRegister:(id)sender {
    if ([self.textFieldPass isFirstResponder]) {
        [self.textFieldPass resignFirstResponder];
    }
    if ([self.textFieldPassRepeat isFirstResponder]) {
        [self.textFieldPassRepeat resignFirstResponder];
    }
    if (![self.textFieldPass.text isEqualToString:self.textFieldPassRepeat.text]) {
        [SCUtil viewController:self showAlertTitle:@"提示" message:@"两次输入的密码不一致" action:nil];
    }
    else if (self.textFieldPass.text.length < 8) {
        [SCUtil viewController:self showAlertTitle:@"提示" message:@"密码长度请大于等于八位" action:nil];
    }
    else {
        [self.acFrame startAc];
        if (self.registerNewUser) {
            BmobUser *buser = [[BmobUser alloc] init];
            buser.password = self.textFieldPass.text;
            if (self.email.length == 0) {
                buser.username = self.phoneNumber;
                buser.mobilePhoneNumber = self.phoneNumber;
            }
            else {
                buser.username = self.email;
                buser.email = self.email;
            }
            [buser signUpInBackgroundWithBlock:^(BOOL isSuccessful, NSError *error) {
                [self.acFrame stopAc];
                if (error != nil) {
                    NSString *info = [[NSString alloc] initWithFormat:@"注册失败 %ld", (long)[error code]];
                    [SCUtil viewController:self showAlertTitle:@"提示" message:info action:^(UIAlertAction * action) {
                        if ([self.presentingViewController isKindOfClass:[MobileVerifyViewController class]]) {
                            [self.presentingViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                        }
                        else {
                            [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                        }
                    }];
                }
                else {
                    [SCUtil viewController:self showAlertTitle:@"提示" message:@"注册成功" action:^(UIAlertAction * action) {
                        if ([self.presentingViewController isKindOfClass:[MobileVerifyViewController class]]) {
                            [self.presentingViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                        }
                        else {
                            [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                        }
                    }];
                }
            }];
        }
        //找回密码此时只考虑手机
        else {
            NSDictionary *dict = @{@"phone":self.phoneNumber, @"password":self.textFieldPass.text};
            [BmobCloud callFunctionInBackground:@"forgetPassword" withParameters:dict block:^(id object, NSError *error) {
                [self.acFrame stopAc];
                if (error) {
                    [SCUtil viewController:self showAlertTitle:@"提示" message:@"密码重设失败" action:^(UIAlertAction * action) {
                        if ([self.presentingViewController isKindOfClass:[MobileVerifyViewController class]]) {
                            [self.presentingViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                        }
                        else {
                            [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                        }
                    }];
                }
                else {
                    NSString *result = (NSString *)object;
                    if ([result isEqualToString:@"good"]) {
                        [SCUtil viewController:self showAlertTitle:@"提示" message:@"密码重设成功" action:^(UIAlertAction * action) {
                                if ([self.presentingViewController isKindOfClass:[MobileVerifyViewController class]]) {
                                    [self.presentingViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                                }
                            }];
                    }
                    else {
                        [SCUtil viewController:self showAlertTitle:@"提示" message:@"密码重设失败" action:^(UIAlertAction * action) {
                            if ([self.presentingViewController isKindOfClass:[MobileVerifyViewController class]]) {
                                [self.presentingViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                            }
                        }];
                    }
                }
            }];
            
        }
    }
}
@end
