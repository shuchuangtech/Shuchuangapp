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
#import "AddTableViewCell1.h"
#import "AddTableViewCell2.h"
#import "AddTableViewCell3.h"
#import "BmobUser.h"
#import "AuthorityChangeProtocol.h"

@interface DeviceAddViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, AuthorityChangeProtocol>
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (strong, nonatomic) MyActivityIndicatorView *acFrame;
@property (strong, nonatomic) NSString *uuid;
@property (strong, nonatomic) NSString *devType;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *loginUser;
@property (nonatomic) NSInteger userAuth;
@property (copy, nonatomic) NSString *password;
@property (weak, nonatomic) AddTableViewCell1 *cell1;

@end

@implementation DeviceAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UINavigationItem *naviItem = [[UINavigationItem alloc] init];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"  取消" style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"完成  " style:UIBarButtonItemStylePlain target:self action:@selector(onRightButton)];
    [leftBarButton setTintColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]];
    [rightBarButton setTintColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]];
    [naviItem setLeftBarButtonItem:leftBarButton];
    [naviItem setRightBarButtonItem:rightBarButton];
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.naviBar.frame.size.width - 100, self.naviBar.frame.size.height)];
    [titleLab setText:@"添加新设备"];
    [titleLab setTextColor:[UIColor colorWithRed:21.0 / 255.0 green:37.0 / 255.0 blue:50.0 / 255.0 alpha:1.0]];
    [titleLab setFont:[UIFont systemFontOfSize:17.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    naviItem.titleView = titleLab;
    [self.naviBar pushNavigationItem:naviItem animated:NO];

    //table view
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.tableView registerNib:[UINib nibWithNibName:@"AddTableViewCell1" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"AddTableViewCell1"];
    [self.tableView registerNib:[UINib nibWithNibName:@"AddTableViewCell2" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"AddTableViewCell2"];
    [self.tableView registerNib:[UINib nibWithNibName:@"AddTableViewCell3" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"AddTableViewCell3"];

    self.userAuth = 9;
    self.loginUser = @"admin";
    
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
    [SCUtil viewController:self showAlertTitle:@"提示" message:@"设备序列号位于设备外壳，设备包装盒以及设备说明书上，由SC+10位数字组成。设备初始密码位于设备外壳，设备说明书上" action:nil];
}

- (void)onRightButton {
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
                        
                        [client login:weakSelf.loginUser password:weakSelf.password
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
                                          [[NSNotificationCenter defaultCenter] postNotificationName:@"AddCompletionNoti" object:nil];
                                          [weakSelf dismissViewControllerAnimated:YES completion:nil];
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
                                          [weakSelf dismissViewControllerAnimated:YES completion:nil];
                                      }];
                                      [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                                          textField.placeholder = @"给设备起个名字吧";
                                      }];
                                      [alert addAction:cancelAction];
                                      [alert addAction:defaultAction];
                                      [weakSelf presentViewController:alert animated:YES completion:nil];
                                  }
                                  else {
                                      [devManager removeDevice:weakSelf.uuid];
                                      [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:response[@"detail"] action:nil];
                                  }
                              }failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  [weakSelf.acFrame stopAc];
                                  [devManager removeDevice:weakSelf.uuid];
                                  [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"网络错误，请稍后再试" action:nil];
                              }];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 44.0;
    }
    else if (indexPath.row == 1) {
        return 44.0;
    }
    else if (indexPath.row == 2) {
        return 75.0;
    }
    else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        AddTableViewCell1 *cell = [tableView dequeueReusableCellWithIdentifier:@"AddTableViewCell1" forIndexPath:indexPath];
        cell.uuidTextField.delegate = self;
        [cell.scanButton addTarget:self action:@selector(onButtonQR) forControlEvents:UIControlEventTouchUpInside];
        self.cell1 = cell;
        return cell;
    }
    else if (indexPath.row == 1) {
        AddTableViewCell2 *cell = [tableView dequeueReusableCellWithIdentifier:@"AddTableViewCell2" forIndexPath:indexPath];
        cell.authDelegate = self;
        return cell;
    }
    else if (indexPath.row == 2) {
        AddTableViewCell3 *cell = [tableView dequeueReusableCellWithIdentifier:@"AddTableViewCell3" forIndexPath:indexPath];
        cell.passwordTextField.delegate = self;
        [cell.infoButton addTarget:self action:@selector(onInfoButton) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    else {
        return nil;
    }
}

- (void)authChangedTo:(NSInteger)auth {
    self.userAuth = 9 - auth;
    if (self.userAuth == 9) {
        self.loginUser = @"admin";
    }
    else {
        BmobUser *user = [BmobUser getCurrentUser];
        self.loginUser = [user username];
    }
}

- (void)onButtonQR {
    [self performSegueWithIdentifier:@"DeviceAddToQRCode" sender:self];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *regex = @"SC[0-9]{10,}";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([test evaluateWithObject:textField.text]) {
        self.uuid = textField.text;
    }
    else {
        self.password = textField.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id desVC = segue.destinationViewController;
    [desVC setValue:self.cell1 forKey:@"scanDelegate"];
}
@end
