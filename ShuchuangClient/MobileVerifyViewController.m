//
//  MobileVerifyViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/6/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "MobileVerifyViewController.h"
#import "UIButton+FillBackgroundImage.h"
#import "MyActivityIndicatorView.h"
#import "Bmob.h"
#import "SCUtil.h"

@interface MobileVerifyViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UINavigationItem *naviItem;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (strong, nonatomic) MyActivityIndicatorView *acFrame;
@property (weak, nonatomic) IBOutlet UIButton *btnResend;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) NSInteger countdown;


- (IBAction)textFieldChanged:(id)sender;
- (IBAction)onButtonResend:(id)sender;
- (IBAction)onButtonNext:(id)sender;
- (void) leftBarBtnClicked;
- (void) timerHandler;
@end

@implementation MobileVerifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.phoneNumberLabel.text = self.phoneNumber;
    self.textField.delegate = self;
    //activity frame
    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];
    
    //navigation bar and navigation item
    UIBarButtonItem * leftBarBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(leftBarBtnClicked)];
    [leftBarBtn setTintColor:[UIColor colorWithRed:1.0 green:129.0/255.0 blue:0.0 alpha:1.0]];
    self.naviItem.leftBarButtonItem = leftBarBtn;
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [titleLab setText:@"输入验证码"];
    [titleLab setTextColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
    [titleLab setFont:[UIFont systemFontOfSize:15.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    self.naviItem.titleView = titleLab;
    
    //button next
    [self.btnNext setBackgroundImage:[UIButton imageWithColor:[UIButton getColorFromHex:0xffba73 Alpha:1.0]] forState:UIControlStateNormal];
    [self.btnNext setBackgroundImage:[UIButton imageWithColor:[UIButton getColorFromHex:0xc0c0c0 Alpha:1.0]] forState:UIControlStateDisabled];
    [self.btnNext setBackgroundImage:[UIButton imageWithColor:[UIButton getColorFromHex:0xff8100 Alpha:1.0]] forState:UIControlStateHighlighted];
    self.btnNext.layer.cornerRadius = 5.0;
    self.btnNext.layer.opaque = NO;
    self.btnNext.layer.masksToBounds = YES;
    self.btnNext.enabled = NO;
    
    [self.btnResend setBackgroundImage:[UIButton imageWithColor:[UIButton getColorFromHex:0xffba73 Alpha:1.0]] forState:UIControlStateNormal];
    [self.btnResend setBackgroundImage:[UIButton imageWithColor:[UIButton getColorFromHex:0xc0c0c0 Alpha:1.0]] forState:UIControlStateDisabled];
    [self.btnResend setBackgroundImage:[UIButton imageWithColor:[UIButton getColorFromHex:0xff8100 Alpha:1.0]] forState:UIControlStateHighlighted];
    self.btnResend.layer.cornerRadius = 5.0;
    self.btnResend.layer.opaque = NO;
    self.btnResend.layer.masksToBounds = YES;
    self.btnResend.enabled = NO;
    
    self.countdown = 60;
    [self.btnResend setTitle:@"60 s" forState:UIControlStateDisabled];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerHandler) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    NSString *verifyCode = @"\\d{6}$";
    NSPredicate *verifyTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", verifyCode];
    if (![verifyTest evaluateWithObject:textField.text]) {
        [SCUtil viewController:self showAlertTitle:@"提示" message:@"请输入六位数字验证码" action:nil];
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [textField endEditing:YES];
    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"verifyToSetPassword"]) {
        id desVC = segue.destinationViewController;
        [desVC setValue:self.phoneNumber forKey:@"phoneNumber"];
        [desVC setValue:@(self.registerNewUser) forKey:@"registerNewUser"];
        [desVC setValue:self.textField.text forKey:@"SMSCode"];
    }
}

- (void) leftBarBtnClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onButtonNext:(id)sender {
    if ([self.textField isFirstResponder]) {
        [self.textField resignFirstResponder];
    }

    [self.acFrame startAc];
    [BmobSMS verifySMSCodeInBackgroundWithPhoneNumber:self.phoneNumber andSMSCode:self.textField.text resultBlock:^(BOOL isSuccessful, NSError *error) {
        [self.acFrame stopAc];
        if (isSuccessful) {
            [self performSegueWithIdentifier:@"verifyToSetPassword" sender:self];
        }
        else {
            [SCUtil viewController:self showAlertTitle:@"提示" message:@"验证码错误" action:nil];
        }
    }];
}

- (void) timerHandler {
    if (self.countdown != 0) {
        self.countdown--;
        NSString *btnTitle = [[NSString alloc] initWithFormat:@"%ld s", (long)self.countdown];
        [self.btnResend setTitle:btnTitle forState:UIControlStateDisabled];
    }
    else {
        self.btnResend.titleLabel.font = [UIFont systemFontOfSize:11.0];
        [self.btnResend setTitle:@"重新发送" forState:UIControlStateNormal];
        self.btnResend.enabled = YES;
        [self.timer invalidate];
    }
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (range.location > 5) {
        return NO;
    }
    else {
        return YES;
    }
}

- (IBAction)textFieldChanged:(id)sender {
    if (self.textField.text.length < 6) {
        self.btnNext.enabled = NO;
    }
    else {
        self.btnNext.enabled = YES;
    }
}


- (IBAction)onButtonResend:(id)sender {
    [self.acFrame startAc];
    [BmobSMS requestSMSCodeInBackgroundWithPhoneNumber:self.phoneNumber andTemplate:@"验证码" resultBlock:^(int number, NSError *error) {
        [self.acFrame stopAc];
        if (error != nil) {
            [SCUtil viewController:self showAlertTitle:@"提示" message:@"获取短信验证码失败，请稍后再试" action:nil];
        }
        else {
            self.btnResend.enabled = NO;
            self.countdown = 60;
            [self.btnResend setTitle:@"60 s" forState:UIControlStateDisabled];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerHandler) userInfo:nil repeats:YES];
        }
    }];
}

@end
