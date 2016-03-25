//
//  LoginViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/5/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "LoginViewController.h"
#import "UIButton+FillBackgroundImage.h"
#import "MyActivityIndicatorView.h"
#import "Bmob.h"
#import "SCUtil.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *naviItem;
@property (weak, nonatomic) IBOutlet UITextField *idField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) MyActivityIndicatorView *acFrame;
@property (nonatomic) BOOL registerNewUser;
@property (strong, nonatomic) NSString *loginId;
@property (strong, nonatomic) NSString *loginPass;
@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;

- (IBAction)onBtnForget:(id)sender;
- (IBAction)onBtnRegister:(id)sender;
- (IBAction)onBtnLogin:(id)sender;
- (void) leftBarBtnClicked;
- (IBAction)idFieldChanged:(id)sender;
- (IBAction)passFieldChanged:(id)sender;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // activity frame
    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];
    
    //text field
    self.idField.delegate = self;
    self.passwordField.delegate = self;
    
    //login button
    [self.buttonLogin setBackgroundImage:[UIButton imageWithColor:[UIButton getColorFromHex:0xffba73 Alpha:1.0]] forState:UIControlStateNormal];
    [self.buttonLogin setBackgroundImage:[UIButton imageWithColor:[UIButton getColorFromHex:0xc0c0c0 Alpha:1.0]] forState:UIControlStateDisabled];
    [self.buttonLogin setBackgroundImage:[UIButton imageWithColor:[UIButton getColorFromHex:0xff8100 Alpha:1.0]] forState:UIControlStateHighlighted];
    self.buttonLogin.layer.cornerRadius = 5.0;
    self.buttonLogin.layer.opaque = NO;
    self.buttonLogin.layer.masksToBounds = YES;
    self.buttonLogin.enabled = NO;
    
    //navigation bar and navigation item
    UIBarButtonItem * leftBarBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(leftBarBtnClicked)];
    [leftBarBtn setTintColor:[UIColor colorWithRed:1.0 green:129.0/255.0 blue:0.0 alpha:1.0]];
    self.naviItem.leftBarButtonItem = leftBarBtn;
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    
    [titleLab setText:@"登录"];
    [titleLab setTextColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
    [titleLab setFont:[UIFont systemFontOfSize:15.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    self.naviItem.titleView = titleLab;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:self.idField]) {
        self.loginId = textField.text;
    }
    else if ([textField isEqual:self.passwordField]) {
        self.loginPass = textField.text;
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [textField endEditing:YES];
    if ([textField isEqual:self.idField]) {
        [self.passwordField becomeFirstResponder];
    }
    else if ([textField isEqual:self.passwordField]) {
        [self onBtnLogin:self];
    }
    return YES;
}

- (IBAction)onBtnForget:(id)sender {
    if ([self.idField isFirstResponder]) {
        [self.idField resignFirstResponder];
    }
    if ([self.passwordField isFirstResponder]) {
        [self.passwordField resignFirstResponder];
    }
    self.registerNewUser = NO;
    [self performSegueWithIdentifier:@"loginToRegister" sender:self];
}

- (IBAction)onBtnRegister:(id)sender {
    if ([self.idField isFirstResponder]) {
        [self.idField resignFirstResponder];
    }
    if ([self.passwordField isFirstResponder]) {
        [self.passwordField resignFirstResponder];
    }
    self.registerNewUser = YES;
    [self performSegueWithIdentifier:@"loginToRegister" sender:self];
}

- (IBAction)onBtnLogin:(id)sender {
    if ([self.idField isFirstResponder]) {
        [self.idField resignFirstResponder];
    }
    if ([self.passwordField isFirstResponder]) {
        [self.passwordField resignFirstResponder];
    }
    [self.acFrame startAc];
    [BmobUser loginWithUsernameInBackground:self.loginId password:self.loginPass block:^(BmobUser *user, NSError *error) {
        [self.acFrame stopAc];
        if (user == nil) {
            if ([error code] == 101) {
                [SCUtil viewController:self showAlertTitle:@"提示" message:@"用不不存在或密码错误" action:nil];
                NSLog(@"error %@", error);
            }
            else {
                NSString *string = [NSString stringWithFormat:@"未知错误%ld", (long)[error code]];
                [SCUtil viewController:self showAlertTitle:@"提示" message:string action:nil];
            }
        }
        else {
            [SCUtil viewController:self showAlertTitle:@"提示" message:@"登录成功" action:^(UIAlertAction *action) {
                [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            }];
            
        }
    }];
}

- (void) leftBarBtnClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)idFieldChanged:(id)sender {
    if (self.idField.text.length > 0 && self.passwordField.text.length > 0) {
        self.buttonLogin.enabled = YES;
    }
    else {
        self.buttonLogin.enabled = NO;
    }
}

- (IBAction)passFieldChanged:(id)sender {
    if (self.idField.text.length > 0 && self.passwordField.text.length > 0) {
        self.buttonLogin.enabled = YES;
    }
    else {
        self.buttonLogin.enabled = NO;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"loginToRegister"]) {
        id desVC = segue.destinationViewController;
        [desVC setValue:@(self.registerNewUser) forKey:@"registerNewUser"];
    }
}


@end
