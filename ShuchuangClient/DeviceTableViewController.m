//
//  DeviceTableViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 4/27/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "DeviceTableViewController.h"
#import "SCDeviceManager.h"
#import "SCDeviceClient.h"
#import "MJRefresh.h"
#import "DeviceTableViewCell.h"
#import "SCUtil.h"
#import "MyActivityIndicatorView.h"

@interface DeviceTableViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSArray *devices;
@property BOOL needRefresh;
@property (weak, nonatomic) SCDeviceManager *devManager;
@property (strong, nonatomic) MyActivityIndicatorView *acFrame;

@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UINavigationItem *naviItem;
@property (strong, nonatomic) UIBarButtonItem *rightEditButton;
@property (strong, nonatomic) UIBarButtonItem *rightFinishButton;
- (IBAction)onButtonAdd:(id)sender;
- (void)onRightButton;
- (void)refreshDevicesState;
- (void)addCompletion:(NSNotification *)noti;
@end

@implementation DeviceTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //table view
    [self.tableView registerNib:[UINib nibWithNibName:@"DeviceTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"DeviceTableCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    //navi bar
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.naviBar.frame.size.width - 200, self.naviBar.frame.size.height)];
    titleLabel.text = @"设备";
    [titleLabel setTextColor:[UIColor colorWithRed:21.0 / 255.0 green:37.0 / 255.0 blue:50.0 / 255.0 alpha:1.0]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setFont:[UIFont systemFontOfSize:17.0]];
    self.naviItem = [[UINavigationItem alloc] init];
    self.naviItem.titleView = titleLabel;
    self.rightEditButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit"] style:UIBarButtonItemStylePlain target:self action:@selector(onRightButton)];
    [self.rightEditButton setTintColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]];
    self.rightFinishButton = [[UIBarButtonItem alloc] initWithTitle:@"完成  " style:UIBarButtonItemStylePlain target:self action:@selector(onRightButton)];
    self.naviItem.rightBarButtonItem = self.rightEditButton;
    [self.naviBar pushNavigationItem:self.naviItem animated:YES];
    
    //data
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addCompletion:) name:@"AddCompletionNoti" object:nil];
    self.devManager = [SCDeviceManager instance];
    self.devices = [self.devManager allDevices];
    self.needRefresh = YES;
    __weak DeviceTableViewController *weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.needRefresh = YES;
        [weakSelf refreshDevicesState];
    }];
    
    [self.tabBarController.tabBar setTintColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]];

    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];
}

- (void)viewWillAppear:(BOOL)animated {
    //self.needRefresh = YES;
    [self refreshDevicesState];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.tableView.editing) {
        [self.tableView setEditing:NO animated:YES];
        self.naviItem.rightBarButtonItem = self.rightEditButton;
    }
    [super viewWillDisappear:animated];
}

- (IBAction)onButtonAdd:(id)sender {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Device" bundle:[NSBundle mainBundle]];
    UIViewController *next = [story instantiateViewControllerWithIdentifier:@"DeviceAddVC"];
    [self presentViewController:next animated:YES completion:nil];
}

- (void)onRightButton {
    if (self.tableView.editing) {
        [self.tableView setEditing:NO animated:YES];
        self.naviItem.rightBarButtonItem = self.rightEditButton;
    }
    else {
        [self.tableView setEditing:YES animated:YES];
        self.naviItem.rightBarButtonItem = self.rightFinishButton;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addCompletion:(NSNotification *)noti {
    self.devices = [[SCDeviceManager instance] allDevices];
    [self.tableView reloadData];
}

- (void)refreshDevicesState {
    if (self.tableView.editing) {
        [self.tableView setEditing:NO animated:YES];
    }
    NSInteger num = [self.devices count];
    if (num == 0) {
        [self.tableView.mj_header endRefreshing];
        self.needRefresh = NO;
    }
    else if (num > 0 && self.needRefresh) {
        __block NSInteger finished = 0;
        for (int i = 0; i < num; i++) {
            NSString *key = [self.devices objectAtIndex:i];
            SCDeviceClient* client = [[SCDeviceManager instance] getDevice:key];
            __weak DeviceTableViewController *weakSelf = self;
            [client checkDoorSuccess:^(NSURLSessionDataTask *task, id response) {
                finished++;
                if (finished == num ) {
                    if ([weakSelf.tableView.mj_header isRefreshing]) {
                        [weakSelf.tableView.mj_header endRefreshing];
                    }
                    [weakSelf.tableView reloadData];
                }
            } failure:^(NSURLSessionDataTask *task, NSError* error) {
                finished++;
                if ([weakSelf.tableView.mj_header isRefreshing]) {
                    [weakSelf.tableView.mj_header endRefreshing];
                }
                [weakSelf.tableView reloadData];
            }];
        }
        self.needRefresh = NO;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.needRefresh) {
        return 0;
    }
    else {
        return [self.devices count];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.needRefresh) {
        return 0;
    }
    else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceTableCell" forIndexPath:indexPath];
    SCDeviceClient *client = [self.devManager getDevice:[self.devices objectAtIndex:indexPath.row]];
    cell.nameLabel.text = client.name;
    cell.uuid = client.uuid;
    if (client.doorClose) {
        cell.lockStateImg.image = [UIImage imageNamed:@"lock_highlight"];
    }
    else {
        cell.lockStateImg.image = [UIImage imageNamed:@"lock_gray"];
    }
    if (client.online) {
        cell.netStateImg.image = [UIImage imageNamed:@"online"];
        cell.netStateLabel.text = @"设备状态（在线）";
    }
    else {
        cell.netStateImg.image = [UIImage imageNamed:@"offline"];
        cell.netStateLabel.text = @"设备状态（离线）";
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma - mark TableView Delegate
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!tableView.editing) {
        return UITableViewCellEditingStyleNone;
    }
    else {
        return UITableViewCellEditingStyleDelete;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        __weak DeviceTableViewController *weakSelf = self;
        [SCUtil viewController:self showAlertTitle:@"提示" message:@"确认删除这个设备吗" yesAction:^(UIAlertAction *action) {
            [weakSelf.acFrame startAc];
            NSString *uuid = [self.devices objectAtIndex:indexPath.row];
            SCDeviceClient *client = [[SCDeviceManager instance] getDevice:uuid];
            [client logoutSuccess:^(NSURLSessionDataTask *task, id response) {
                [weakSelf.acFrame stopAc];
                [[SCDeviceManager instance] removeDevice:uuid];
                weakSelf.devices = [self.devManager allDevices];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [weakSelf.acFrame stopAc];
                [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"网络错误，请稍后再试" action:nil];
            }];
        } noAction:^(UIAlertAction *action) {
            
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SCDeviceClient *client = [self.devManager getDevice:[self.devices objectAtIndex:indexPath.row]];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Device" bundle:[NSBundle mainBundle]];
    UIViewController *next = [story instantiateViewControllerWithIdentifier:@"DeviceDetailVC"];
    [next setValue:client.uuid forKey:@"uuid"];
    [self presentViewController:next animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
