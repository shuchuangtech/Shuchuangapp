//
//  DeviceOpViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 5/9/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "DeviceOpViewController.h"
#import "SCDeviceClient.h"
#import "SCDeviceManager.h"
#import "SCUtil.h"
#import "MyActivityIndicatorView.h"
#import "UpdateTableViewCell.h"
@interface DeviceOpViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIImageView *modeView;

@property (strong ,nonatomic) SCDeviceClient *client;
@property (strong, nonatomic) MyActivityIndicatorView *acFrame;
@property (copy, nonatomic) NSString *uuid;
@property (strong, nonatomic) NSDictionary *deviceVersion;
@property (strong, nonatomic) NSDictionary *serverVersion;
@property (strong, nonatomic) NSString *featureString;
@property (nonatomic) CGSize featureSize;
@property (nonatomic) BOOL showUpdate;
@property (nonatomic) BOOL hasUpdate;
@property (nonatomic) BOOL showUpdateNew;
@property (nonatomic) BOOL serverCheckFinish;
@property (nonatomic) BOOL deviceCheckFinish;
- (void)onLeftButton;
- (void)getDeviceMode;
- (void)changeDeviceMode;
- (void)reVerifyPassword;
- (void)changeDeviceName;
- (void)showDeviceInfo;
- (void)resetDeviceConfig;
- (void)checkDeviceUpdate;
@end

@implementation DeviceOpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UINavigationItem *naviItem = [[UINavigationItem alloc] init];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    [leftBarButton setTintColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]];
    [naviItem setLeftBarButtonItem:leftBarButton];
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.naviBar.frame.size.width - 100, self.naviBar.frame.size.height)];
    [titleLab setText:@"设备控制"];
    [titleLab setTextColor:[UIColor colorWithRed:21.0 / 255.0 green:37.0 / 255.0 blue:50.0 / 255.0 alpha:1.0]];
    [titleLab setFont:[UIFont systemFontOfSize:17.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    naviItem.titleView = titleLab;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    //table view
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView registerNib:[UINib nibWithNibName:@"UpdateTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"UpdateTableViewCell"];
    //
    self.client = [[SCDeviceManager instance] getDevice:self.uuid];
    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];
    self.modeView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"switch_on"]];
    
    self.deviceCheckFinish = NO;
    self.serverCheckFinish = NO;
    self.showUpdate = NO;
    self.showUpdateNew = NO;
    self.hasUpdate = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (animated) {
        [self getDeviceMode];
    }
}

- (void)onLeftButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)getDeviceMode {
    [self.acFrame startAc];
    __weak DeviceOpViewController *weakSelf = self;
    [self.client getDeviceModeSuccess:^(NSURLSessionDataTask *task, id response) {
        [weakSelf.tableView reloadData];
        [weakSelf.acFrame stopAc];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakSelf.tableView reloadData];
        [weakSelf.acFrame stopAc];
    }];
}

#pragma - mark table view delegate and datasource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.1;
    }
    else {
        return 10.0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2 && indexPath.row == 4) {
        if (self.showUpdateNew && self.hasUpdate)
        {
            return self.featureSize.height + 48.0;
        }
        else
            return 44.0;
    }
    else {
        return 44.0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    else if (section == 1) {
        return 3;
    }
    else {
        if (!self.showUpdate)
            return 3;
        else
            return 5;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 2 && indexPath.row == 4) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"UpdateTableViewCell" forIndexPath:indexPath];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceOpCell" forIndexPath:indexPath];
    }
    cell.detailTextLabel.text = @"";
    if (indexPath.section == 0) {
        cell.textLabel.text = @"设备模式";
        [cell.imageView setImage:[UIImage imageNamed:@"icon1-1"]];
        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:12.0]];
        if (self.client.mode < 0) {
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.detailTextLabel.text = @"模式未知 ";
        }
        else if (self.client.mode == 0) {
            [self.modeView setImage:[UIImage imageNamed:@"switch_off"]];
            cell.detailTextLabel.text = @"普通模式 ";
        }
        else {
            [self.modeView setImage:[UIImage imageNamed:@"switch_on"]];
            cell.detailTextLabel.text = @"管理员模式 ";
        }
        if (cell.accessoryView == nil) {
            cell.accessoryView = self.modeView;
        }
    }
    else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: {
                cell.textLabel.text = @"重新验证";
                [cell.imageView setImage:[UIImage imageNamed:@"icon2-1"]];
                break;
            }
            case 1: {
                cell.textLabel.text = @"修改名称";
                [cell.imageView setImage:[UIImage imageNamed:@"icon2-2"]];
                break;
            }
            case 2: {
                cell.textLabel.text = @"修改密码";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [cell.imageView setImage:[UIImage imageNamed:@"icon2-3"]];
                break;
            }
        }
    }
    else {
        switch (indexPath.row) {
            case 0: {
                cell.textLabel.text = @"设备信息";
                [cell.imageView setImage:[UIImage imageNamed:@"icon3-1"]];
                break;
            }
            case 1: {
                cell.textLabel.text = @"恢复设置";
                [cell.imageView setImage:[UIImage imageNamed:@"icon3-3"]];
                break;
            }
            case 2: {
                cell.textLabel.text = @"检查更新";
                [cell.imageView setImage:[UIImage imageNamed:@"icon3-4"]];
                break;
            }
            case 3: {
                cell.textLabel.text = @"当前版本";
                [cell.textLabel setFont:[UIFont systemFontOfSize:14.0]];
                [cell.detailTextLabel setFont:[UIFont systemFontOfSize:14.0]];
                [cell setBackgroundColor:[UIColor colorWithRed:251.0 / 255.0 green:251.0 / 255.0 blue:251.0 / 255.0 alpha:1.0]];
                NSString* buildTime = self.deviceVersion[@"buildtime"];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@(%@)", self.deviceVersion[@"version"], [buildTime substringToIndex:[buildTime length] - 6]];
                break;
            }
            case 4: {
                UpdateTableViewCell* thisCell = (UpdateTableViewCell *)cell;
                thisCell.myTextLabel.text = @"最新版本";
                [thisCell setBackgroundColor:[UIColor colorWithRed:251.0 / 255.0 green:251.0 / 255.0 blue:251.0 / 255.0 alpha:1.0]];
                thisCell.clipsToBounds = YES;
                if ([self.deviceVersion[@"version"] isEqualToString:self.serverVersion[@"version"]]) {
                    [thisCell.myImageView setImage:nil];
                    self.hasUpdate = NO;
                }
                else {
                    [thisCell.myImageView setImage:[UIImage imageNamed:@"reddot"]];
                    self.hasUpdate = YES;
                }
                NSString* buildTime = self.serverVersion[@"buildtime"];
                thisCell.myDetailTextLabel.text = [NSString stringWithFormat:@"%@(%@)", self.serverVersion[@"version"], [buildTime substringToIndex:[buildTime length] - 6]];
                thisCell.featureLabel.text = self.featureString;
                thisCell.featureLabel.numberOfLines = 0;
                thisCell.featureLabel.lineBreakMode = NSLineBreakByCharWrapping;
                if (!self.showUpdateNew || !self.hasUpdate) {
                    thisCell.featureLabel.hidden = YES;
                    thisCell.buttonUpdate.hidden = YES;
                }
                else {
                    thisCell.featureLabel.hidden = NO;
                    thisCell.buttonUpdate.hidden = NO;
                }
                [thisCell.buttonUpdate addTarget:self action:@selector(onButtonUpdate) forControlEvents:UIControlEventTouchUpInside];

                break;
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        [self changeDeviceMode];
    }
    else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                [self reVerifyPassword];
                break;
            case 1:
                [self changeDeviceName];
                break;
            case 2:
                [self performSegueWithIdentifier:@"DeviceChangePass" sender:self];
                break;
            default:
                break;
        }
    }
    else {
        switch (indexPath.row) {
            case 0:
                [self showDeviceInfo];
                break;
            case 1:
                [self resetDeviceConfig];
                break;
            case 2:
                if (!self.showUpdate) {
                    self.showUpdate = YES;
                    [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:2], [NSIndexPath indexPathForRow:4 inSection:2]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self checkDeviceUpdate];
                }
                break;
            case 3:
                break;
            case 4:
                if (self.hasUpdate) {
                    if (!self.showUpdateNew) {
                        self.showUpdateNew = YES;
                        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                }
                break;
            default:
                break;
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    id desVC = segue.destinationViewController;
    [desVC setValue:self.uuid forKey:@"uuid"];
}


- (void)changeDeviceMode {
    if (self.client.mode < 0) {
        [self getDeviceMode];
    }
    else {
        NSInteger mode;
        if (self.client.mode == 0) {
            mode = 1;
        }
        else {
            mode = 0;
        }
        [self.acFrame startAc];
        __weak DeviceOpViewController *weakSelf = self;
        [self.client changeDeviceMode:mode success:^(NSURLSessionDataTask *task, id response) {
            [weakSelf.acFrame stopAc];
            if ([response[@"result"] isEqualToString:@"good"]) {
                [weakSelf.tableView reloadData];
            }
            else {
                [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:response[@"detail"] action:nil];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [weakSelf.acFrame stopAc];
            [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"网络错误，请稍后再试" action:nil];
        }];
    }
}

- (void)reVerifyPassword {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"重新验证设备密码" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        if ([alert.textFields[0] isFirstResponder]) {
            [alert.textFields[0] resignFirstResponder];
        }
    }];
    __weak DeviceOpViewController *weakSelf = self;
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([alert.textFields[0] isFirstResponder]) {
            [alert.textFields[0] resignFirstResponder];
        }
        if ([alert.textFields[0].text length] != 0) {
            NSString *password = alert.textFields[0].text;
            [weakSelf.acFrame startAc];
            [weakSelf.client login:weakSelf.client.user password:password success:^(NSURLSessionDataTask *task, id response) {
                [weakSelf.acFrame stopAc];
                if ([response[@"result"] isEqualToString:@"good"]) {
                    [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"密码重新验证成功" action:nil];
                }
                else {
                    [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:response[@"detail"] action:nil];
                }
            }failure:^(NSURLSessionDataTask *task, NSError *error) {
                [weakSelf.acFrame stopAc];
                [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"网络错误，验证密码失败" action:nil];
            }];
        }
        
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"请输入设备密码";
        textField.secureTextEntry = YES;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.spellCheckingType = UITextSpellCheckingTypeNo;
    }];
    [alert addAction:cancelAction];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)changeDeviceName {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"修改设备名称" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        if ([alert.textFields[0] isFirstResponder]) {
            [alert.textFields[0] resignFirstResponder];
        }
    }];
    __weak DeviceOpViewController *weakSelf = self;
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([alert.textFields[0] isFirstResponder]) {
            [alert.textFields[0] resignFirstResponder];
        }
        if ([alert.textFields[0].text length] != 0) {
            NSString *name = alert.textFields[0].text;
            [weakSelf.client updateDeviceName:name];
        }
        
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"给设备起个名字吧";
    }];
    [alert addAction:cancelAction];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showDeviceInfo {
    NSString *message = [[NSString alloc] initWithFormat:@"设备名称: %@\n设备序列号: %@\n设备类型: %@", self.client.name, self.client.uuid, self.client.type];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"设备信息" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)resetDeviceConfig {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"恢复设备出厂设置会还原设备的管理密码，删除设备上的所有自定义用户、定时任务。\n是否要继续？" preferredStyle:UIAlertControllerStyleAlert];
    __weak DeviceOpViewController *weakSelf = self;
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action) {
        [weakSelf.acFrame startAc];
        [weakSelf.client resetDeviceSuccess:^(NSURLSessionDataTask* task, id response) {
            [weakSelf.acFrame stopAc];
            if ([response[@"result"] isEqualToString:@"good"]) {
                [weakSelf.client clearLocalTasks];
                [weakSelf reVerifyPassword];
            }
            else {
                [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:response[@"detail"] action:nil];
            }
        } failure:^(NSURLSessionDataTask* task, NSError* error) {
            [weakSelf.acFrame stopAc];
            [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"网络错误，请稍后再试" action:nil];
        }];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)checkDeviceUpdate {
    if (!self.deviceCheckFinish && !self.serverCheckFinish) {
        [self.acFrame startAc];
        [self checkDeviceVersion];
        [self checkServerVersion];
    }
}

- (void)checkDeviceVersion {
    __weak DeviceOpViewController *weakSelf = self;
    [self.client checkDeviceVersionSuccess:^(NSURLSessionDataTask* task, id response) {
        weakSelf.deviceCheckFinish = YES;
        if (weakSelf.deviceCheckFinish && weakSelf.serverCheckFinish) {
            if ([weakSelf.acFrame isAnimating]) {
                [weakSelf.acFrame stopAc];
                [weakSelf.tableView reloadData];
            }
        }
        if ([response[@"result"] isEqualToString:@"good"]) {
            weakSelf.deviceVersion = [[NSDictionary alloc] initWithDictionary:response[@"param"]];
        }
        else {
            weakSelf.deviceVersion = @{@"buildtime" : @"unkown", @"version" : @"unkown"};
        }
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        weakSelf.deviceCheckFinish = YES;
        if (weakSelf.deviceCheckFinish && weakSelf.serverCheckFinish) {
            if ([weakSelf.acFrame isAnimating]) {
                [weakSelf.acFrame stopAc];
                [weakSelf.tableView reloadData];
            }
        }
        weakSelf.deviceVersion = @{@"buildtime" : @"unkown", @"version" : @"unkown"};
    }];
}

- (void)checkServerVersion {
    __weak DeviceOpViewController *weakSelf = self;
    [self.client checkServerVersionSuccess:^(NSURLSessionDataTask* task, id response) {
        weakSelf.serverCheckFinish = YES;
        if (weakSelf.deviceCheckFinish && weakSelf.serverCheckFinish) {
            if ([weakSelf.acFrame isAnimating]) {
                [weakSelf.acFrame stopAc];
                [weakSelf.tableView reloadData];
            }
        }
        if ([response[@"result"] isEqualToString:@"good"]) {
            weakSelf.featureString = [[NSString alloc] init];
            weakSelf.serverVersion = [[NSDictionary alloc] initWithDictionary:response[@"param"][@"update"]];
            NSArray* featureArray = weakSelf.serverVersion[@"newfeature"];
            for (NSUInteger i = 0; i < [featureArray count] - 1; i ++) {
                weakSelf.featureString = [weakSelf.featureString stringByAppendingFormat:@"%@\n", [featureArray objectAtIndex:i]];
            }
            weakSelf.featureString = [weakSelf.featureString stringByAppendingFormat:@"%@", [featureArray objectAtIndex:([featureArray count] - 1)]];
            weakSelf.featureSize = [weakSelf.featureString boundingRectWithSize:CGSizeMake(weakSelf.view.frame.size.width - 72.0, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]} context:nil].size;
        }
        else {
            weakSelf.serverVersion = @{@"version" : @"unkown", @"buildtime" : @"unkown"};
        }
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        weakSelf.serverCheckFinish = YES;
        if (weakSelf.deviceCheckFinish && weakSelf.serverCheckFinish) {
            if ([weakSelf.acFrame isAnimating]) {
                [weakSelf.acFrame stopAc];
                [weakSelf.tableView reloadData];
            }
        }
        weakSelf.serverVersion = @{@"version" : @"unkown", @"buildtime" : @"unkown"};
    }];
}

- (void)onButtonUpdate {
    [self.acFrame startAc];
    __weak DeviceOpViewController *weakSelf = self;
    [self.client updateDeviceTo:self.serverVersion[@"version"] success:^(NSURLSessionDataTask* task, id response) {
        [weakSelf.acFrame stopAc];
        if ([response[@"result"] isEqualToString:@"good"]) {
            [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"设备正在升级，升级成功后设备会重新启动" action:nil];
        }
        else {
            [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:response[@"detail"] action:nil];
        }
    } failure:^(NSURLSessionDataTask* taskk, NSError* error) {
        [weakSelf.acFrame stopAc];
        [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"网络错误，请稍后再试" action:nil];
    }];
}


@end
