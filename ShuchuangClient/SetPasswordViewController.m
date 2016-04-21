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
@property (weak, nonatomic) IBOutlet UITextField *textFieldPass;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPassRepeat;
@property (weak, nonatomic) IBOutlet UIButton *btnRegister;
@property (strong, nonatomic) MyActivityIndicatorView *acFrame;
@property (weak, nonatomic) NSString *phoneNumber;
@property (weak, nonatomic) NSString *SMSCode;
@property (nonatomic) BOOL registerNewUser;
@property (strong, nonatomic) UIImageView *barBg;
@property (strong, nonatomic) UIImageView *bgView;
@property (strong, nonatomic) UIImageView *textFieldBg1;
@property (strong, nonatomic) UIImageView *textFieldBg2;


- (IBAction)passwordChanged:(id)sender;
- (IBAction)passwordRepeatChanged:(id)sender;
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
    [self.textFieldPass setBackgroundColor:[UIColor clearColor]];
    [self.textFieldPassRepeat setBackgroundColor:[UIColor clearColor]];
    
    //navigation bar
    UIBarButtonItem * leftBarBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(leftBarBtnClicked)];
    [leftBarBtn setTintColor:[UIColor whiteColor]];
    UINavigationItem *naviItem = [[UINavigationItem alloc] init];
    naviItem.leftBarButtonItem = leftBarBtn;
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.naviBar.frame.size.width - 100, self.naviBar.frame.size.height)];
    [titleLab setTextColor:[UIColor whiteColor]];
    [titleLab setFont:[UIFont systemFontOfSize:17.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    naviItem.titleView = titleLab;
    if (self.registerNewUser) {
        [titleLab setText:@"注册"];
        [self.btnRegister setTitle:@"注册" forState:UIControlStateNormal];
        [self.btnRegister setTitle:@"注册" forState:UIControlStateDisabled];
        [self.btnRegister setTitle:@"注册" forState:UIControlStateHighlighted];
    }
    else {
        [titleLab setText:@"设置新密码"];
        [self.btnRegister setTitle:@"修改密码" forState:UIControlStateNormal];
        [self.btnRegister setTitle:@"修改密码" forState:UIControlStateDisabled];
        [self.btnRegister setTitle:@"修改密码" forState:UIControlStateHighlighted];
    }
    naviItem.titleView = titleLab;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    [self.naviBar setBackgroundImage:[UIImage imageNamed:@"barBg"] forBarMetrics:UIBarMetricsCompact];
    
    //button register
    [self.btnRegister setBackgroundImage:[UIImage imageNamed:@"longButtonActive"] forState:UIControlStateNormal];
    [self.btnRegister setBackgroundImage:[UIImage imageNamed:@"longButton"] forState:UIControlStateDisabled];
    self.btnRegister.layer.cornerRadius = 5.0;
    self.btnRegister.layer.opaque = NO;
    self.btnRegister.layer.masksToBounds = YES;
    self.btnRegister.enabled = NO;
    
    self.barBg = [[UIImageView alloc] init];
    [self.barBg setImage:[UIImage imageNamed:@"barBg"]];
    [self.view addSubview:self.barBg];
    [self.view bringSubviewToFront:self.naviBar];
    self.bgView = [[UIImageView alloc] init];
    [self.bgView setImage:[UIImage imageNamed:@"background"]];
    self.textFieldBg1 = [[UIImageView alloc] init];
    [self.textFieldBg1 setImage:[UIImage imageNamed:@"textFieldBg"]];
    [self.textFieldPass addSubview:self.textFieldBg1];
    self.textFieldBg2 = [[UIImageView alloc] init];
    [self.textFieldBg2 setImage:[UIImage imageNamed:@"textFieldBg"]];
    [self.textFieldPassRepeat addSubview:self.textFieldBg2];
    [self.view addSubview:self.bgView];
    [self.view sendSubviewToBack:self.bgView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.barBg setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.naviBar.frame.size.height + self.naviBar.frame.origin.y)];
    [self.bgView setFrame:CGRectMake(0, self.barBg.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.barBg.frame.size.height)];
    [self.textFieldBg1 setFrame:CGRectMake(0, 0, self.textFieldPass.frame.size.width, self.textFieldPass.frame.size.height)];
    [self.textFieldBg2 setFrame:CGRectMake(0, 0, self.textFieldPassRepeat.frame.size.width, self.textFieldPassRepeat.frame.size.height)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)passwordChanged:(id)sender {
    if (self.textFieldPass.text.length > 0 && self.textFieldPassRepeat.text.length > 0) {
        self.btnRegister.enabled = YES;
    }
}

- (IBAction)passwordRepeatChanged:(id)sender {
    if (self.textFieldPass.text.length > 0 && self.textFieldPassRepeat.text.length > 0) {
        self.btnRegister.enabled = YES;
    }
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
            buser.username = self.phoneNumber;
            buser.mobilePhoneNumber = self.phoneNumber;
            __weak SetPasswordViewController *weakSelf = self;
            [buser signUpInBackgroundWithBlock:^(BOOL isSuccessful, NSError *error) {
                [weakSelf.acFrame stopAc];
                if (error != nil) {
                    NSString *info = [[NSString alloc] initWithFormat:@"注册失败 %ld", (long)[error code]];
                    [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:info action:^(UIAlertAction * action) {
                        if ([weakSelf.presentingViewController isKindOfClass:[MobileVerifyViewController class]]) {
                            [weakSelf.presentingViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                        }
                        else {
                            [weakSelf.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                        }
                    }];
                }
                else {
                    [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"注册成功" action:^(UIAlertAction * action) {
                        [BmobUser loginWithUsernameInBackground:weakSelf.phoneNumber password:weakSelf.textFieldPass.text block:^(BmobUser *user, NSError *error) {
                            [weakSelf.presentingViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                        }];
                    }];
                }
            }];
        }
        //找回密码此时只考虑手机
        else {
            NSDictionary *dict = @{@"phone":self.phoneNumber, @"password":self.textFieldPass.text};
            __weak SetPasswordViewController *weakSelf = self;
            [BmobCloud callFunctionInBackground:@"forgetPassword" withParameters:dict block:^(id object, NSError *error) {
                [weakSelf.acFrame stopAc];
                if (error) {
                    [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"密码重设失败" action:^(UIAlertAction * action) {
                        [weakSelf.presentingViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                    }];
                }
                else {
                    NSString *result = (NSString *)object;
                    if ([result isEqualToString:@"good"]) {
                        [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"密码重设成功" action:^(UIAlertAction * action) {
                                [BmobUser loginWithUsernameInBackground:weakSelf.phoneNumber password:weakSelf.textFieldPass.text block:^(BmobUser *user, NSError *error) {
                                    [weakSelf.presentingViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                                }];
                            }];
                    }
                    else {
                        [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"密码重设失败" action:^(UIAlertAction * action) {
                            [weakSelf.presentingViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                        }];
                    }
                }
            }];
        }
    }
}
@end
