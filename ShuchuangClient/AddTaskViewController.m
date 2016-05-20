//
//  AddTaskViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 3/2/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "AddTaskViewController.h"
#import "UIButton+FillBackgroundImage.h"
#import "SCDeviceManager.h"
#import "SCDeviceClient.h"
#import "MyActivityIndicatorView.h"
#import "SCUtil.h"
#import "AddTaskRepeatCell.h"
#import "AddTaskOptionCell.h"
#import "SCTimePickerView.h"
@interface AddTaskViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (strong, nonatomic) NSString *uuid;
@property (strong, nonatomic) NSDictionary *modifyTask;
@property NSInteger modifyIndex;
@property NSInteger pickerHour;
@property NSInteger pickerMinute;
@property NSInteger weekday;
@property NSInteger option;
@property (strong, nonatomic) SCDeviceClient *client;
@property (strong, nonatomic) MyActivityIndicatorView *acFrame;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet SCTimePickerView *timePicker;

- (void)onLeftButton;
- (void)onRightButton;
@end

@implementation AddTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //navi bar
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, self.naviBar.frame.size.width - 100, self.naviBar.frame.size.height - 2)];
    [titleLab setTextColor:[UIColor colorWithRed:21.0 / 255.0 green:37.0 / 255.0 blue:50.0 / 255.0 alpha:1.0]];
    [titleLab setFont:[UIFont systemFontOfSize:17.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    if (self.modifyTask == nil) {
        [titleLab setText:@"添加任务"];
    }
    else {
        [titleLab setText:@"修改任务"];
    }
    UINavigationItem *naviItem = [[UINavigationItem alloc] init];
    naviItem.titleView = titleLab;
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"  取消" style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"完成  " style:UIBarButtonItemStylePlain target:self action:@selector(onRightButton)];
    [leftButton setTintColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]];
    [rightButton setTintColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]];
    naviItem.leftBarButtonItem = leftButton;
    naviItem.rightBarButtonItem = rightButton;
    [self.naviBar pushNavigationItem:naviItem animated:NO];

    //task info variables
    if (self.modifyTask) {
        self.option = [self.modifyTask[@"option"] integerValue];
        self.pickerHour = [self.modifyTask[@"hour"] integerValue];
        self.pickerMinute = [self.modifyTask[@"minute"] integerValue];
        self.weekday = [self.modifyTask[@"weekday"] integerValue];
    }
    else {
        self.option = 0;
        self.pickerHour = 0;
        self.pickerMinute = 0;
        self.weekday = 0;
    }
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView registerNib:[UINib nibWithNibName:@"AddTaskRepeatCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"AddTaskRepeatCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"AddTaskOptionCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"AddTaskOptionCell"];
    //SCDeviceClient
    self.client = [[SCDeviceManager instance] getDevice:self.uuid];
    
    //ac frame
    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];
    
    [self.timePicker setPickedHour:self.pickerHour minute:self.pickerMinute];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onLeftButton {
    [self.addTaskDelegate cancelAdd];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onRightButton {
    if (self.weekday == 0) {
        [SCUtil viewController:self showAlertTitle:@"提示" message:@"请选择任务重复时间" action:nil];
        return;
    }
    self.pickerHour = [self.timePicker getPickedHour];
    self.pickerMinute = [self.timePicker getPickedMinute];
    if (self.modifyTask == nil) {
        NSDictionary *task = @{@"option" : [NSNumber numberWithInteger:self.option], @"hour" : [NSNumber numberWithInteger:self.pickerHour], @"minute" : [NSNumber numberWithInteger:self.pickerMinute], @"weekday" : [NSNumber numberWithInteger:self.weekday], @"active" : [NSNumber numberWithInt:0]};
        [self.acFrame startAc];
        __weak AddTaskViewController *blockSelf = self;
        [self.client addTask:task success:^(NSURLSessionDataTask *task, id response) {
            [blockSelf.acFrame stopAc];
            if (![response[@"result"] isEqualToString:@"good"]) {
                [SCUtil viewController:blockSelf showAlertTitle:@"提示" message:response[@"detail"] action:^(UIAlertAction *action) {
                    [blockSelf dismissViewControllerAnimated:YES completion:nil];
                }];
            }
            else {
                [blockSelf.addTaskDelegate finishAdd];
                [blockSelf dismissViewControllerAnimated:YES completion:nil];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [blockSelf.acFrame stopAc];
            [SCUtil viewController:blockSelf showAlertTitle:@"提示" message:@"网络错误，请稍后再试" action:^(UIAlertAction *action) {
                [blockSelf dismissViewControllerAnimated:YES completion:nil];
            }];
        }];
    }
    else {
        NSDictionary *task = @{@"id":self.modifyTask[@"id"], @"option" : [NSNumber numberWithInteger:self.option], @"hour" : [NSNumber numberWithInteger:self.pickerHour], @"minute" : [NSNumber numberWithInteger:self.pickerMinute], @"weekday" : [NSNumber numberWithInteger:self.weekday], @"active" : self.modifyTask[@"active"]};
        [self.acFrame startAc];
        __weak AddTaskViewController *blockSelf = self;
        [self.client updateTask:task atIndex:self.modifyIndex success:^(NSURLSessionDataTask *task, id response) {
            [blockSelf.acFrame stopAc];
            if (![response[@"result"] isEqualToString:@"good"]) {
                [SCUtil viewController:blockSelf showAlertTitle:@"提示" message:response[@"detail"] action:^(UIAlertAction *action) {
                    [blockSelf dismissViewControllerAnimated:YES completion:nil];
                }];
            }
            else {
                [blockSelf.addTaskDelegate finishAdd];
                [blockSelf dismissViewControllerAnimated:YES completion:nil];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [blockSelf.acFrame stopAc];
            [SCUtil viewController:blockSelf showAlertTitle:@"提示" message:@"网络错误，请稍后再试" action:^(UIAlertAction *action) {
                [blockSelf dismissViewControllerAnimated:YES completion:nil];
            }];
        }];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 90.0;
    }
    else {
        return 44.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        AddTaskRepeatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddTaskRepeatCell" forIndexPath:indexPath];
        cell.editDelegate = self;
        [cell initCellRepeatDay:self.weekday];
        return cell;
    }
    else if (indexPath.row == 1) {
        AddTaskOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddTaskOptionCell" forIndexPath:indexPath];
        cell.editDelegate = self;
        [cell initCellOption:self.option];
        return cell;
    }
    return nil;
}

- (void)repeatChangedTo:(NSInteger)repeat {
    self.weekday = repeat;
}

- (void)optionChangedTo:(NSInteger)option {
    self.option = option;
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
