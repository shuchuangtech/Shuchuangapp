//
//  RecordViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/25/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "RecordViewController.h"
#import "RPCDef.h"
#import "SCDeviceManager.h"
#import "SCDeviceClient.h"
#import "SCUtil.h"
#import "MyActivityIndicatorView.h"
#import "RecordTableViewCell.h"
#import "MJRefresh.h"
#import "SCDatePickerView.h"
#import "SCTextField.h"

@interface RecordViewController () <FSCalendarDelegate, FSCalendarDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *beginDate;
@property (weak, nonatomic) IBOutlet UILabel *endDate;
@property (weak, nonatomic) IBOutlet UILabel *beginTime;
@property (weak, nonatomic) IBOutlet UILabel *endTime;
@property (weak, nonatomic) IBOutlet UIView *beginView;
@property (weak, nonatomic) IBOutlet UIView *endView;
@property (weak, nonatomic) IBOutlet UIView *dateTimeContainer;
@property (weak, nonatomic) IBOutlet UIButton *upButton;
@property (weak, nonatomic) IBOutlet UIView *pickerContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pickerContainerHeight;
@property (weak, nonatomic) IBOutlet SCDatePickerView *datePicker;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *datePickerHeight;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet SCTextField *hourTextField;
@property (weak, nonatomic) IBOutlet SCTextField *minuteTextField;
@property (weak, nonatomic) IBOutlet UIButton *buttonTimeOK;
@property (nonatomic) BOOL beginSet;
@property (nonatomic) BOOL endSet;
@property (nonatomic) BOOL beginTimeSet;
@property (nonatomic) BOOL endTimeSet;
@property (strong, nonatomic) NSDateComponents *beginComp;
@property (strong, nonatomic) NSDateComponents *endComp;
@property (copy, nonatomic) NSString *uuid;
@property (strong, nonatomic) SCDeviceClient *client;
@property NSInteger datePickerTag;
@property (strong, nonatomic) NSMutableArray *records;
@property (strong, nonatomic) MyActivityIndicatorView *acFrame;
@property (nonatomic) CGFloat pickerOriginHeight;

- (void)onButtonTimeOK;
- (void)onUpButton;
- (void)onButtonSearch;
- (void)onBeginView;
- (void)onEndView;
- (void)onLeftButton;
- (void)loadMoreData;
@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //navi bar
    UINavigationItem *naviItem = [[UINavigationItem alloc] init];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    [leftButton setTintColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]];
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.naviBar.frame.size.width - 100, self.naviBar.frame.size.height)];
    [titleLab setText:@"记录查询"];
    [titleLab setTextColor:[UIColor colorWithRed:21.0 / 255.0 green:37.0 / 255.0 blue:50.0 / 255.0 alpha:1.0]];
    [titleLab setFont:[UIFont systemFontOfSize:17.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    naviItem.titleView = titleLab;
    naviItem.leftBarButtonItem = leftButton;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    
    //date components
    self.beginComp = [[NSDateComponents alloc] init];
    self.endComp = [[NSDateComponents alloc] init];
    
    self.beginSet = NO;
    self.endSet = NO;
    self.beginTimeSet = NO;
    self.endTimeSet = NO;
    //date
    UITapGestureRecognizer *gesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBeginView)];
    UITapGestureRecognizer *gesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onEndView)];
    [self.beginView addGestureRecognizer:gesture1];
    [self.endView addGestureRecognizer:gesture2];
    [self.beginDate setText:@"-/-/-"];
    [self.endDate setText:@"-/-/-"];
    
    //time
    [self.beginTime setText:@"-:-"];
    [self.endTime setText:@"-:-"];
    
    //client
    self.client = [[SCDeviceManager instance] getDevice:self.uuid];
    
    //records array
    self.records = [[NSMutableArray alloc] init];
    
    //ac frame
    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];
    
    //table view
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    [self.tableView registerNib:[UINib nibWithNibName:@"RecordTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"RecordTableViewCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    if ([self.records count] == 0) {
        self.tableView.scrollEnabled = NO;
    }
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    //picker view
    self.datePicker.pickDelegate = self;
    self.datePicker.pickDataSource = self;
    self.pickerContainer.clipsToBounds = YES;
    
    self.hourTextField.delegate = self;
    self.hourTextField.placeholder = @"00";
    self.minuteTextField.delegate = self;
    self.minuteTextField.placeholder = @"00";
    [self.buttonTimeOK addTarget:self action:@selector(onButtonTimeOK) forControlEvents:UIControlEventTouchUpInside];
    [self.upButton addTarget:self action:@selector(onUpButton) forControlEvents:UIControlEventTouchUpInside];
    self.searchButton.layer.cornerRadius = 15.0;
    self.searchButton.clipsToBounds = YES;
    [self.searchButton addTarget:self action:@selector(onButtonSearch) forControlEvents:UIControlEventTouchUpInside];
    
    self.hourTextField.lineColor = [UIColor colorWithRed:227.0 / 255.0 green:93.0 / 255.0 blue:93.0 / 255.0 alpha:1.0];
    self.minuteTextField.lineColor = [UIColor colorWithRed:227.0 / 255.0 green:93.0 / 255.0 blue:93.0 / 255.0 alpha:1.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadMoreData {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *beginDate = [calendar dateFromComponents:self.beginComp];
    NSDate *endDate = [calendar dateFromComponents:self.endComp];
    long long tt1 = [beginDate timeIntervalSince1970] * 1000000;
    long long tt2 = [endDate timeIntervalSince1970] * 1000000;
    NSDictionary *condition = @{RECORD_STARTTIME_STR:[NSNumber numberWithLongLong:tt1], RECORD_ENDTIME_STR:[NSNumber numberWithLongLong:tt2], RECORD_LIMIT_STR:[NSNumber numberWithInteger:10], RECORD_OFFSET_STR:[NSNumber numberWithInteger:[self.records count]]};
    __weak RecordViewController *weakSelf = self;
    [self.client getRecord:condition success:^(NSURLSessionDataTask *task, id response) {
        if ([response[@"result"] isEqualToString:@"good"]) {
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSUInteger unitFlag = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
            NSArray *responseRecords = response[@"records"];
            if ([responseRecords count] == 0) {
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            else {
                for (int i = 0; i < [responseRecords count]; i++) {
                    NSMutableDictionary *record = [[NSMutableDictionary alloc] initWithDictionary:[responseRecords objectAtIndex:i]];
                    long long timestamp = [record[@"Timestamp"] longLongValue];
                    NSTimeInterval timeInterval = timestamp / 1000000.0;
                    NSDateComponents *comp = [calendar components:unitFlag fromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
                    NSString *timeStr = [NSString stringWithFormat:@"%02ld/%02ld/%04ld %02ld:%02ld:%02ld", (long)[comp day], (long)[comp month], (long)[comp year], (long)[comp hour], (long)[comp minute], (long)[comp second]];
                    [record setObject:timeStr forKey:@"Timestamp"];
                    [weakSelf.records addObject:record];
                }
                [weakSelf.tableView reloadData];
                [weakSelf.tableView.mj_footer endRefreshing];
            }
        }
        else {
            [weakSelf.tableView.mj_footer endRefreshing];
            [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:response[@"detail"] action:nil];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakSelf.tableView.mj_footer endRefreshing];
        [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"网络错误，请稍后再试" action:nil];
    }];
}

- (void)onLeftButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onButtonSearch {
    [self.records removeAllObjects];
    if (!(self.beginSet && self.endSet && self.beginTimeSet && self.endTimeSet)) {
        [SCUtil viewController:self showAlertTitle:@"提示" message:@"请输入查询条件" action:nil];
        return;
    }
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *beginDate = [calendar dateFromComponents:self.beginComp];
    NSDate *endDate = [calendar dateFromComponents:self.endComp];
    long long tt1 = [beginDate timeIntervalSince1970] * 1000000;
    long long tt2 = [endDate timeIntervalSince1970] * 1000000;
    NSDictionary *condition = @{RECORD_STARTTIME_STR:[NSNumber numberWithLongLong:tt1], RECORD_ENDTIME_STR:[NSNumber numberWithLongLong:tt2], RECORD_LIMIT_STR:[NSNumber numberWithInteger:10], RECORD_OFFSET_STR:[NSNumber numberWithInteger:0]};
    [self.acFrame startAc];
    __weak RecordViewController *weakSelf = self;
    [self.client getRecord:condition success:^(NSURLSessionDataTask *task, id response) {
        if ([response[@"result"] isEqualToString:@"good"]) {
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSUInteger unitFlag = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
            NSArray *responseRecords = response[@"records"];
            for (int i = 0; i < [responseRecords count]; i++) {
                NSMutableDictionary *record = [[NSMutableDictionary alloc] initWithDictionary:[responseRecords objectAtIndex:i]];
                long long timestamp = [record[@"Timestamp"] longLongValue];
                NSTimeInterval timeInterval = timestamp / 1000000.0;
                NSDateComponents *comp = [calendar components:unitFlag fromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
                NSString *timeStr = [NSString stringWithFormat:@"%02ld/%02ld/%04ld %02ld:%02ld:%02ld", (long)[comp day], (long)[comp month], (long)[comp year], (long)[comp hour], (long)[comp minute], (long)[comp second]];
                [record setObject:timeStr forKey:@"Timestamp"];
                [weakSelf.records addObject:record];
            }
            if ([weakSelf.records count] > 0) {
                weakSelf.tableView.scrollEnabled = YES;
                [weakSelf.tableView reloadData];
            }
            else {
                [SCUtil viewController:self showAlertTitle:@"提示" message:@"没有查询到操作记录" action:nil];
                weakSelf.tableView.scrollEnabled = NO;
            }
            [weakSelf.acFrame stopAc];
            [weakSelf.tableView reloadData];
        }
        else {
            [weakSelf.acFrame stopAc];
            [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:response[@"detail"] action:nil];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakSelf.acFrame stopAc];
        [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"网络错误，请稍后再试" action:nil];
    }];
}

- (void)onBeginView {
    self.datePickerTag = 0;
    [self.beginDate setTextColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]];
    [self.endDate setTextColor:[UIColor colorWithRed:21.0 / 255.0 green:37.0 / 255.0 blue:50.0 / 255.0 alpha:1.0]];
    if (self.endSet) {
        NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        [self.datePicker.calendar deselectDate:[calendar dateFromComponents:self.endComp]];
    }
    if (self.beginSet) {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDate *beginDate = [calendar dateFromComponents:self.beginComp];
        [self.datePicker.calendar setCurrentPage:beginDate animated:NO];
        [self.datePicker.calendar selectDate:beginDate];
    }
    else {
        NSCalendar *cal = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        NSDate *today = [NSDate date];
        NSUInteger unitFlag = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
        NSDateComponents *comp = [cal components:unitFlag fromDate:today];
        self.beginDate.text = [NSString stringWithFormat:@"%02ld/%02ld/%04ld", (long)[comp day], (long)[comp month], (long)[comp year]];
        [self.beginComp setYear:[comp year]];
        [self.beginComp setMonth:[comp month]];
        [self.beginComp setDay:[comp day]];
        [self.datePicker.calendar selectDate:today];
        self.beginSet = YES;
        [self.datePicker.calendar setCurrentPage:[NSDate date] animated:NO];
    }
    [UIView animateWithDuration:0.5 animations:^ {
        [self.datePickerHeight setConstant:self.pickerOriginHeight];
        [self.pickerContainerHeight setConstant:(self.pickerOriginHeight + 70.0)];
        [self.view layoutIfNeeded];
    }];
}

- (void)onEndView {
    self.datePickerTag = 1;
    [self.endDate setTextColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]];
    [self.beginDate setTextColor:[UIColor colorWithRed:21.0 / 255.0 green:37.0 / 255.0 blue:50.0 / 255.0 alpha:1.0]];
    if (self.beginSet) {
        NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        [self.datePicker.calendar deselectDate:[calendar dateFromComponents:self.beginComp]];
    }
    if (self.endSet) {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDate *endDate = [calendar dateFromComponents:self.endComp];
        [self.datePicker.calendar setCurrentPage:endDate animated:NO];
        [self.datePicker.calendar selectDate:endDate];
    }
    else {
        NSCalendar *cal = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        NSDate *today = [NSDate date];
        NSUInteger unitFlag = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
        NSDateComponents *comp = [cal components:unitFlag fromDate:today];
        self.endDate.text = [NSString stringWithFormat:@"%02ld/%02ld/%04ld", (long)[comp day], (long)[comp month], (long)[comp year]];
        [self.endComp setYear:[comp year]];
        [self.endComp setMonth:[comp month]];
        [self.endComp setDay:[comp day]];
        [self.datePicker.calendar selectDate:today];
        self.endSet = YES;
        [self.datePicker.calendar setCurrentPage:[NSDate date] animated:NO];
    }
    [UIView animateWithDuration:0.5 animations:^ {
        [self.datePickerHeight setConstant:self.pickerOriginHeight];
        [self.pickerContainerHeight setConstant:(self.pickerOriginHeight + 70.0)];
        [self.view layoutIfNeeded];
    }];
}

- (void)onButtonTimeOK {
    self.beginTimeSet = (self.datePickerTag == 0)?NO:self.beginTimeSet;
    self.endTimeSet = (self.datePickerTag == 1)?NO:self.endTimeSet;
    if ([self.hourTextField.text length] == 0 || [self.minuteTextField.text length] == 0) {
        [SCUtil viewController:self showAlertTitle:@"提示" message:@"请输入查询时间" action:nil];
        return;
    }
    NSInteger hour = [self.hourTextField.text integerValue];
    NSInteger minute = [self.minuteTextField.text integerValue];
    if (!(hour <= 23 && hour >= 0 && minute <= 60 && minute >= 0)) {
        [SCUtil viewController:self showAlertTitle:@"提示" message:@"请输入正确的时间" action:nil];
        return;
    }
    else {
        if (self.datePickerTag == 0) {
            [self.beginComp setHour:hour];
            [self.beginComp setMinute:minute];
            self.beginTime.text = [NSString stringWithFormat:@"%ld:%02ld", (long)hour, (long)minute];
            self.beginTimeSet = YES;
        }
        else {
            [self.endComp setHour:[self.hourTextField.text integerValue]];
            [self.endComp setMinute:[self.minuteTextField.text integerValue]];
            self.endTime.text = [NSString stringWithFormat:@"%ld:%02ld", (long)hour, (long)minute];
            self.endTimeSet = YES;
        }
        self.hourTextField.text = @"";
        self.minuteTextField.text = @"";
        [self onUpButton];
    }
}

- (void)onUpButton {
    [UIView animateWithDuration:0.5 animations:^ {
        [self.pickerContainerHeight setConstant:0.0];
        [self.view layoutIfNeeded];
    }];
    if (self.datePickerTag == 0) {
        [self.beginDate setTextColor:[UIColor colorWithRed:21.0 / 255.0 green:37.0 / 255.0 blue:50.0 / 255.0 alpha:1.0]];
    }
    else {
        [self.endDate setTextColor:[UIColor colorWithRed:21.0 / 255.0 green:37.0 / 255.0 blue:50.0 / 255.0 alpha:1.0]];
    }
}

#pragma -mark Calendar delegate and datasource
- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated {
    if (animated) {
        [self.datePickerHeight setConstant:CGRectGetHeight(bounds)];
        [self.pickerContainerHeight setConstant:(CGRectGetHeight(bounds) + 70.0)];
        [self.view layoutIfNeeded];
    }
    else {
        self.pickerOriginHeight = CGRectGetHeight(bounds);
    }
}

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date {
    if (self.datePickerTag == 0 && self.endSet) {
        NSDateComponents *endCom = [[NSDateComponents alloc] init];
        [endCom setYear:[self.endComp year]];
        [endCom setMonth:[self.endComp month]];
        [endCom setDay:[self.endComp day]];
        NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDate *endDate = [cal dateFromComponents:endCom];
        if ([date compare:endDate] == NSOrderedDescending) {
            [SCUtil viewController:self showAlertTitle:@"提示" message:@"起始日期不能大于结束日期，请重新选择" action:nil];
            return NO;
        }
        else {
            return YES;
        }
    }
    else if (self.datePickerTag == 1 && self.beginSet){
        NSDateComponents *beginCom = [[NSDateComponents alloc] init];
        [beginCom setYear:[self.beginComp year]];
        [beginCom setMonth:[self.beginComp month]];
        [beginCom setDay:[self.beginComp day]];
        NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDate *beginDate = [cal dateFromComponents:beginCom];
        if ([beginDate compare:date] == NSOrderedDescending) {
            [SCUtil viewController:self showAlertTitle:@"提示" message:@"结束日期不能小于起始日期，请重新选择" action:nil];
            return NO;
        }
        else {
            return YES;
        }
    }
    else {
        return YES;
    }
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date {
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlag = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
    NSDateComponents *dateComponent = [cal components:unitFlag fromDate:date];
    if (self.datePickerTag == 0) {
        self.beginSet = YES;
        [self.beginComp setYear:[dateComponent year]];
        [self.beginComp setMonth:[dateComponent month]];
        [self.beginComp setDay:[dateComponent day]];
        [self.beginDate setText:[NSString stringWithFormat:@"%02ld/%02ld/%04ld", (long)[dateComponent day], (long)[dateComponent month], (long)[dateComponent year]]];
    }
    else {
        self.endSet = YES;
        [self.endComp setYear:[dateComponent year]];
        [self.endComp setMonth:[dateComponent month]];
        [self.endComp setDay:[dateComponent day]];
        [self.endDate setText:[NSString stringWithFormat:@"%02ld/%02ld/%04ld", (long)[dateComponent day], (long)[dateComponent month], (long)[dateComponent year]]];
    }

}

#pragma -mark textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma --mark tableview datasouce and delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.records count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecordTableViewCell"];
    [cell setBackgroundColor:[UIColor clearColor]];
    NSDictionary *record = [self.records objectAtIndex:indexPath.row];
    if ([[record objectForKey:@"Operation"] integerValue] == 0) {
        cell.optionLabel.text = @"设备上锁";
        [cell.lockImg setImage:[UIImage imageNamed:@"lock_on"]];
    }
    else {
        cell.optionLabel.text = @"设备解锁";
        [cell.lockImg setImage:[UIImage imageNamed:@"lock_off"]];
    }
    if ([[record objectForKey:@"Schema"] integerValue] == 0) {
        cell.userLabel.text = [record objectForKey:@"Username"];
    }
    else {
        cell.userLabel.text = @"定时任务";
    }
    cell.timeLabel.text = [record objectForKey:@"Timestamp"];
    if (indexPath.row == 0) {
        cell.topLine.hidden = YES;
    }
    else {
        cell.topLine.hidden = NO;
    }
    if (indexPath.row == [self.records count] - 1) {
        cell.bottomLine.hidden = YES;
    }
    else {
        cell.bottomLine.hidden = NO;
    }
    return cell;
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
