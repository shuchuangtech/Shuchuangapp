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
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (strong, nonatomic) MyActivityIndicatorView *acFrame;
@property (weak, nonatomic) IBOutlet UIButton *btnResend;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) NSInteger countdown;
@property (weak, nonatomic) NSString *phoneNumber;
@property (nonatomic) BOOL registerNewUser;
@property (strong, nonatomic) UIImageView *bgView;


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
    [self.textField setBackgroundColor:[UIColor clearColor]];
    
    //activity frame
    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];
    
    //navigation bar and navigation item
    UIBarButtonItem * leftBarBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_white"] style:UIBarButtonItemStyleDone target:self action:@selector(leftBarBtnClicked)];
    [leftBarBtn setTintColor:[UIColor whiteColor]];
    UINavigationItem *naviItem = [[UINavigationItem alloc] init];
    naviItem.leftBarButtonItem = leftBarBtn;
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.naviBar.frame.size.width - 100, self.naviBar.frame.size.height)];
    [titleLab setText:@"输入验证码"];
    [titleLab setTextColor:[UIColor whiteColor]];
    [titleLab setFont:[UIFont systemFontOfSize:17.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    naviItem.titleView = titleLab;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    [self.naviBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsCompact];
    self.naviBar.clipsToBounds = YES;
    //button next
    [self.btnNext setBackgroundColor:[UIColor whiteColor]];
    [self.btnNext setAlpha:0.3];
    self.btnNext.layer.cornerRadius = 18.0;
    self.btnNext.layer.opaque = NO;
    self.btnNext.layer.masksToBounds = YES;
    self.btnNext.enabled = NO;
    
    //[self.btnResend setBackgroundColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:0.3]];
    [self.btnResend setBackgroundColor:[UIColor lightGrayColor]];
    [self.btnResend setAlpha:0.6];
    self.btnResend.layer.cornerRadius = 12.0;
    self.btnResend.layer.opaque = NO;
    self.btnResend.layer.masksToBounds = YES;
    self.btnResend.enabled = NO;
    
    self.countdown = 60;
    [self.btnResend setTitle:@"60 s" forState:UIControlStateDisabled];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerHandler) userInfo:nil repeats:YES];
    
    [self.view bringSubviewToFront:self.naviBar];
    self.bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.bgView setImage:[UIImage imageNamed:@"background"]];
    [self.view addSubview:self.bgView];
    [self.view sendSubviewToBack:self.bgView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
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
    [self.timer invalidate];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onButtonNext:(id)sender {
    if ([self.textField isFirstResponder]) {
        [self.textField resignFirstResponder];
    }
    [self.acFrame startAc];
    __weak MobileVerifyViewController *weakSelf = self;
    [BmobSMS verifySMSCodeInBackgroundWithPhoneNumber:weakSelf.phoneNumber andSMSCode:weakSelf.textField.text resultBlock:^(BOOL isSuccessful, NSError *error) {
        [weakSelf.acFrame stopAc];
        if (isSuccessful) {
            [weakSelf.timer invalidate];
            [weakSelf performSegueWithIdentifier:@"verifyToSetPassword" sender:weakSelf];
        }
        else {
            [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"验证码错误" action:nil];
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
        [self.btnResend setBackgroundColor:[UIColor colorWithRed:227.0 / 255.0 green:93.0 / 255.0 blue:93.0 / 255.0 alpha:1.0]];
        [self.btnResend setAlpha:1.0];
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
        [self.btnNext setAlpha:0.3];
    }
    else {
        self.btnNext.enabled = YES;
        [self.btnNext setAlpha:1.0];
    }
}


- (IBAction)onButtonResend:(id)sender {
    [self.acFrame startAc];
    __weak MobileVerifyViewController *weakSelf = self;
    [BmobSMS requestSMSCodeInBackgroundWithPhoneNumber:weakSelf.phoneNumber andTemplate:@"验证码" resultBlock:^(int number, NSError *error) {
        [weakSelf.acFrame stopAc];
        if (error != nil) {
            [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"获取短信验证码失败，请稍后再试" action:nil];
        }
        else {
            [weakSelf.btnResend setBackgroundColor:[UIColor grayColor]];
            [weakSelf.btnResend setAlpha:0.6];
            weakSelf.btnResend.enabled = NO;
            weakSelf.countdown = 60;
            [weakSelf.btnResend setTitle:@"60 s" forState:UIControlStateDisabled];
            weakSelf.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:weakSelf selector:@selector(timerHandler) userInfo:nil repeats:YES];
        }
    }];
}

@end
