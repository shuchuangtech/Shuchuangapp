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
#import "MyDatePickerView.h"
#import "MyTimePickerView.h"

@interface RecordViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *beginDate;
@property (weak, nonatomic) IBOutlet UILabel *endDate;
@property (weak, nonatomic) IBOutlet UILabel *beginTime;
@property (weak, nonatomic) IBOutlet UILabel *endTime;
@property (strong, nonatomic) MyDatePickerView* datePicker;
@property (strong, nonatomic) MyTimePickerView* timePicker;
@property (strong, nonatomic) NSDateComponents *beginComp;
@property (strong, nonatomic) NSDateComponents *endComp;
@property (strong, nonatomic) NSString *uuid;
@property (strong, nonatomic) SCDeviceClient *client;
@property NSInteger datePickerTag;
@property NSInteger timePickerTag;
@property (strong, nonatomic) NSMutableArray *records;
@property (strong, nonatomic) MyActivityIndicatorView *acFrame;

- (IBAction)onButtonSearch:(id)sender;
- (void)onDateLabelBegin:(id)sender;
- (void)onDateLabelEnd:(id)sender;
- (void)onTimeLabelBegin:(id)sender;
- (void)onTimeLabelEnd:(id)sender;
- (void)onLeftButton;
- (void)loadMoreData;
@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //navi bar
    UINavigationItem *naviItem = [[UINavigationItem alloc] initWithTitle:@"记录查询"];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    [leftButton setTintColor:[UIColor colorWithRed:1.0 green:129.0 / 255.0 blue:0 alpha:1]];
    naviItem.leftBarButtonItem = leftButton;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    
    //picker view
    self.datePicker = [[MyDatePickerView alloc] initWithFrameInView:self.view];
    self.datePicker.datePickerDelegate = self;
    self.timePicker = [[MyTimePickerView alloc] initWithFrameInView:self.view];
    self.timePicker.timePickerDelegate = self;
    
    //date components
    self.beginComp = [[NSDateComponents alloc] init];
    self.endComp = [[NSDateComponents alloc] init];
    
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlag = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute;
    NSDateComponents *dateComponent = [calendar components:unitFlag fromDate:nowDate];
    NSInteger year = [dateComponent year];
    NSInteger month = [dateComponent month];
    NSInteger day = [dateComponent day];
    NSInteger hour = [dateComponent hour];
    NSInteger minute = [dateComponent minute];
    [self.beginComp setYear:year];
    [self.endComp setYear:year];
    [self.beginComp setMonth:month];
    [self.endComp setMonth:month];
    [self.beginComp setDay:day];
    [self.endComp setDay:day];
    [self.beginComp setHour:hour];
    [self.endComp setHour:hour];
    [self.beginComp setMinute:minute];
    [self.endComp setMinute:minute];
    
    //date
    self.beginDate.userInteractionEnabled = YES;
    self.endDate.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDateLabelBegin:)];
    UITapGestureRecognizer *gesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDateLabelEnd:)];
    [self.beginDate addGestureRecognizer:gesture1];
    [self.endDate addGestureRecognizer:gesture2];
    [self.beginDate setText:[NSString stringWithFormat:@"%04ld-%02ld-%02ld", year, month, day]];
    [self.endDate setText:[NSString stringWithFormat:@"%04ld-%02ld-%02ld", year, month, day]];
    
    //time
    self.beginTime.userInteractionEnabled = YES;
    self.endTime.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTimeLabelBegin:)];
    UITapGestureRecognizer *gesture4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTimeLabelEnd:)];
    [self.beginTime addGestureRecognizer:gesture3];
    [self.endTime addGestureRecognizer:gesture4];
    [self.beginTime setText:[NSString stringWithFormat:@"%02ld:%02ld", hour, minute]];
    [self.endTime setText:[NSString stringWithFormat:@"%02ld:%02ld", hour, minute]];
    
    //client
    self.client = [[SCDeviceManager instance] getDevice:self.uuid];
    
    //records array
    self.records = [[NSMutableArray alloc] init];
    
    //ac frame
    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];
    
    //table view
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"RecordTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"RecordTableViewCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    if ([self.records count] == 0) {
        self.tableView.scrollEnabled = NO;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadMoreData {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *beginDate = [calendar dateFromComponents:self.beginComp];
    NSDate *endDate = [calendar dateFromComponents:self.endComp];
    NSInteger tt1 = [beginDate timeIntervalSince1970] * 1000000;
    NSInteger tt2 = [endDate timeIntervalSince1970] * 1000000;
    NSDictionary *condition = @{RECORD_STARTTIME_STR:[NSNumber numberWithInteger:tt1], RECORD_ENDTIME_STR:[NSNumber numberWithInteger:tt2], RECORD_LIMIT_STR:[NSNumber numberWithInteger:10], RECORD_OFFSET_STR:[NSNumber numberWithInteger:[self.records count]]};
    [self.client getRecord:condition success:^(NSURLSessionDataTask *task, id response) {
        if ([response[@"result"] isEqualToString:@"good"]) {
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSUInteger unitFlag = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
            NSArray *responseRecords = response[@"records"];
            if ([responseRecords count] == 0) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            else {
                for (int i = 0; i < [responseRecords count]; i++) {
                    NSMutableDictionary *record = [[NSMutableDictionary alloc] initWithDictionary:[responseRecords objectAtIndex:i]];
                    NSInteger timestamp = [record[@"Timestamp"] integerValue];
                    NSTimeInterval timeInterval = timestamp / 1000000.0;
                    NSDateComponents *comp = [calendar components:unitFlag fromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
                    NSString *timeStr = [NSString stringWithFormat:@"%04ld-%02ld-%02ld %02ld:%02ld:%02ld", [comp year], [comp month], [comp day], [comp hour], [comp minute], [comp second]];
                    [record setObject:timeStr forKey:@"Timestamp"];
                    [self.records addObject:record];
                }
                [self.tableView reloadData];
                [self.tableView.mj_footer endRefreshing];
            }
        }
        else {
            [self.tableView.mj_footer endRefreshing];
            [SCUtil viewController:self showAlertTitle:@"提示" message:response[@"detail"] action:nil];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self.tableView.mj_footer endRefreshing];
        [SCUtil viewController:self showAlertTitle:@"提示" message:@"网络错误，请稍后再试" action:nil];
    }];
}

- (void)onLeftButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onDatePickerOK:(NSDate*)pickedDate {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlag = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
    NSDateComponents *dateComponent = [calendar components:unitFlag fromDate:pickedDate];
    if (self.datePickerTag == 0) {
        [self.beginComp setYear:[dateComponent year]];
        [self.beginComp setMonth:[dateComponent month]];
        [self.beginComp setDay:[dateComponent day]];
        [self.beginDate setText:[NSString stringWithFormat:@"%04ld-%02ld-%02ld", [dateComponent year], [dateComponent month], [dateComponent day]]];
    }
    else {
        [self.endComp setYear:[dateComponent year]];
        [self.endComp setMonth:[dateComponent month]];
        [self.endComp setDay:[dateComponent day]];
        [self.endDate setText:[NSString stringWithFormat:@"%04ld-%02ld-%02ld", [dateComponent year], [dateComponent month], [dateComponent day]]];
    }
    [self.datePicker hidePicker];
}

- (void)onDatePickerCancel {
    [self.datePicker hidePicker];
}

- (void)onTimePickerOKHour:(NSInteger)hour minute:(NSInteger)minute {
    if (self.timePickerTag == 0) {
        [self.beginComp setHour:hour];
        [self.beginComp setMinute:minute];
        [self.beginTime setText:[NSString stringWithFormat:@"%02ld:%02ld", hour, minute]];
    }
    else {
        [self.endComp setHour:hour];
        [self.endComp setMinute:minute];
        [self.endTime setText:[NSString stringWithFormat:@"%02ld:%02ld", hour, minute]];
    }
    [self.timePicker hidePicker];
}

- (void)onTimePickerCancel {
    [self.timePicker hidePicker];
}

- (IBAction)onButtonSearch:(id)sender {
    [self.records removeAllObjects];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *beginDate = [calendar dateFromComponents:self.beginComp];
    NSDate *endDate = [calendar dateFromComponents:self.endComp];
    NSInteger tt1 = [beginDate timeIntervalSince1970] * 1000000;
    NSInteger tt2 = [endDate timeIntervalSince1970] * 1000000;
    NSDictionary *condition = @{RECORD_STARTTIME_STR:[NSNumber numberWithInteger:tt1], RECORD_ENDTIME_STR:[NSNumber numberWithInteger:tt2], RECORD_LIMIT_STR:[NSNumber numberWithInteger:10], RECORD_OFFSET_STR:[NSNumber numberWithInteger:0]};
    [self.acFrame startAc];
    [self.client getRecord:condition success:^(NSURLSessionDataTask *task, id response) {
        if ([response[@"result"] isEqualToString:@"good"]) {
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSUInteger unitFlag = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
            NSArray *responseRecords = response[@"records"];
            for (int i = 0; i < [responseRecords count]; i++) {
                NSMutableDictionary *record = [[NSMutableDictionary alloc] initWithDictionary:[responseRecords objectAtIndex:i]];
                NSInteger timestamp = [record[@"Timestamp"] integerValue];
                NSTimeInterval timeInterval = timestamp / 1000000.0;
                NSDateComponents *comp = [calendar components:unitFlag fromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
                NSString *timeStr = [NSString stringWithFormat:@"%04ld-%02ld-%02ld %02ld:%02ld:%02ld", [comp year], [comp month], [comp day], [comp hour], [comp minute], [comp second]];
                [record setObject:timeStr forKey:@"Timestamp"];
                [self.records addObject:record];
            }
            if ([self.records count] > 0) {
                self.tableView.scrollEnabled = YES;
                [self.tableView reloadData];
            }
            else {
                self.tableView.scrollEnabled = NO;
            }
            [self.acFrame stopAc];
            [self.tableView reloadData];
        }
        else {
            [self.acFrame stopAc];
            [SCUtil viewController:self showAlertTitle:@"提示" message:response[@"detail"] action:nil];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self.acFrame stopAc];
        [SCUtil viewController:self showAlertTitle:@"提示" message:@"网络错误，请稍后再试" action:nil];
    }];
}

#pragma --mark on time buttons
- (void)onDateLabelBegin:(id)sender {
    self.datePickerTag = 0;
    [self.datePicker showPicker];
}

- (void)onDateLabelEnd:(id)sender {
    self.datePickerTag = 1;
    [self.datePicker showPicker];
}

- (void)onTimeLabelBegin:(id)sender {
    self.timePickerTag = 0;
    [self.timePicker showPicker];
}

- (void)onTimeLabelEnd:(id)sender {
    self.timePickerTag = 1;
    [self.timePicker showPicker];
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
    NSDictionary *record = [self.records objectAtIndex:indexPath.row];
    if ([[record objectForKey:@"Operation"] integerValue] == 0) {
        cell.optionLabel.text = @"关闭";
    }
    else {
        cell.optionLabel.text = @"开启";
    }
    if ([[record objectForKey:@"Schema"] integerValue] == 0) {
        cell.userLabel.text = [record objectForKey:@"Username"];
    }
    else {
        cell.userLabel.text = @"定时任务";
    }
    cell.timeLabel.text = [record objectForKey:@"Timestamp"];
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
