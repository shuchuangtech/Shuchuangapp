//
//  DeviceDetailViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/20/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "DeviceDetailViewController.h"
#import "DetailBottomView.h"
#import "TableViewCell.h"
#import "SCHTTPManager.h"
#import "MyActivityIndicatorView.h"
#import "SCUtil.h"
#import "SCDeviceClient.h"
#import "SCDeviceManager.h"
@interface DeviceDetailViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (strong, nonatomic) UIView *taskView;
@property (strong, nonatomic) UILabel *taskLabel;
@property (weak, nonatomic) IBOutlet UIButton *swButton;
@property (nonatomic) BOOL swActive;
@property (strong, nonatomic) UIView *tableContainer;
@property (nonatomic) BOOL showTable;
@property (nonatomic) BOOL needFresh;
@property (nonatomic) BOOL stateRefreshFinish;
@property (nonatomic) BOOL modeRefreshFinish;
@property (strong, nonatomic) MyActivityIndicatorView* acFrame;
@property (weak, nonatomic) SCDeviceClient *device;
@property (nonatomic) NSInteger selectItem;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modeSegController;
@property (strong, nonatomic) UIImageView *barBg;
@property (strong, nonatomic) UIImageView *bgView;


- (void)showDeviceInfo;
- (void)changeDeviceName;
- (void)reVerifyPassword;
- (void)resetDeviceConfig;
- (void)rightButtonAnimationWillStart;
- (void)rightButtonAnimationDidStop;
- (IBAction)onSwButton:(id)sender;
- (void)onLeftButton;
- (void)onRightButton;
- (void)onUserButton;
- (void)onTaskButton;
- (void)onListButton;
- (void)setDeviceActive;
- (void)setDeviceInactive;
- (void)handleSingleTap:(UITapGestureRecognizer *)sender;
@end

@implementation DeviceDetailViewController
#define TABLE_ITEM_NUM 7
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //navigation bar
    UINavigationItem *naviItem = [[UINavigationItem alloc] init];
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.naviBar.frame.size.width - 100, self.naviBar.frame.size.height)];
    [titleLab setText:@"设备"];
    [titleLab setTextColor:[UIColor whiteColor]];
    [titleLab setFont:[UIFont systemFontOfSize:17.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    naviItem.titleView = titleLab;
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list"] style:UIBarButtonItemStylePlain target:self action:@selector(onRightButton)];
    [leftBarButton setTintColor:[UIColor whiteColor]];
    [rightBarButton setTintColor:[UIColor whiteColor]];
    naviItem.leftBarButtonItem = leftBarButton;
    naviItem.rightBarButtonItem = rightBarButton;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    [self.naviBar setBackgroundImage:[UIImage imageNamed:@"barBg"] forBarMetrics:UIBarMetricsCompact];
    
    
    //task label
    self.taskView = [[UIView alloc] init];
    [self.taskView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.taskView];
    self.taskLabel = [[UILabel alloc] init];
    [self.taskLabel setFont:[UIFont systemFontOfSize:13.0]];
    self.taskLabel.text = @"";
    self.taskLabel.textAlignment = NSTextAlignmentCenter;
    [self.taskView setBackgroundColor:[UIColor clearColor]];
    [self.taskView addSubview:self.taskLabel];
    
    //middle switch button
    self.swActive = NO;
    [self setDeviceInactive];
    
    //bottom button views
    CGFloat viewWidth = (self.view.frame.size.width) / 3;
    CGFloat viewHeight = viewWidth * 0.65;
    CGFloat viewTop = self.view.frame.size.height - viewHeight;
    CGFloat viewLeft = 0;
    DetailBottomView *taskBottomView = [[DetailBottomView alloc] initWithFrame:CGRectMake(viewLeft, viewTop, viewWidth, viewHeight) image:[UIImage imageNamed:@"detail_task"] activeImage:[UIImage imageNamed:@"detail_task_active"] leftLine:NO rightLine:YES];
    DetailBottomView *listBottomView = [[DetailBottomView alloc] initWithFrame:CGRectMake(viewLeft + viewWidth, viewTop, viewWidth, viewHeight) image:[UIImage imageNamed:@"detail_list"] activeImage:[UIImage imageNamed:@"detail_list_active"] leftLine:YES rightLine:YES];
    DetailBottomView *userBottomView = [[DetailBottomView alloc] initWithFrame:CGRectMake(viewLeft + 2 * viewWidth, viewTop, viewWidth, viewHeight) image:[UIImage imageNamed:@"detail_user"] activeImage:[UIImage imageNamed:@"detail_user_active"] leftLine:YES rightLine:NO];
    [taskBottomView setBackgroundColor:[UIColor whiteColor]];
    [listBottomView setBackgroundColor:[UIColor whiteColor]];
    [userBottomView setBackgroundColor:[UIColor whiteColor]];
    [userBottomView.button addTarget:self action:@selector(onUserButton) forControlEvents:UIControlEventTouchUpInside];
    [taskBottomView.button addTarget:self action:@selector(onTaskButton) forControlEvents:UIControlEventTouchUpInside];
    [listBottomView.button addTarget:self action:@selector(onListButton) forControlEvents:UIControlEventTouchUpInside];
    [taskBottomView setBackgroundColor:[UIColor colorWithRed:235.0 / 255.0 green:235.0 / 255.0 blue:235.0 / 255.0 alpha:1.0]];
    [userBottomView setBackgroundColor:[UIColor colorWithRed:235.0 / 255.0 green:235.0 / 255.0 blue:235.0 / 255.0 alpha:1.0]];
    [listBottomView setBackgroundColor:[UIColor colorWithRed:235.0 / 255.0 green:235.0 / 255.0 blue:235.0 / 255.0 alpha:1.0]];
    [self.view addSubview:taskBottomView];
    [self.view addSubview:listBottomView];
    [self.view addSubview:userBottomView];

    //screen gesture
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.delegate = self;
    [self.view addGestureRecognizer:singleTap];
    
    //ac frame
    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];
    [self.view addSubview:self.acFrame];
    
    //show table
    self.tableContainer = [[UIView alloc] init];
    CGFloat tc_width = self.view.frame.size.width / 4 ;
    CGFloat tc_height = tc_width * TABLE_ITEM_NUM / 3 + 25;
    UIImageView *tableBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tc_width, tc_height)];
    [tableBg setImage:[UIImage imageNamed:@"tablebg2"]];
    [self.tableContainer addSubview:tableBg];
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 25, tc_width, tc_height - 25)];
    [tableView registerClass:[TableViewCell class] forCellReuseIdentifier:@"PrototypeCell"];
    [[tableView tableHeaderView] setBackgroundColor:[UIColor yellowColor]];
    [self.tableContainer addSubview:tableView];
    self.showTable = NO;
    [tableView setBackgroundColor:[UIColor clearColor]];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableContainer.hidden = YES;
    [self.view addSubview:self.tableContainer];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.device = [[SCDeviceManager instance] getDevice:self.uuid];
    self.needFresh = YES;
    
    self.selectItem = -1;
    
    [self.modeSegController addTarget:self action:@selector(onModeChange) forControlEvents:UIControlEventValueChanged];
    
    self.barBg = [[UIImageView alloc] init];
    [self.barBg setImage:[UIImage imageNamed:@"barBg"]];
    [self.view addSubview:self.barBg];
    [self.view bringSubviewToFront:self.naviBar];
    self.bgView = [[UIImageView alloc] init];
    [self.bgView setImage:[UIImage imageNamed:@"background"]];
    [self.view addSubview:self.bgView];
    [self.view sendSubviewToBack:self.bgView];
}

- (void)viewWillLayoutSubviews {
    [self.barBg setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.naviBar.frame.size.height + self.naviBar.frame.origin.y)];
    [self.bgView setFrame:CGRectMake(0, self.barBg.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.barBg.frame.size.height)];
    //task view
    [self.taskView setFrame:CGRectMake(0, self.naviBar.frame.origin.y  + self.naviBar.frame.size.height, self.view.frame.size.width, self.naviBar.frame.size.height)];
    [self.taskLabel setFrame:CGRectMake(0, 0, self.taskView.frame.size.width, self.taskView.frame.size.height)];
    
    //table view
    CGFloat tc_width = self.view.frame.size.width / 4;
    CGFloat tc_height = tc_width * TABLE_ITEM_NUM / 3 + 13;
    [self.tableContainer setFrame:CGRectMake(self.view.frame.size.width * 3 / 4 - 20, self.naviBar.frame.origin.y + self.naviBar.frame.size.height, tc_width, tc_height)];
    
    if (![self.device.user isEqualToString:@"admin"]) {
        self.modeSegController.hidden = YES;
    }
    [super viewWillLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.needFresh) {
        self.needFresh = NO;
        [self.acFrame startAc];
        self.stateRefreshFinish = NO;
        self.modeRefreshFinish = NO;
        __weak DeviceDetailViewController *weakSelf = self;
        [self.device checkDoorSuccess:^(NSURLSessionDataTask *task, id response) {
            weakSelf.stateRefreshFinish = YES;
            if (weakSelf.stateRefreshFinish && weakSelf.modeRefreshFinish) {
                [weakSelf.acFrame stopAc];
            }
            if ([response[@"result"] isEqualToString:@"good"]) {
                if (weakSelf.device.switchClose) {
                    [weakSelf.swButton setImage:[UIImage imageNamed:@"buttonSw_active"] forState:UIControlStateNormal];
                    weakSelf.swActive = YES;
                }
                else {
                    [weakSelf.swButton setImage:[UIImage imageNamed:@"buttonSw"] forState:UIControlStateNormal];
                    weakSelf.swActive = NO;
                }
            }
            else {
                [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:response[@"detail"] action:nil];
            }
            
        }
        failure:^(NSURLSessionDataTask *task, NSError *error) {
            weakSelf.stateRefreshFinish = YES;
            if (weakSelf.stateRefreshFinish && weakSelf.modeRefreshFinish) {
                [weakSelf.acFrame stopAc];
            }
            [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"网络错误，获取设备状态失败" action:nil];
        }];
        if (!self.modeSegController.hidden) {
            [self.device getDeviceModeSuccess:^(NSURLSessionDataTask *task, id response) {
                weakSelf.modeRefreshFinish = YES;
                if (weakSelf.stateRefreshFinish && weakSelf.modeRefreshFinish) {
                    [weakSelf.acFrame stopAc];
                }
                if ([response[@"result"] isEqualToString:@"good"]) {
                    [weakSelf.modeSegController setSelectedSegmentIndex:[[response objectForKey:@"mode"] integerValue]];
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                weakSelf.modeRefreshFinish = YES;
                if (weakSelf.stateRefreshFinish && weakSelf.modeRefreshFinish) {
                    [weakSelf.acFrame stopAc];
                }
            }];
        }
        else {
            self.modeRefreshFinish = YES;
            if (self.stateRefreshFinish && self.modeRefreshFinish) {
                [self.acFrame stopAc];
            }
        }
    }
    else {
        if (self.device.switchClose) {
            [self.swButton setImage:[UIImage imageNamed:@"buttonSw_active"] forState:UIControlStateNormal];
            self.swActive = YES;
        }
        else {
            [self.swButton setImage:[UIImage imageNamed:@"buttonSw"] forState:UIControlStateNormal];
            self.swActive = NO;
        }
    }
    //task label
    NSCalendar *calender = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit unitFlasg = NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitWeekday;
    NSDate *now = [NSDate date];
    NSDateComponents *nowDateComp = [calender components:unitFlasg fromDate:now];
    NSArray *array = [self.device getLocalTasks];
    NSInteger nearestMinute = 7 * 24 * 60;
    NSInteger nearestOption = 0;
    NSInteger w = [nowDateComp weekday];    //today weekday
    for (int i = 0; i < [array count]; i++) {
        NSDictionary *task = [array objectAtIndex:i];
        if ([task[@"active"] integerValue] == 0)
            continue;
        NSInteger mask = 0x40 >> (w - 1);
        NSInteger weekday = [task[@"weekday"] integerValue];
        NSInteger hour = [task[@"hour"] integerValue];
        NSInteger minute = [task[@"minute"] integerValue];
        for (int j = 0; j < 8; j++) {
            if ((weekday & mask) != 0)
            {
                NSInteger minuteDiff = j * 24 * 60 + (hour * 60 + minute - [nowDateComp hour] * 60 - [nowDateComp minute]);
                if (minuteDiff < 0) {
                    if (j == 0)
                        continue;
                    else
                        minuteDiff += 7 * 24 * 60;
                }
                if (minuteDiff < nearestMinute) {
                    nearestMinute = minuteDiff;
                    nearestOption = [task[@"option"] integerValue];
                }
                break;
            }
            if (mask == 1) {
                mask = 0x40;
            }
            else {
                mask = mask >> 1;
            }
        }
    }
    if (nearestMinute < 7 * 24 * 60) {
        self.taskLabel.hidden = NO;
        NSInteger minute = nearestMinute % 60;
        NSInteger hour = ((nearestMinute - minute) / 60) % 24;
        NSInteger day = (nearestMinute - minute - hour * 60) / (24 * 60);
        NSString *option = (nearestOption == 1)?@"开启":@"关闭";
        self.taskLabel.text = [NSString stringWithFormat:@"定时%ld天%ld小时%ld分钟后%@", (long)day, (long)hour, (long)minute, option];
    }
    else {
        self.taskLabel.hidden = YES;
    }
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onTaskButton {
    [self performSegueWithIdentifier:@"DetailToTaskSegue" sender:self];
}

- (void)onListButton {
    [self performSegueWithIdentifier:@"DetailToRecordSegue" sender:self];
}

- (void)onUserButton {
    [self performSegueWithIdentifier:@"DetailToUserSegue" sender:self];
}

- (void)onModeChange {
    [self.acFrame startAc];
    __weak DeviceDetailViewController *weakSelf = self;
    [self.device changeDeviceMode:[self.modeSegController selectedSegmentIndex] success:^(NSURLSessionDataTask *task, id response) {
        [weakSelf.acFrame stopAc];
        if (![response[@"result"] isEqualToString:@"good"]) {
            [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:response[@"detail"] action:^(UIAlertAction *action) {
                [weakSelf.modeSegController setSelectedSegmentIndex:(1 - [weakSelf.modeSegController selectedSegmentIndex])];
            }];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"网络错误，请稍后再试" action:^(UIAlertAction *action) {
            [weakSelf.modeSegController setSelectedSegmentIndex:(1 - [weakSelf.modeSegController selectedSegmentIndex])];
        }];
    }];
}

- (IBAction)onSwButton:(id)sender {
    if (self.showTable) {
        [self onRightButton];
    }
    [self.acFrame startAc];
    __weak DeviceDetailViewController *weakSelf = self;
    if (self.swActive) {
        [self.device openDoorSuccess:^(NSURLSessionDataTask *task, id response) {
            [weakSelf.acFrame stopAc];
            if ([response[@"result"] isEqualToString:@"good"]) {
                if (weakSelf.swActive) {
                    [weakSelf setDeviceInactive];
                }
                else {
                    [weakSelf setDeviceActive];
                }
            }
            else {
                [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:response[@"detail"] action:nil];
            }
        }
        failure:^(NSURLSessionDataTask *task, NSError *error) {
            [weakSelf.acFrame stopAc];
            [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"网络错误，设备操作失败" action:nil];
        }];
    }
    else {
        [self.device closeDoorSuccess:^(NSURLSessionDataTask *task, id response) {
            [weakSelf.acFrame stopAc];
            if ([response[@"result"] isEqualToString:@"good"]) {
                if (weakSelf.swActive) {
                    [weakSelf setDeviceInactive];
                }
                else {
                    [weakSelf setDeviceActive];
                }
            }
            else {
                [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:response[@"detail"] action:nil];
            }
        }
        failure:^(NSURLSessionDataTask *task, NSError *error) {
            [weakSelf.acFrame stopAc];
            [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"网络错误，设备操作失败" action:nil];
        }];
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender {
    if (self.showTable) {
        [self onRightButton];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}

- (void)onLeftButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onRightButton {
    self.showTable = !self.showTable;
    if ([self.tableContainer isHidden]) {
        self.tableContainer.transform = CGAffineTransformMakeScale(0, 0);
        [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.2f];
        self.tableContainer.transform = CGAffineTransformMakeScale(1.0, 1.0);
        [UIView setAnimationDelegate:self];
        [UIView setAnimationWillStartSelector:@selector(rightButtonAnimationWillStart)];
        [UIView setAnimationDidStopSelector:@selector(rightButtonAnimationDidStop)];
        [UIView commitAnimations];
    }
    else {
        self.tableContainer.transform = CGAffineTransformMakeScale(1.0, 1.0);
        [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.2f];
        self.tableContainer.transform = CGAffineTransformMakeScale(0.1, 0.1);
        [UIView setAnimationDelegate:self];
        [UIView setAnimationWillStartSelector:@selector(rightButtonAnimationWillStart)];
        [UIView setAnimationDidStopSelector:@selector(rightButtonAnimationDidStop)];
        [UIView commitAnimations];
    }
}

- (void)rightButtonAnimationWillStart {
    [self.tableContainer.layer setAnchorPoint:CGPointMake(1, 0)];
    [self.tableContainer.layer setPosition:CGPointMake(self.tableContainer.layer.position.x + self.tableContainer.layer.bounds.size.width * 0.5, self.tableContainer.layer.position.y + self.tableContainer.layer.bounds.size.height * (-0.5))];
    //ready to show
    if ([self.tableContainer isHidden] && self.showTable) {
        [self.view bringSubviewToFront:self.tableContainer];
        self.tableContainer.hidden = NO;
    }
    //ready to hide
    else if (![self.tableContainer isHidden] && !self.showTable) {
        
    }
}

- (void)rightButtonAnimationDidStop {
    [self.tableContainer.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
    [self.tableContainer.layer setPosition:CGPointMake(self.tableContainer.layer.position.x + self.tableContainer.layer.bounds.size.width * (-0.5), self.tableContainer.layer.position.y + self.tableContainer.layer.bounds.size.height * 0.5)];
    //show finish
    if ([self.tableContainer isHidden] && self.showTable) {
        
    }
    //hide finish
    else if (![self.tableContainer isHidden] && !self.showTable) {
        self.tableContainer.hidden = YES;
        [self.view sendSubviewToBack:self.tableContainer];
        switch (self.selectItem) {
            case 0:
                [self reVerifyPassword];
                break;
            case 1:
                [self changeDeviceName];
                break;
            case 2:
                [self performSegueWithIdentifier:@"DetailToChangePassword" sender:self];
                break;
            case 3:
                [self showDeviceInfo];
                break;
            case 4:
                [self performSegueWithIdentifier:@"DetailToAddUserSegue" sender:self];
                break;
            case 5:
                [self resetDeviceConfig];
                break;
            case 6:
                [self performSegueWithIdentifier:@"DetailToUpdateSegue" sender:self];
            default:
                break;
        }
        self.selectItem = -1;
    }
}

- (void)setDeviceActive {
    [self.swButton setImage:[UIImage imageNamed:@"buttonSw_active"] forState:UIControlStateNormal];
    self.swActive = YES;
}

- (void)setDeviceInactive {
    [self.swButton setImage:[UIImage imageNamed:@"buttonSw"] forState:UIControlStateNormal];
    self.swActive = NO;
}

- (void)changeDeviceName {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"修改设备名称" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        if ([alert.textFields[0] isFirstResponder]) {
            [alert.textFields[0] resignFirstResponder];
        }
    }];
    __weak DeviceDetailViewController *weakSelf = self;
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([alert.textFields[0] isFirstResponder]) {
            [alert.textFields[0] resignFirstResponder];
        }
        if ([alert.textFields[0].text length] != 0) {
            NSString *name = alert.textFields[0].text;
            [weakSelf.device updateDeviceName:name];
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
    NSString *message = [[NSString alloc] initWithFormat:@"设备名称: %@\n设备序列号: %@\n设备类型: %@", self.device.name, self.device.uuid, self.device.type];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"设备信息" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)reVerifyPassword {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"重新验证设备密码" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        if ([alert.textFields[0] isFirstResponder]) {
            [alert.textFields[0] resignFirstResponder];
        }
    }];
    __weak DeviceDetailViewController *weakSelf = self;
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([alert.textFields[0] isFirstResponder]) {
            [alert.textFields[0] resignFirstResponder];
        }
        if ([alert.textFields[0].text length] != 0) {
            NSString *password = alert.textFields[0].text;
            [weakSelf.device login:@"admin" password:password success:^(NSURLSessionDataTask *task, id response) {
                if ([response[@"result"] isEqualToString:@"good"]) {
                    [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"密码重新验证成功" action:nil];
                }
                else {
                    [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:response[@"detail"] action:nil];
                }
            }failure:^(NSURLSessionDataTask *task, NSError *error) {
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

- (void)resetDeviceConfig {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"恢复设备出厂设置会还原设备的管理密码，删除设备上的所有自定义用户、定时任务。\n是否要继续？" preferredStyle:UIAlertControllerStyleAlert];
    __weak DeviceDetailViewController *weakSelf = self;
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action) {
        [weakSelf.acFrame startAc];
        [weakSelf.device resetDeviceSuccess:^(NSURLSessionDataTask* task, id response) {
            [weakSelf.acFrame stopAc];
            if ([response[@"result"] isEqualToString:@"good"]) {
                [weakSelf.device clearLocalTasks];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    id desVC = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"DetailToChangePassword"]){
        [desVC setValue:self.uuid forKey:@"uuid"];
    }
    else if ([segue.identifier isEqualToString:@"DetailToTaskSegue"]) {
        [desVC setValue:self.uuid forKey:@"uuid"];
    }
    else if ([segue.identifier isEqualToString:@"DetailToRecordSegue"]) {
        [desVC setValue:self.uuid forKey:@"uuid"];
    }
    else if ([segue.identifier isEqualToString:@"DetailToUserSegue"]) {
        [desVC setValue:self.uuid forKey:@"uuid"];
    }
    else if ([segue.identifier isEqualToString:@"DetailToUpdateSegue"]) {
        [desVC setValue:self.uuid forKey:@"uuid"];
    }
    else if ([segue.identifier isEqualToString:@"DetailToAddUserSegue"]) {
        [desVC setValue:self.uuid forKey:@"uuid"];
    }
}

#pragma mark - Table DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return TABLE_ITEM_NUM;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (TableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PrototypeCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    switch (indexPath.row) {
        case 0:
            [cell setImage:[UIImage imageNamed:@"table_restart"] labelText:@"重新验证"];
            break;
        case 1:
            [cell setImage:[UIImage imageNamed:@"table_edit"] labelText:@"修改名称"];
            break;
        case 2:
            [cell setImage:[UIImage imageNamed:@"table_password"] labelText:@"修改密码"];
            break;
        case 3:
            [cell setImage:[UIImage imageNamed:@"table_info"] labelText:@"设备信息"];
            break;
        case 4:
            [cell setImage:[UIImage imageNamed:@"table_share"] labelText:@"分享设备"];
            break;
        case 5:
            [cell setImage:[UIImage imageNamed:@"table_reset"] labelText:@"恢复设置"];
            break;
        case 6:
            [cell setImage:[UIImage imageNamed:@"table_update"] labelText:@"检查更新"];
            break;
        default:
            break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.tableContainer.frame.size.width / 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self onRightButton];
    self.selectItem = indexPath.row;
}
@end
