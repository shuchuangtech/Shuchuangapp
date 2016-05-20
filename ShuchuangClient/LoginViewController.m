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
#import "SCTextField.h"
@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet SCTextField *idField;
@property (weak, nonatomic) IBOutlet SCTextField *passwordField;
@property (strong, nonatomic) MyActivityIndicatorView *acFrame;
@property (nonatomic) BOOL registerNewUser;
@property (strong, nonatomic) NSString *loginId;
@property (strong, nonatomic) NSString *loginPass;
@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;
@property (strong, nonatomic) UIImageView *bgView;
@property (weak, nonatomic) IBOutlet UIButton *buttonForget;


- (IBAction)onBtnForget:(id)sender;
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
    UIImageView *idFieldIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tel"]];
    self.idField.leftView = idFieldIcon;
    self.idField.leftViewMode = UITextFieldViewModeAlways;
    UIImageView *passFieldIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"password"]];
    self.passwordField.leftView = passFieldIcon;
    self.passwordField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordField.delegate = self;
    [self.idField setBackgroundColor:[UIColor clearColor]];
    [self.passwordField setBackgroundColor:[UIColor clearColor]];
    
    //button reg forget
    NSDictionary *attrDic = @{NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    NSMutableAttributedString *forgetStr = [[NSMutableAttributedString alloc] initWithString:@"密码忘记了？找回密码" attributes:attrDic];
    self.buttonForget.titleLabel.attributedText = forgetStr;
    
    //login button
    [self.buttonLogin setBackgroundColor:[UIColor whiteColor]];
    [self.buttonLogin setAlpha:0.3];
    self.buttonLogin.layer.cornerRadius = 18.0;
    self.buttonLogin.layer.opaque = NO;
    self.buttonLogin.layer.masksToBounds = YES;
    self.buttonLogin.enabled = NO;
    
    //navigation bar and navigation item
    UIBarButtonItem * leftBarBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_white"] style:UIBarButtonItemStyleDone target:self action:@selector(leftBarBtnClicked)];
    UINavigationItem *naviItem = [[UINavigationItem alloc] init];
    [leftBarBtn setTintColor:[UIColor whiteColor]];
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.naviBar.frame.size.width - 100, self.naviBar.frame.size.height)];
    [titleLab setText:@"登录"];
    [titleLab setTextColor:[UIColor whiteColor]];
    [titleLab setFont:[UIFont systemFontOfSize:17.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    naviItem.titleView = titleLab;
    naviItem.leftBarButtonItem = leftBarBtn;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    self.naviBar.clipsToBounds = YES;
    [self.naviBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsCompact];
    
    self.bgView = [[UIImageView alloc] init];
    [self.bgView setImage:[UIImage imageNamed:@"background"]];
    
    [self.view addSubview:self.bgView];
    [self.view sendSubviewToBack:self.bgView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.bgView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
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

- (IBAction)onBtnLogin:(id)sender {
    if ([self.idField isFirstResponder]) {
        [self.idField resignFirstResponder];
    }
    if ([self.passwordField isFirstResponder]) {
        [self.passwordField resignFirstResponder];
    }
    [self.acFrame startAc];
    __weak LoginViewController *block_self = self;
    [BmobUser loginWithUsernameInBackground:block_self.loginId password:block_self.loginPass block:^(BmobUser *user, NSError *error) {
        [block_self.acFrame stopAc];
        if (user == nil) {
            if ([error code] == 101) {
                [SCUtil viewController:block_self showAlertTitle:@"提示" message:@"用不不存在或密码错误" action:nil];
            }
            else {
                NSString *string = [NSString stringWithFormat:@"未知错误%ld", (long)[error code]];
                [SCUtil viewController:block_self showAlertTitle:@"提示" message:string action:nil];
            }
        }
        else {
            [SCUtil viewController:block_self showAlertTitle:@"提示" message:@"登录成功" action:^(UIAlertAction *action) {
                [block_self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
        [self.buttonLogin setAlpha:1.0];
    }
    else {
        self.buttonLogin.enabled = NO;
        [self.buttonLogin setAlpha:0.3];
    }
}

- (IBAction)passFieldChanged:(id)sender {
    if (self.idField.text.length > 0 && self.passwordField.text.length > 0) {
        self.buttonLogin.enabled = YES;
        [self.buttonLogin setAlpha:1.0];
    }
    else {
        self.buttonLogin.enabled = NO;
        [self.buttonLogin setAlpha:0.3];
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
