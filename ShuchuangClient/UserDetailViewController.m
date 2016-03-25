//
//  UserDetailViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 3/24/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "UserDetailViewController.h"
#import "SCDeviceClient.h"
#import "SCDeviceManager.h"
#import "MyActivityIndicatorView.h"
#import "SCUtil.h"
#import "MyDatePickerView.h"

@interface UserDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UISlider *remainOpenSlide;
@property (weak, nonatomic) IBOutlet UILabel *remainOpenLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (strong, nonatomic) NSMutableDictionary* userInfo;
@property (strong, nonatomic) NSString* uuid;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segController;
@property (strong,  nonatomic) SCDeviceClient* client;
@property (strong, nonatomic) MyActivityIndicatorView* acFrame;
@property (strong, nonatomic) MyDatePickerView* datePicker;
@property (strong, nonatomic) NSDateComponents* dateComp;

- (void)onLeftButton;
- (void)onRightButton;
- (void)onDeleteButton;
- (void)onSlideValueChanged;
- (void)onSlideTouchUp;
- (void)onSegValueChanged;
- (void)onDateLabel;
@end

@implementation UserDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UINavigationItem *naviItem = [[UINavigationItem alloc] initWithTitle:@"修改用户"];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(onRightButton)];
    [leftButton setTintColor:[UIColor colorWithRed:1.0 green:129.0 / 255.0 blue:0 alpha:1]];
    [rightButton setTintColor:[UIColor colorWithRed:1.0 green:129.0 / 255.0 blue:0 alpha:1]];
    naviItem.leftBarButtonItem = leftButton;
    naviItem.rightBarButtonItem = rightButton;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    
    [self.remainOpenSlide addTarget:self action:@selector(onSlideValueChanged) forControlEvents:UIControlEventValueChanged];
    [self.remainOpenSlide addTarget:self action:@selector(onSlideTouchUp) forControlEvents:UIControlEventTouchUpInside];
    [self.segController addTarget:self action:@selector(onSegValueChanged) forControlEvents:UIControlEventValueChanged];
    if ([[self.userInfo objectForKey:@"remainopen"] integerValue] == -1) {
        [self.segController setSelectedSegmentIndex:1];
        [self.remainOpenSlide setValue:0.999];
        self.remainOpenSlide.enabled = NO;
        self.remainOpenLabel.text = @"999";
    }
    else {
        [self.segController setSelectedSegmentIndex:0];
        [self.remainOpenSlide setValue:[[self.userInfo objectForKey:@"remainopen"] integerValue] / 1000.0];
        self.remainOpenLabel.text = [NSString stringWithFormat:@"%ld", [[self.userInfo objectForKey:@"remainopen"] integerValue]];
        self.remainOpenSlide.enabled = YES;
    }
    
    [self.deleteButton setBackgroundColor:[UIColor colorWithRed:1.0 green:0.25 blue:0.25 alpha:1.0]];
    self.deleteButton.layer.cornerRadius = 5.0;
    [self.deleteButton addTarget:self action:@selector(onDeleteButton) forControlEvents:UIControlEventTouchUpInside];
    
    self.client = [[SCDeviceManager instance] getDevice:self.uuid];
    
    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];
    
    self.datePicker = [[MyDatePickerView alloc] initWithFrameInView:self.view];
    self.datePicker.datePickerDelegate = self;
    self.dateLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDateLabel)];
    [self.dateLabel addGestureRecognizer:tap];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlag = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
    NSInteger timestamp = [[self.userInfo objectForKey:@"timeofvalidity"] integerValue];
    NSDate* userDate = [NSDate dateWithTimeIntervalSince1970:timestamp / 1000000.0];
    self.dateComp = [calendar components:unitFlag fromDate:userDate];
    self.dateLabel.text = [self.userInfo objectForKey:@"timestring"];
    [self.datePicker setDate:userDate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onDatePickerOK:(NSDate *)pickedDate {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlag = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
    self.dateComp = [calendar components:unitFlag fromDate:pickedDate];
    self.dateLabel.text = [NSString stringWithFormat:@"%04ld-%02ld-%02ld", [self.dateComp year], [self.dateComp month], [self.dateComp day]];
    [self.userInfo setValue:self.dateLabel.text forKey:@"timestring"];
    NSInteger timestamp = [pickedDate timeIntervalSince1970] * 1000000;
    [self.userInfo setValue:[NSNumber numberWithInteger:timestamp] forKey:@"timeofvalidity"];
    [self.datePicker hidePicker];
}

- (void)onDatePickerCancel {
    [self.datePicker hidePicker];
}

- (void)onLeftButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onRightButton {
    NSDictionary *dict = @{@"username":self.userInfo[@"username"], @"remainopen":self.userInfo[@"remainopen"], @"timeofvalidity":self.userInfo[@"timeofvalidity"]};
    NSLog(@"%@", dict);
}

- (void)onDateLabel {
    [self.datePicker showPicker];
}

- (void)onDeleteButton {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否删除该用户" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action) {
        [self.acFrame startAc];
        [self.client deleteUser:[self.userInfo objectForKey:@"username"] success:^(NSURLSessionDataTask* task, id response) {
            [self.acFrame stopAc];
            if ([response[@"result"] isEqualToString:@"good"]) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else {
                [SCUtil viewController:self showAlertTitle:@"提示" message:response[@"detail"] action:nil];
            }
        } failure:^(NSURLSessionDataTask* task, NSError* error) {
            [self.acFrame stopAc];
            [SCUtil viewController:self showAlertTitle:@"提示" message:@"网络出错，请稍后再试" action:nil];
        }];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)onSlideValueChanged {
    NSInteger remainopen = [[NSNumber numberWithFloat:[self.remainOpenSlide value] * 1000] integerValue];
    self.remainOpenLabel.text = [NSString stringWithFormat:@"%ld", remainopen];
}

- (void)onSlideTouchUp {
    NSInteger remainopen = [[NSNumber numberWithFloat:[self.remainOpenSlide value] * 1000] integerValue];
    [self.userInfo setObject:[NSNumber numberWithInteger:remainopen] forKey:@"remainopen"];
}

- (void)onSegValueChanged {
    if ([self.segController selectedSegmentIndex] == 1) {
        self.remainOpenSlide.enabled = NO;
        [self.userInfo setObject:[NSNumber numberWithInteger:-1] forKey:@"remainopen"];
    }
    else {
        self.remainOpenSlide.enabled = YES;
        NSInteger remainopen = [[NSNumber numberWithFloat:[self.remainOpenSlide value] * 1000] integerValue];
        [self.userInfo setObject:[NSNumber numberWithInteger:remainopen] forKey:@"remainopen"];
    }
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
