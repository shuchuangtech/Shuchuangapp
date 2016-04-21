//
//  TaskViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/25/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "TaskViewController.h"
#import "TaskListTableViewCell.h"
#import "SCDeviceManager.h"
#import "SCDeviceClient.h"
#import "AddTaskViewController.h"
#import "SCUtil.h"
#import "MyActivityIndicatorView.h"
#import "MJRefresh.h"

static NSArray *weekday;
@interface TaskViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray* tasks;
@property (weak, nonatomic) SCDeviceClient *client;
@property (weak, nonatomic) NSString *uuid;
@property NSDictionary *modifyTask;
@property NSInteger modifyIndex;
@property (strong, nonatomic) MyActivityIndicatorView *acFrame;
@property (strong, nonatomic) UIImageView *barBg;
@property (strong, nonatomic) UIImageView *bgView;


- (void)refreshTaskList;
- (void)onLeftButton;
- (void)onRightButton;
@end

@implementation TaskViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UINavigationItem *naviItem = [[UINavigationItem alloc] init];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add"] style:UIBarButtonItemStylePlain target:self action:@selector(onRightButton)];
    [leftButton setTintColor:[UIColor whiteColor]];
    [rightButton setTintColor:[UIColor whiteColor]];
    naviItem.leftBarButtonItem = leftButton;
    naviItem.rightBarButtonItem = rightButton;
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.naviBar.frame.size.width - 100, self.naviBar.frame.size.height)];
    [titleLab setText:@"定时任务"];
    [titleLab setTextColor:[UIColor whiteColor]];
    [titleLab setFont:[UIFont systemFontOfSize:17.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    naviItem.titleView = titleLab;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    [self.naviBar setBackgroundImage:[UIImage imageNamed:@"barBg"] forBarMetrics:UIBarMetricsCompact];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView registerNib:[UINib nibWithNibName:@"TaskListTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"taskProtoCellXib"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    __weak TaskViewController *weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf refreshTaskList];
    }];
    self.client = [[SCDeviceManager instance] getDevice:self.uuid];
    self.tasks = [self.client getLocalTasks];
    weekday = [NSArray arrayWithObjects:@"日", @"一", @"二", @"三", @"四", @"五", @"六", nil];
    self.modifyTask = nil;
    self.modifyIndex = 0;
    
    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];
    
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
    [super viewWillLayoutSubviews];
    [self.barBg setFrame:CGRectMake(0, 0, self.view.frame.size.width, 64.0)];
    [self.bgView setFrame:CGRectMake(0, self.barBg.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.barBg.frame.size.height)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onLeftButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onRightButton {
    self.modifyTask = nil;
    [self performSegueWithIdentifier:@"TaskToAddTaskSegue" sender:self];
}

- (void)refreshTaskList {
    [self.acFrame startAc];
    __weak TaskViewController *weakSelf = self;
    [self.client getTasksSuccess:^(NSURLSessionDataTask *task, id response) {
        [weakSelf.acFrame stopAc];
        if ([weakSelf.tableView.mj_header isRefreshing]) {
            [weakSelf.tableView.mj_header endRefreshing];
        }
        if ([response[@"result"] isEqualToString:@"good"]) {
            weakSelf.tasks = [weakSelf.client getLocalTasks];
            [weakSelf.tableView reloadData];
        }
        else {
            [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:response[@"detail"] action:nil];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakSelf.acFrame stopAc];
        if ([weakSelf.tableView.mj_header isRefreshing]) {
            [weakSelf.tableView.mj_header endRefreshing];
        }
        [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"网络错误，请稍后再试" action:nil];
    }];
}

#pragma mark - AddTaskProtocol

- (void)finishAdd {
    self.tasks = [self.client getLocalTasks];
    [self.tableView reloadData];
}

- (void)cancelAdd {
    
}

#pragma mark - ModifyTaskProtocol

- (void)setTask:(NSInteger)index active:(BOOL)active {
    NSMutableDictionary *task = [[NSMutableDictionary alloc] initWithDictionary:[self.tasks objectAtIndex:index]];
    if (active) {
        [task setValue:[NSNumber numberWithInteger:1] forKey:@"active"];
    }
    else {
        [task setValue:[NSNumber numberWithInteger:0] forKey:@"active"];
    }
    [self.acFrame startAc];
    __weak TaskViewController *weakSelf = self;
    [self.client updateTask:task atIndex:index success:^(NSURLSessionDataTask *task, id response) {
        [weakSelf.acFrame stopAc];
        if (![response[@"result"] isEqualToString:@"good"]) {
            TaskListTableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
            [cell.taskSwitch setOn:!active];
            [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:response[@"detail"] action:nil];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakSelf.acFrame stopAc];
        TaskListTableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        [cell.taskSwitch setOn:!active];
        [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"网络错误，请稍后再试" action:nil];
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    AddTaskViewController *desVC = segue.destinationViewController;
    [desVC setValue:self.uuid forKey:@"uuid"];
    [desVC setValue:self.modifyTask forKey:@"modifyTask"];
    [desVC setValue:[NSNumber numberWithInteger:self.modifyIndex] forKey:@"modifyIndex"];
    desVC.addTaskDelegate = self;
}


#pragma mark - Table Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.tasks) {
        return [self.tasks count];
    }
    else {
        return 0;
    }
}

#pragma mark - Table Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"taskProtoCellXib" forIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor clearColor]];
    NSDictionary *task = [self.tasks objectAtIndex:indexPath.row];
    cell.taskId = [task[@"id"] integerValue];
    if ([task[@"option"] integerValue] == 0) {
        cell.optionLabel.text = @"关闭";
    }
    else {
        cell.optionLabel.text = @"开启";
    }
    cell.excuteTime.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)[task[@"hour"] integerValue], (long)[task[@"minute"] integerValue]];
    NSInteger mask = 0x40;
    NSInteger taskRepeat = [task[@"weekday"] integerValue];
    NSString *repeatDay = [[NSString alloc] init];
    for (int i = 0; i < 7; i++) {
        if ((taskRepeat & mask) != 0) {
            repeatDay = [repeatDay stringByAppendingFormat:@"%@、", weekday[i]];
        }
        mask >>= 1;
    }
    if ([repeatDay length] > 0) {
        repeatDay = [repeatDay substringToIndex:repeatDay.length - 1];
    }
    
    cell.repeatDay.text = repeatDay;
    if ([task[@"active"] integerValue] == 0) {
        [cell.taskSwitch setOn:NO];
    }
    else {
        [cell.taskSwitch setOn:YES];
    }
    cell.taskIndex = indexPath.row;
    cell.modifyDelegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.modifyTask = [self.tasks objectAtIndex:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.modifyIndex = indexPath.row;
    [self performSegueWithIdentifier:@"TaskToAddTaskSegue" sender:self];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary * task = [self.tasks objectAtIndex:indexPath.row];
        NSInteger taskId = [[task objectForKey:@"id"] integerValue];
        [self.acFrame startAc];
        __weak TaskViewController *weakSelf = self;
        [self.client removeTask:taskId atIndex:indexPath.row success:^(NSURLSessionDataTask *task, id response) {
            [weakSelf.acFrame stopAc];
            if ([response[@"result"] isEqualToString:@"good"]) {
                weakSelf.tasks = [weakSelf.client getLocalTasks];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

@end
