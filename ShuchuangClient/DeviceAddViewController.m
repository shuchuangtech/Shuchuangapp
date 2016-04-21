//
//  DeviceAddViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/12/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "DeviceAddViewController.h"
#import "UIButton+FillBackgroundImage.h"
#import "MyActivityIndicatorView.h"
#import "SCUtil.h"
#import "SCDeviceClient.h"
#import "SCDeviceManager.h"
#import "ScanQRCodeProtocol.h"

@interface DeviceAddViewController () <ScanQRCodeProtocol>
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UITextField *uuidTextField;
@property (weak, nonatomic) IBOutlet UIButton *buttonNext;
@property (weak, nonatomic) IBOutlet UIButton *buttonQR;
@property (strong, nonatomic) MyActivityIndicatorView *acFrame;
@property (strong, nonatomic) NSString *uuid;
@property (strong, nonatomic) NSString *devType;
@property (strong, nonatomic) UIImageView *barBg;
@property (strong, nonatomic) UIImageView *bgView;
@property (strong, nonatomic) UIImageView *textFieldBg;


- (IBAction)textFieldChanged:(id)sender;
- (IBAction)onButtonNext:(id)sender;
- (IBAction)onButtonQR:(id)sender;
@end

@implementation DeviceAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UINavigationItem *naviItem = [[UINavigationItem alloc] init];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    [leftBarButton setTintColor:[UIColor whiteColor]];
    [naviItem setLeftBarButtonItem:leftBarButton];
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.naviBar.frame.size.width - 100, self.naviBar.frame.size.height)];
    [titleLab setText:@"添加新设备"];
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
    
    //uuid subview
    self.uuidTextField.delegate = self;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [button addTarget:self action:@selector(onInfoButton) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, self.uuidTextField.frame.size.height, self.uuidTextField.frame.size.height)];
    self.uuidTextField.rightView = button;
    self.uuidTextField.rightViewMode = UITextFieldViewModeUnlessEditing;
    [self.uuidTextField setBackgroundColor:[UIColor clearColor]];
    
    //ac frame
    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];
    
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
    [self.uuidTextField addSubview:self.textFieldBg];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.barBg setFrame:CGRectMake(0, 0, self.view.frame.size.width, 64.0)];
    [self.bgView setFrame:CGRectMake(0, self.barBg.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.barBg.frame.size.height)];
    [self.textFieldBg setFrame:CGRectMake(0, 0, self.uuidTextField.frame.size.width, self.uuidTextField.frame.size.height)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onLeftButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onInfoButton {
    [SCUtil viewController:self showAlertTitle:@"提示" message:@"设备序列号位于设备外壳，设备包装盒以及设备说明书上，由SC+10位数字组成" action:nil];
}

- (IBAction)textFieldChanged:(id)sender {
    if ( [self.uuidTextField.text length] > 0) {
        self.buttonNext.enabled = YES;
    }
    else {
        self.buttonNext.enabled = NO;
    }
}

- (IBAction)onButtonNext:(id)sender {
    if ([self.uuidTextField isFirstResponder]) {
        [self.uuidTextField resignFirstResponder];
    }
    self.uuid = self.uuidTextField.text;
    NSString *regex = @"SC[0-9]{10,}";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![test evaluateWithObject:self.uuid]) {
        [SCUtil viewController:self showAlertTitle:@"提示" message:@"请输入正确的设备序列号" action:nil];
    }
    else {
        SCDeviceManager *devManager = [SCDeviceManager instance];
        __weak DeviceAddViewController *weakSelf = self;
        if (![devManager addDevice:self.uuid]) {
            [SCUtil viewController:self showAlertTitle:@"提示" message:@"设备已经存在" action:^(UIAlertAction *action) {
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }];
        }
        else {
            [self.acFrame startAc];
            SCDeviceClient *client = [devManager getDevice:self.uuid];
            [client serverCheckSuccess:^(NSURLSessionDataTask *task, id response) {
                [weakSelf.acFrame stopAc];
                if ([response[@"result"]  isEqual: @"good"]) {
                    if ([response[@"state"] isEqualToString:@"online"]) {
                        [weakSelf performSegueWithIdentifier:@"DeviceAddToPassword" sender:weakSelf];
                    }
                    else {
                        [devManager removeDevice:weakSelf.uuid];
                        [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"设备不在线，请确认设备已经接入网络" action:nil];
                    }
                }
                else {
                    [devManager removeDevice:weakSelf.uuid];
                    [SCUtil viewController:self showAlertTitle:@"提示" message:response[@"detail"] action:nil];
                }
            }
            failure:^(NSURLSessionDataTask *task, NSError *error) {
                [weakSelf.acFrame stopAc];
                [devManager removeDevice:weakSelf.uuid];
                [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"网络错误，请稍后再试" action:nil];
            }];
        }
    }
}

- (IBAction)onButtonQR:(id)sender {
    [self performSegueWithIdentifier:@"DeviceAddToQRCode" sender:self];
}

- (void)getQRCodeStringValue:(NSString *)stringValue {
    self.uuidTextField.text = stringValue;
    self.buttonNext.enabled = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    id desVC = segue.destinationViewController;
    if ([segue.identifier  isEqual: @"DeviceAddToPassword"]) {
        [desVC setValue:self.uuid forKey:@"devId"];
        
    }
    else {
        [desVC setValue:self forKey:@"scanDelegate"];
    }
}


@end
