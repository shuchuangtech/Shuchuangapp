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
@property (strong, nonatomic) NSString *devId;
@property (nonatomic) BOOL firstAdd;
@property (weak, nonatomic) IBOutlet UILabel *authLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *authSeg;
@property NSInteger userAuth;

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
    //navi bar
    UINavigationItem *naviItem = [[UINavigationItem alloc] initWithTitle:@"验证设备密码"];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cancel"] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    [naviItem setLeftBarButtonItem:leftBarButton];
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    [self.naviBar setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
    //button
    [self.buttonNext setBackgroundImage:[UIButton imageWithColor:[UIButton getColorFromHex:0xffba73 Alpha:1.0]] forState:UIControlStateNormal];
    [self.buttonNext setBackgroundImage:[UIButton imageWithColor:[UIButton getColorFromHex:0xc0c0c0 Alpha:1.0]] forState:UIControlStateDisabled];
    [self.buttonNext setBackgroundImage:[UIButton imageWithColor:[UIButton getColorFromHex:0xff8100 Alpha:1.0]] forState:UIControlStateHighlighted];
    self.buttonNext.layer.cornerRadius = 5.0;
    self.buttonNext.layer.opaque = NO;
    self.buttonNext.layer.masksToBounds = YES;
    self.buttonNext.enabled = NO;
    
    [self.authSeg addTarget:self action:@selector(onSegValueChanged) forControlEvents:UIControlEventValueChanged];
    self.userAuth = 9;
    if (self.firstAdd) {
        [self.buttonNext setTitle:@"添加完成" forState:UIControlStateNormal];
        self.authLabel.hidden = NO;
        self.authSeg.hidden = NO;
    }
    else {
        self.authLabel.hidden = YES;
        self.authSeg.hidden = YES;
        [self.buttonNext setTitle:@"重新验证" forState:UIControlStateNormal];
    }
}

- (void)viewDidAppear:(BOOL)animated {
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
    if (!self.firstAdd) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [SCUtil viewController:self showAlertTitle:@"提示" message:@"确认放弃添加新设备吗？" yesAction:^(UIAlertAction *action) {
                [[SCDeviceManager instance] removeDevice:self.devId];
                [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        } noAction:nil];
    }
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
    [client login:loginUser password:self.passTextField.text
    success:^(NSURLSessionDataTask *task, id response) {
        [self.acFrame stopAc];
        if ([response[@"result"] isEqualToString:@"good"]) {
            if (self.firstAdd) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"设备绑定成功" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    if ([alert.textFields[0] isFirstResponder]) {
                        [alert.textFields[0] resignFirstResponder];
                    }
                    NSString *devName = @"默认设备";
                    [client updateDeviceName:devName];
                    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
                    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                }];
                [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                    textField.placeholder = @"给设备起个名字吧";
                }];
                [alert addAction:cancelAction];
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
            else {
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            }
        }
        else {
            [SCUtil viewController:self showAlertTitle:@"提示" message:response[@"detail"] action:nil];
        }
    }failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self.acFrame stopAc];
        [SCUtil viewController:self showAlertTitle:@"提示" message:@"网络错误" action:nil];
    }];
}
@end
