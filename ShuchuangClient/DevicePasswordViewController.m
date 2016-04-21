//
//  DevicePasswordViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/13/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "DevicePasswordViewController.h"
#import "SCUtil.h"
#import "MyActivityIndicatorView.h"
#import "UIButton+FillBackgroundImage.h"
#import "SCDeviceManager.h"
#import "Bmob.h"
@interface DevicePasswordViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UITextField *passTextField;
@property (weak, nonatomic) IBOutlet UIButton *buttonNext;
@property (strong, nonatomic) MyActivityIndicatorView *acFrame;
@property (weak, nonatomic) NSString *devId;
@property (weak, nonatomic) IBOutlet UILabel *authLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *authSeg;
@property (nonatomic) NSInteger userAuth;
@property (strong, nonatomic) UIImageView *barBg;
@property (strong, nonatomic) UIImageView *bgView;
@property (strong, nonatomic) UIImageView *textFieldBg;

- (IBAction)textFieldChanged:(id)sender;
- (IBAction)onButtonNext:(id)sender;
- (void)onInfoButton;
- (void)onLeftButton;
- (void)onSegValueChanged;
@end

@implementation DevicePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //ac frame
    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];
    
    //text field
    self.passTextField.delegate = self;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [button addTarget:self action:@selector(onInfoButton) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, self.passTextField.frame.size.height, self.passTextField.frame.size.height)];
    self.passTextField.rightView = button;
    self.passTextField.rightViewMode = UITextFieldViewModeUnlessEditing;
    [self.passTextField setBackgroundColor:[UIColor clearColor]];
    
    //navi bar
    UINavigationItem *naviItem = [[UINavigationItem alloc] init];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cancel"] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    [leftBarButton setTintColor:[UIColor whiteColor]];
    [naviItem setLeftBarButtonItem:leftBarButton];
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.naviBar.frame.size.width - 100, self.naviBar.frame.size.height)];
    [titleLab setText:@"验证设备密码"];
    [titleLab setTextColor:[UIColor whiteColor]];
    [titleLab setFont:[UIFont systemFontOfSize:17.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    naviItem.titleView = titleLab;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    [self.naviBar setBackgroundImage:[UIImage imageNamed:@"barBg"] forBarMetrics:UIBarMetricsCompact];
    //button
    [self.buttonNext setBackgroundImage:[UIImage imageNamed:@"longButtonActive"] forState:UIControlStateNormal];
    [self.buttonNext setBackgroundImage:[UIImage imageNamed:@"longButton"] forState:UIControlStateDisabled];
    self.buttonNext.layer.cornerRadius = 5.0;
    self.buttonNext.layer.opaque = NO;
    self.buttonNext.layer.masksToBounds = YES;
    self.buttonNext.enabled = NO;
    
    [self.authSeg addTarget:self action:@selector(onSegValueChanged) forControlEvents:UIControlEventValueChanged];
    self.userAuth = 9;
    [self.buttonNext setTitle:@"添加完成" forState:UIControlStateNormal];
    
    self.barBg = [[UIImageView alloc] init];
    [self.barBg setImage:[UIImage imageNamed:@"barBg"]];
    [self.view addSubview:self.barBg];
    [self.view bringSubviewToFront:self.naviBar];
    self.bgView = [[UIImageView alloc] init];
    [self.bgView setImage:[UIImage imageNamed:@"background"]];
    [self.view addSubview:self.bgView];
    [self.view sendSubviewToBack:self.bgView];
    
    self.textFieldBg = [[UIImageView alloc] init];
    [self.textFieldBg setImage:[UIImage imageNamed:@"textFieldBg"]];
    [self.passTextField addSubview:self.textFieldBg];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.barBg setFrame:CGRectMake(0, 0, self.view.frame.size.width, 64.0)];
    [self.bgView setFrame:CGRectMake(0, self.barBg.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.barBg.frame.size.height)];
    [self.textFieldBg setFrame:CGRectMake(0, 0, self.passTextField.frame.size.width, self.passTextField.frame.size.height)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onSegValueChanged {
    if ([self.authSeg selectedSegmentIndex] == 0) {
        self.userAuth = 9;
    }
    else {
        self.userAuth = 8;
    }
}

- (void)onInfoButton {
    [SCUtil viewController:self showAlertTitle:@"提示" message:@"设备初始密码位于设备外壳，设备说明书上" action:nil];
}

- (void)onLeftButton {
    __weak DevicePasswordViewController *weakSelf = self;
    [SCUtil viewController:self showAlertTitle:@"提示" message:@"确认放弃添加新设备吗？" yesAction:^(UIAlertAction *action) {
            [[SCDeviceManager instance] removeDevice:weakSelf.devId];
            [weakSelf.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } noAction:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)textFieldChanged:(id)sender {
    if ([self.passTextField.text length] > 0) {
        self.buttonNext.enabled = YES;
    }
    else {
        self.buttonNext.enabled = NO;
    }
}

- (IBAction)onButtonNext:(id)sender {
    if ([self.passTextField isFirstResponder]) {
        [self.passTextField resignFirstResponder];
    }
    SCDeviceClient *client = [[SCDeviceManager instance] getDevice:self.devId];
    [self.acFrame startAc];
    NSString *loginUser;
    if (self.userAuth == 9) {
        loginUser = @"admin";
    }
    else {
        BmobUser *user = [BmobUser getCurrentUser];
        loginUser = [user username];
    }
    __weak DevicePasswordViewController *weakSelf = self;
    [client login:loginUser password:self.passTextField.text
    success:^(NSURLSessionDataTask *task, id response) {
        [weakSelf.acFrame stopAc];
        if ([response[@"result"] isEqualToString:@"good"]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"设备绑定成功" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                if ([alert.textFields[0] isFirstResponder]) {
                    [alert.textFields[0] resignFirstResponder];
                }
                NSString *devName = @"默认设备";
                [client updateDeviceName:devName];
                [weakSelf.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            }];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                if ([alert.textFields[0] isFirstResponder]) {
                    [alert.textFields[0] resignFirstResponder];
                }
                NSString *devName;
                if ([alert.textFields[0].text length] == 0) {
                    devName = @"默认设备";
                }
                else {
                    devName = alert.textFields[0].text;
                }
                [client updateDeviceName:devName];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AddCompletionNoti" object:nil];
                [weakSelf.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            }];
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = @"给设备起个名字吧";
            }];
            [alert addAction:cancelAction];
            [alert addAction:defaultAction];
            [weakSelf presentViewController:alert animated:YES completion:nil];
        }
        else {
            [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:response[@"detail"] action:nil];
        }
    }failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakSelf.acFrame stopAc];
        [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"网络错误" action:nil];
    }];
}
@end
