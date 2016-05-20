//
//  UserChpasswdViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 4/12/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "UserChpasswdViewController.h"
#import "SCUtil.h"
#import "Bmob.h"
#import "MyActivityIndicatorView.h"

@interface UserChpasswdViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextField *textFieldRepeat;
@property (weak, nonatomic) IBOutlet UITextField *textFieldOldPassword;
@property (strong, nonatomic) MyActivityIndicatorView *acFrame;

- (void)onLeftButton;
- (void)onRightButton;

@end

@implementation UserChpasswdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UINavigationItem *naviItem = [[UINavigationItem alloc] init];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"  取消" style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    [leftButton setTintColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]];
    naviItem.leftBarButtonItem = leftButton;
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"完成  " style:UIBarButtonItemStylePlain target:self action:@selector(onRightButton)];
    [rightButton setTintColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]];
    naviItem.rightBarButtonItem = rightButton;
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.naviBar.frame.size.width - 100, self.naviBar.frame.size.height)];
    [titleLab setText:@"修改密码"];
    [titleLab setTextColor:[UIColor colorWithRed:21.0 / 255.0 green:37.0 / 255.0 blue:50.0 / 255.0 alpha:1.0]];
    [titleLab setFont:[UIFont systemFontOfSize:17.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    naviItem.titleView = titleLab;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    
    self.textField.delegate = self;
    self.textFieldOldPassword.delegate = self;
    self.textFieldRepeat.delegate = self;
    
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
    __weak UserChpasswdViewController *weakSelf = self;
    if (self.textFieldOldPassword.text.length == 0) {
        [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"请输入旧密码" action:^(UIAlertAction *action) {
            [weakSelf.textFieldOldPassword becomeFirstResponder];
        }];
    }
    else if (self.textField.text != self.textFieldRepeat.text) {
        [SCUtil viewController:self showAlertTitle:@"提示" message:@"两次输入的新密码不一致" action:nil];
    }
    else if (self.textField.text.length < 8) {
        [SCUtil viewController:self showAlertTitle:@"提示" message:@"新密码长度至少需要8位" action:nil];
    }
    else {
        BmobUser *user = [BmobUser getCurrentUser];
        NSString *username = [user username];
        [self.acFrame startAc];
        [user updateCurrentUserPasswordWithOldPassword:self.textFieldOldPassword.text newPassword:self.textField.text block:^(BOOL isSuccessful, NSError *error) {
            if (isSuccessful) {
                [BmobUser loginInbackgroundWithAccount:username andPassword:weakSelf.textField.text block:^(BmobUser *user, NSError *error) {
                    [weakSelf.acFrame stopAc];
                    if (error) {
                        [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"使用新密码登录失败" action:nil];
                    }
                    else {
                        [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"修改密码成功" action:^(UIAlertAction *action) {
                            [weakSelf dismissViewControllerAnimated:YES completion:nil];
                        }];
                    }
                }];
            }
            else {
                [weakSelf.acFrame stopAc];
                [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"修改密码失败" action:nil];
            }
        }];
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

- (IBAction)onTextFieldChanged:(id)sender {
}
@end
