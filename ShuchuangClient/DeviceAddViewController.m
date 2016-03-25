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

@interface DeviceAddViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UITextField *uuidTextField;
@property (weak, nonatomic) IBOutlet UIButton *buttonNext;
@property (weak, nonatomic) IBOutlet UIButton *buttonQR;
@property (strong, nonatomic) MyActivityIndicatorView *acFrame;
@property (strong, nonatomic) NSString *uuid;
@property (strong, nonatomic) NSString *devType;

- (IBAction)textFieldChanged:(id)sender;
- (IBAction)onButtonNext:(id)sender;
- (IBAction)onButtonQR:(id)sender;
@end

@implementation DeviceAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UINavigationItem *naviItem = [[UINavigationItem alloc] initWithTitle:@"添加新设备"];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
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
    
    //uuid subview
    self.uuidTextField.delegate = self;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [button addTarget:self action:@selector(onInfoButton) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, self.uuidTextField.frame.size.height, self.uuidTextField.frame.size.height)];
    self.uuidTextField.rightView = button;
    self.uuidTextField.rightViewMode = UITextFieldViewModeUnlessEditing;
    
    //ac frame
    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];

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
        if (![devManager addDevice:self.uuid]) {
            [SCUtil viewController:self showAlertTitle:@"提示" message:@"设备已经存在" action:^(UIAlertAction *action) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        }
        else {
            [self.acFrame startAc];
            SCDeviceClient *client = [devManager getDevice:self.uuid];
            [client serverCheckSuccess:^(NSURLSessionDataTask *task, id response) {
                [self.acFrame stopAc];
                if ([response[@"result"]  isEqual: @"good"]) {
                    if ([response[@"state"] isEqualToString:@"online"]) {
                        [self performSegueWithIdentifier:@"DeviceAddToPassword" sender:self];
                    }
                    else {
                        [devManager removeDevice:self.uuid];
                        [SCUtil viewController:self showAlertTitle:@"提示" message:@"设备不在线，请确认设备已经接入网络" action:nil];
                    }
                }
                else {
                    [devManager removeDevice:self.uuid];
                    [SCUtil viewController:self showAlertTitle:@"提示" message:response[@"detail"] action:nil];
                }
            }
            failure:^(NSURLSessionDataTask *task, NSError *error) {
                [self.acFrame stopAc];
                [devManager removeDevice:self.uuid];
                [SCUtil viewController:self showAlertTitle:@"提示" message:@"网络错误，请稍后再试" action:nil];
            }];
        }
    }
}

- (IBAction)onButtonQR:(id)sender {
    /*
    SCHTTPManager *http = [SCHTTPManager instance];
    NSDictionary *dict = @{@"type":@"request", @"action":@"server.check", @"param":@{@"uuid":self.uuidTextField.text}};
    NSLog(@"%@", dict);
    [http sendMessage:dict success:^(NSURLSessionDataTask *task, id response) {
        NSLog(@"%@", response);
    } failure:^(NSURLSessionDataTask* task, NSError *error) {
        NSLog(@"%@", error);
    }];
     */

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
    if ([segue.identifier  isEqual: @"DeviceAddToPassword"]) {
        id desVC = segue.destinationViewController;
        [desVC setValue:self.uuid forKey:@"devId"];
        [desVC setValue:@YES forKey:@"firstAdd"];
    }
}


@end
