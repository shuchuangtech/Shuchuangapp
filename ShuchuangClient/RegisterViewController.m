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
@property (weak, nonatomic) IBOutlet UINavigationItem *naviItem;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) MyActivityIndicatorView *acFrame;
@property (strong, nonatomic) NSString *registerId;

- (IBAction)onNextBtn:(id)sender;
- (IBAction)textFieldChanged:(id)sender;
- (void) showAlertTitle:(NSString *)title Message:(NSString *)message;
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
    [leftBarBtn setTintColor:[UIColor colorWithRed:1.0 green:129.0/255.0 blue:0.0 alpha:1.0]];
    self.naviItem.leftBarButtonItem = leftBarBtn;
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.naviBar.frame.size.width - 100, self.naviBar.frame.size.height)];
    if (self.registerNewUser) {
        [titleLab setText:@"新用户注册"];
    }
    else {
        [titleLab setText:@"忘记密码"];
    }
    [titleLab setTextColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
    [titleLab setFont:[UIFont systemFontOfSize:15.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    self.naviItem.titleView = titleLab;
    
    //next button
    [self.nextButton setBackgroundImage:[UIButton imageWithColor:[UIButton getColorFromHex:0xffba73 Alpha:1.0]] forState:UIControlStateNormal];
    [self.nextButton setBackgroundImage:[UIButton imageWithColor:[UIButton getColorFromHex:0xc0c0c0 Alpha:1.0]] forState:UIControlStateDisabled];
    [self.nextButton setBackgroundImage:[UIButton imageWithColor:[UIButton getColorFromHex:0xff8100 Alpha:1.0]] forState:UIControlStateHighlighted];
    self.nextButton.layer.cornerRadius = 5.0;
    self.nextButton.layer.opaque = NO;
    self.nextButton.layer.masksToBounds = YES;
    self.nextButton.enabled = NO;
    
    //textField
    self.textField.delegate = self;
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
        [self showAlertTitle:@"提示" Message:@"请输入正确的手机号码或电子邮箱"];
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
        [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            [self.acFrame stopAc];
            if (self.registerNewUser && [array count] != 0) {
                [self showAlertTitle:@"提示" Message:@"用户已注册"];
            }
            else if (!self.registerNewUser && [array count] == 0) {
                [self showAlertTitle:@"提示" Message:@"用户不存在"];
            }
            else {
                if (isMobile) {
                    [BmobSMS requestSMSCodeInBackgroundWithPhoneNumber:self.registerId andTemplate:@"验证码" resultBlock:^(int number, NSError *error) {
                        if (error != nil) {
                            [self showAlertTitle:@"提示" Message:@"获取短信验证码失败，请稍后再试"];
                        }
                        else {
                            [self performSegueWithIdentifier:@"regToMobileVerify" sender:self];
                        }
                    }];
                }
                else {
                    if ([array count] != 0) {
                        [self.acFrame startAc];
                        [BmobUser requestPasswordResetInBackgroundWithEmail:self.registerId];
                        [self.acFrame stopAc];
                        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"一封邮件已经发往您注册邮箱，请前往查收" preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction * defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                            [self dismissViewControllerAnimated:YES completion:nil];
                        }];
                        [alert addAction:defaultAction];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                    else {
                        [self performSegueWithIdentifier:@"regToSetPassword" sender:self];
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

-(void) showAlertTitle:(NSString *)title Message:(NSString *)message {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
    }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
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
