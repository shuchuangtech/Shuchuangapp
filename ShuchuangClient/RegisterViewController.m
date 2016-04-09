//
//  RegisterViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/5/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "RegisterViewController.h"
#import "UIButton+FillBackgroundImage.h"
#import "MyActivityIndicatorView.h"
#import "SCUtil.h"
#import "Bmob.h"
@interface RegisterViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) MyActivityIndicatorView *acFrame;
@property (strong, nonatomic) NSString *registerId;

- (IBAction)onNextBtn:(id)sender;
- (IBAction)textFieldChanged:(id)sender;
- (void) leftBarBtnClicked;
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // activity frame
    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];

    //navigation bar and navigation item
    UIBarButtonItem * leftBarBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(leftBarBtnClicked)];
    [leftBarBtn setTintColor:[UIColor whiteColor]];
    UINavigationItem *naviItem = [[UINavigationItem alloc] init];
    naviItem.leftBarButtonItem = leftBarBtn;
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.naviBar.frame.size.width - 100, self.naviBar.frame.size.height)];
    if (self.registerNewUser) {
        [titleLab setText:@"新用户注册"];
    }
    else {
        [titleLab setText:@"忘记密码"];
    }
    [titleLab setTextColor:[UIColor whiteColor]];
    [titleLab setFont:[UIFont systemFontOfSize:17.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    naviItem.titleView = titleLab;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    [self.naviBar setBackgroundImage:[UIImage imageNamed:@"barBg"] forBarMetrics:UIBarMetricsCompact];
    
    //next button
    [self.nextButton setBackgroundImage:[UIImage imageNamed:@"longButtonActive"] forState:UIControlStateNormal];
    [self.nextButton setBackgroundImage:[UIImage imageNamed:@"longButton"] forState:UIControlStateDisabled];
    self.nextButton.layer.cornerRadius = 5.0;
    self.nextButton.layer.opaque = NO;
    self.nextButton.layer.masksToBounds = YES;
    self.nextButton.enabled = NO;
    
    //textField
    self.textField.delegate = self;
    [self.textField setBackgroundColor:[UIColor clearColor]];
}

- (void)viewWillLayoutSubviews {
    UIImageView *barBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.naviBar.frame.size.height + self.naviBar.frame.origin.y)];
    [barBg setImage:[UIImage imageNamed:@"barBg"]];
    [self.view addSubview:barBg];
    [self.view bringSubviewToFront:self.naviBar];
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, barBg.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - barBg.frame.size.height)];
    [bgView setImage:[UIImage imageNamed:@"background"]];
    UIImageView *textFieldBg = [[UIImageView alloc] initWithFrame:self.textField.frame];
    [textFieldBg setImage:[UIImage imageNamed:@"textFieldBg"]];
    [self.view addSubview:textFieldBg];
    [self.view addSubview:bgView];
    [self.view sendSubviewToBack:bgView];
    [super viewWillLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onNextBtn:(id)sender {
    if ([self.textField isFirstResponder]) {
        [self.textField resignFirstResponder];
    }
    BOOL isMobile = [SCUtil validateMobile:self.registerId];
    BOOL isEmail = [SCUtil validateEmail:self.registerId];
    if (!isMobile && !isEmail) {
        [SCUtil viewController:self showAlertTitle:@"提示" message:@"请输入正确的手机号码或电子邮箱" action:nil];
        self.textField.text = @"";
    }
    else {
        BmobQuery *query = [BmobUser query];
        if (isMobile) {
            [query whereKey:@"mobilePhoneNumber" equalTo:self.registerId];
        }
        else {
            [query whereKey:@"email" equalTo:self.registerId];
        }
        [self.acFrame startAc];
        __weak RegisterViewController *weakSelf = self;
        [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            [weakSelf.acFrame stopAc];
            if (weakSelf.registerNewUser && [array count] != 0) {
                [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"用户已注册" action:nil];
            }
            else if (!weakSelf.registerNewUser && [array count] == 0) {
                [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"用户不存在" action:nil];
            }
            else {
                if (isMobile) {
                    [BmobSMS requestSMSCodeInBackgroundWithPhoneNumber:weakSelf.registerId andTemplate:@"验证码" resultBlock:^(int number, NSError *error) {
                        if (error != nil) {
                            [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"获取短信验证码失败，请稍后再试" action:nil];
                        }
                        else {
                            [weakSelf performSegueWithIdentifier:@"regToMobileVerify" sender:weakSelf];
                        }
                    }];
                }
                else {
                    if ([array count] != 0) {
                        [weakSelf.acFrame startAc];
                        [BmobUser requestPasswordResetInBackgroundWithEmail:weakSelf.registerId];
                        [weakSelf.acFrame stopAc];
                        [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"一封邮件已经发往您注册邮箱，请前往查收" action:^(UIAlertAction * action) {
                            [weakSelf dismissViewControllerAnimated:YES completion:nil];
                        }];
                    }
                    else {
                        [weakSelf performSegueWithIdentifier:@"regToSetPassword" sender:weakSelf];
                    }
                }
            }
        }];
    }
}

- (IBAction)textFieldChanged:(id)sender {
    UITextField *textField = (UITextField *)sender;
    if ([textField.text length] == 0) {
        self.nextButton.enabled = NO;
    }
    else {
        self.nextButton.enabled = YES;
    }
}

-(void) leftBarBtnClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) textFieldDidEndEditing:(UITextField *)textField {
    self.registerId = textField.text;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    [self.textField resignFirstResponder];
    [textField endEditing:YES];
    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"regToMobileVerify"]) {
        id desVC = segue.destinationViewController;
        [desVC setValue:self.registerId forKey:@"phoneNumber"];
        [desVC setValue:@(self.registerNewUser) forKey:@"registerNewUser"];
    }
    else if ([segue.identifier isEqualToString:@"regToSetPassword"]) {
        id desVC = segue.destinationViewController;
        [desVC setValue:self.registerId forKey:@"email"];
        [desVC setValue:@(self.registerNewUser) forKey:@"registerNewUser"];
    }
}


@end
