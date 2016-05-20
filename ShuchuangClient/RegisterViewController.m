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
#import "SCTextField.h"
@interface RegisterViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet SCTextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) MyActivityIndicatorView *acFrame;
@property (strong, nonatomic) NSString *registerId;
@property (strong, nonatomic) UIImageView *bgView;


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
    UIBarButtonItem * leftBarBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_white"] style:UIBarButtonItemStyleDone target:self action:@selector(leftBarBtnClicked)];
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
    [self.naviBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsCompact];
    self.naviBar.clipsToBounds = YES;
    
    //next button
    [self.nextButton setBackgroundColor:[UIColor whiteColor]];
    [self.nextButton setAlpha:0.3];
    self.nextButton.layer.cornerRadius = 18.0;
    self.nextButton.layer.opaque = NO;
    self.nextButton.layer.masksToBounds = YES;
    self.nextButton.enabled = NO;
        
    //textField
    self.textField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tel"]];
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    self.textField.delegate = self;
    
    [self.textField setBackgroundColor:[UIColor clearColor]];
    
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

- (IBAction)onNextBtn:(id)sender {
    if ([self.textField isFirstResponder]) {
        [self.textField resignFirstResponder];
    }
    BOOL isMobile = [SCUtil validateMobile:self.registerId];
    if (!isMobile) {
        [SCUtil viewController:self showAlertTitle:@"提示" message:@"请输入正确的手机号码" action:nil];
        self.textField.text = @"";
    }
    else {
        BmobQuery *query = [BmobUser query];
        [query whereKey:@"mobilePhoneNumber" equalTo:self.registerId];
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
                [BmobSMS requestSMSCodeInBackgroundWithPhoneNumber:weakSelf.registerId andTemplate:@"验证码" resultBlock:^(int number, NSError *error) {
                    if (error != nil) {
                        [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"获取短信验证码失败，请稍后再试" action:nil];
                    }
                    else {
                        [weakSelf performSegueWithIdentifier:@"regToMobileVerify" sender:weakSelf];
                    }
                }];
            }
        }];
    }
}

- (IBAction)textFieldChanged:(id)sender {
    UITextField *textField = (UITextField *)sender;
    if ([textField.text length] == 0) {
        [self.nextButton setAlpha:0.3];
        self.nextButton.enabled = NO;
    }
    else {
        [self.nextButton setAlpha:1.0];
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
}


@end
