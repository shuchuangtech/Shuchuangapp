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
@property (strong, nonatomic) MyActivityIndicatorView* acFrame;
@property (strong, nonatomic) SCDeviceClient *device;


- (void)showDeviceInfo;
- (void)changeDeviceName;
- (void)reVerifyPassword;
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
#define TABLE_ITEM_NUM 6
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //navigation bar
    UINavigationItem *naviItem = [[UINavigationItem alloc] initWithTitle:@"设备"];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list"] style:UIBarButtonItemStylePlain target:self action:@selector(onRightButton)];
    [leftBarButton setTintColor:[UIColor colorWithRed:1.0 green:129.0/255.0 blue:0.0 alpha:1.0]];
    [rightBarButton setTintColor:[UIColor colorWithRed:1.0 green:129.0/255.0 blue:0.0 alpha:1.0]];
    naviItem.leftBarButtonItem = leftBarButton;
    naviItem.rightBarButtonItem = rightBarButton;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    
    //task label
    self.taskView = [[UIView alloc] init];
    [self.taskView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.taskView];
    self.taskLabel = [[UILabel alloc] init];
    [self.taskLabel setFont:[UIFont systemFontOfSize:13.0]];
    self.taskLabel.text = @"定时 21:00 开启";
    [self.taskView addSubview:self.taskLabel];
    //middle switch button
    self.swActive = NO;
    [self setDeviceInactive];
    
    //bottom button views
    CGFloat viewWidth = (self.view.frame.size.width - 40.0) / 3;
    CGFloat viewHeight = viewWidth;
    CGFloat viewTop = self.view.frame.size.height - viewHeight;
    CGFloat viewLeft = 20;
    DetailBottomView *taskBottomView = [[DetailBottomView alloc] initWithFrame:CGRectMake(viewLeft, viewTop, viewWidth, viewHeight) image:[UIImage imageNamed:@"detail_task"] labelText:@"定时任务" leftLine:NO rightLine:YES];
    DetailBottomView *listBottomView = [[DetailBottomView alloc] initWithFrame:CGRectMake(viewLeft + viewWidth, viewTop, viewWidth, viewHeight) image:[UIImage imageNamed:@"detail_list"] labelText:@"记录查询" leftLine:YES rightLine:YES];
    DetailBottomView *userBottomView = [[DetailBottomView alloc] initWithFrame:CGRectMake(viewLeft + 2 * viewWidth, viewTop, viewWidth, viewHeight) image:[UIImage imageNamed:@"detail_user"] labelText:@"查看用户" leftLine:YES rightLine:NO];
    [taskBottomView setBackgroundColor:[UIColor whiteColor]];
    [listBottomView setBackgroundColor:[UIColor whiteColor]];
    [userBottomView setBackgroundColor:[UIColor whiteColor]];
    [userBottomView.button addTarget:self action:@selector(onUserButton) forControlEvents:UIControlEventTouchUpInside];
    [taskBottomView.button addTarget:self action:@selector(onTaskButton) forControlEvents:UIControlEventTouchUpInside];
    [listBottomView.button addTarget:self action:@selector(onListButton) forControlEvents:UIControlEventTouchUpInside];
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
    CGFloat tc_width = self.view.frame.size.width / 4;
    CGFloat tc_height = tc_width * TABLE_ITEM_NUM / 3 + 13;
    UIImageView *tableBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tc_width, tc_height)];
    [tableBg setImage:[UIImage imageNamed:@"tablebg"]];
    [self.tableContainer addSubview:tableBg];
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 13, tc_width, tc_height - 13)];
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
}

- (void)viewWillLayoutSubviews {
    //task view
    [self.taskView setFrame:CGRectMake(0, self.naviBar.frame.origin.y  + self.naviBar.frame.size.height, self.view.frame.size.width, self.naviBar.frame.size.height)];
    [self.taskLabel setFrame:CGRectMake(self.taskView.frame.size.width / 2 - 50, self.taskView.frame.size.height / 2 - 15, 100, 30)];
    
    //table view
    CGFloat tc_width = self.view.frame.size.width / 4;
    CGFloat tc_height = tc_width * TABLE_ITEM_NUM / 3 + 13;
    [self.tableContainer setFrame:CGRectMake(self.view.frame.size.width * 3 / 4 - 10, self.naviBar.frame.origin.y + self.naviBar.frame.size.height, tc_width, tc_height)];
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.needFresh) {
        self.needFresh = NO;
        [self.acFrame startAc];
        [self.device checkDoorSuccess:^(NSURLSessionDataTask *task, id response) {
            [self.acFrame stopAc];
            if ([response[@"result"] isEqualToString:@"good"]) {
                if (self.device.switchClose) {
                    [self.swButton setImage:[UIImage imageNamed:@"buttonSw_active"] forState:UIControlStateNormal];
                    self.swActive = YES;
                }
                else {
                    [self.swButton setImage:[UIImage imageNamed:@"buttonSw"] forState:UIControlStateNormal];
                    self.swActive = NO;
                }
            }
            else {
                [SCUtil viewController:self showAlertTitle:@"提示" message:response[@"detail"] action:nil];
            }
            
        }
        failure:^(NSURLSessionDataTask *task, NSError *error) {
            [self.acFrame stopAc];
            [SCUtil viewController:self showAlertTitle:@"提示" message:@"网络错误，获取设备状态失败" action:nil];
        }];
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

- (IBAction)onSwButton:(id)sender {
    if (self.showTable) {
        [self onRightButton];
    }
    [self.acFrame startAc];
    if (self.swActive) {
        [self.device openDoorSuccess:^(NSURLSessionDataTask *task, id response) {
            [self.acFrame stopAc];
            if ([response[@"result"] isEqualToString:@"good"]) {
                if (self.swActive) {
                    [self setDeviceInactive];
                }
                else {
                    [self setDeviceActive];
                }
            }
            else {
                [SCUtil viewController:self showAlertTitle:@"提示" message:response[@"detail"] action:nil];
            }
        }
        failure:^(NSURLSessionDataTask *task, NSError *error) {
            [self.acFrame stopAc];
            [SCUtil viewController:self showAlertTitle:@"提示" message:@"网络错误，设备操作失败" action:nil];
        }];
    }
    else {
        [self.device closeDoorSuccess:^(NSURLSessionDataTask *task, id response) {
            [self.acFrame stopAc];
            if ([response[@"result"] isEqualToString:@"good"]) {
                if (self.swActive) {
                    [self setDeviceInactive];
                }
                else {
                    [self setDeviceActive];
                }
            }
            else {
                [SCUtil viewController:self showAlertTitle:@"提示" message:response[@"detail"] action:nil];
            }
        }
        failure:^(NSURLSessionDataTask *task, NSError *error) {
            [self.acFrame stopAc];
            [SCUtil viewController:self showAlertTitle:@"提示" message:@"网络错误，设备操作失败" action:nil];
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
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([alert.textFields[0] isFirstResponder]) {
            [alert.textFields[0] resignFirstResponder];
        }
        if ([alert.textFields[0].text length] != 0) {
            NSString *name = alert.textFields[0].text;
            [self.device updateDeviceName:name];
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
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([alert.textFields[0] isFirstResponder]) {
            [alert.textFields[0] resignFirstResponder];
        }
        if ([alert.textFields[0].text length] != 0) {
            NSString *password = alert.textFields[0].text;
            [self.device login:@"admin" password:password success:^(NSURLSessionDataTask *task, id response) {
                if ([response[@"result"] isEqualToString:@"good"]) {
                    [SCUtil viewController:self showAlertTitle:@"提示" message:@"密码重新验证成功" action:nil];
                }
                else {
                    [SCUtil viewController:self showAlertTitle:@"提示" message:response[@"detail"] action:nil];
                }
            }failure:^(NSURLSessionDataTask *task, NSError *error) {
                [SCUtil viewController:self showAlertTitle:@"提示" message:@"网络错误，验证密码失败" action:nil];
            }];
        }
        
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"请输入设备密码";
    }];
    [alert addAction:cancelAction];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"DeviceDetailToPassword"]) {
        id desVC = segue.destinationViewController;
        [desVC setValue:self.uuid forKey:@"devId"];
        [desVC setValue:@NO forKey:@"firstAdd"];
    }
    else if ([segue.identifier isEqualToString:@"DetailToChangePassword"]){
        id desVC = segue.destinationViewController;
        [desVC setValue:self.uuid forKey:@"uuid"];
    }
    else if ([segue.identifier isEqualToString:@"DetailToTaskSegue"]) {
        id desVC = segue.destinationViewController;
        [desVC setValue:self.uuid forKey:@"uuid"];
    }
    else if ([segue.identifier isEqualToString:@"DetailToRecordSegue"]) {
        id desVC = segue.destinationViewController;
        [desVC setValue:self.uuid forKey:@"uuid"];
    }
    else if ([segue.identifier isEqualToString:@"DetailToUserSegue"]) {
        id desVC = segue.destinationViewController;
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
            [cell setImage:[UIImage imageNamed:@"table_info"] labelText:@"恢复设置"];
        default:
            break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.tableContainer.frame.size.width / 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [self performSegueWithIdentifier:@"DeviceDetailToPassword" sender:self];
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
            break;
        case 5:
            break;
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self onRightButton];
}
@end
