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

@interface UserDetailViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UISlider *remainOpenSlide;
@property (weak, nonatomic) IBOutlet UILabel *remainOpenLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (copy, nonatomic) NSDictionary* userInfo;
@property (strong, nonatomic) NSMutableDictionary *modifyUserInfo;
@property (weak, nonatomic) NSString* uuid;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segController;
@property (weak,  nonatomic) SCDeviceClient* client;
@property (strong, nonatomic) MyActivityIndicatorView* acFrame;
@property (strong, nonatomic) MyDatePickerView* datePicker;
@property (strong, nonatomic) NSDateComponents* dateComp;
@property (strong, nonatomic) UIImageView *barBg;
@property (strong, nonatomic) UIImageView *bgView;
@property (strong, nonatomic) UIImageView *textFieldBg;

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
    UINavigationItem *naviItem = [[UINavigationItem alloc] init];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(onRightButton)];
    [leftButton setTintColor:[UIColor whiteColor]];
    [rightButton setTintColor:[UIColor whiteColor]];
    naviItem.leftBarButtonItem = leftButton;
    naviItem.rightBarButtonItem = rightButton;
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.naviBar.frame.size.width - 100, self.naviBar.frame.size.height)];
    [titleLab setText:@"修改用户"];
    [titleLab setTextColor:[UIColor whiteColor]];
    [titleLab setFont:[UIFont systemFontOfSize:17.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    naviItem.titleView = titleLab;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    [self.naviBar setBackgroundImage:[UIImage imageNamed:@"barBg"] forBarMetrics:UIBarMetricsCompact];
    
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
        self.remainOpenLabel.text = [NSString stringWithFormat:@"%ld", (long)[[self.userInfo objectForKey:@"remainopen"] integerValue]];
        self.remainOpenSlide.enabled = YES;
    }
    self.modifyUserInfo = [[NSMutableDictionary alloc] initWithDictionary:self.userInfo];
    
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
    
    self.textField.delegate = self;
    [self.textField setBackgroundColor:[UIColor clearColor]];
    
    self.barBg = [[UIImageView alloc] init];
    [self.barBg setImage:[UIImage imageNamed:@"barBg"]];
    [self.view addSubview:self.barBg];
    [self.view bringSubviewToFront:self.naviBar];
    self.bgView = [[UIImageView alloc] init];
    [self.bgView setImage:[UIImage imageNamed:@"background"]];
    [self.view addSubview:self.bgView];
    [self.view sendSubviewToBack:self.bgView];
    
    self.textFieldBg = [[UIImageView alloc] initWithFrame:self.textField.frame];
    [self.textFieldBg setImage:[UIImage imageNamed:@"textFieldBg_small"]];
    [self.textField addSubview:self.textFieldBg];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.barBg setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.naviBar.frame.size.height + self.naviBar.frame.origin.y)];
    [self.bgView setFrame:CGRectMake(0, self.barBg.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.barBg.frame.size.height)];
    [self.textFieldBg setFrame:CGRectMake(0, 0, self.textField.frame.size.width, self.textField.frame.size.height)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onDatePickerOK:(NSDate *)pickedDate {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlag = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
    self.dateComp = [calendar components:unitFlag fromDate:pickedDate];
    self.dateLabel.text = [NSString stringWithFormat:@"%04ld-%02ld-%02ld", (long)[self.dateComp year], (long)[self.dateComp month], (long)[self.dateComp day]];
    [self.modifyUserInfo setValue:self.dateLabel.text forKey:@"timestring"];
    NSInteger timestamp = [pickedDate timeIntervalSince1970] * 1000000;
    [self.modifyUserInfo setValue:[NSNumber numberWithInteger:timestamp] forKey:@"timeofvalidity"];
    [self.datePicker hidePicker];
}

- (void)onDatePickerCancel {
    [self.datePicker hidePicker];
}

- (void)onLeftButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onRightButton {
    NSDictionary *dict = @{@"username":self.modifyUserInfo[@"username"], @"remainopen":self.modifyUserInfo[@"remainopen"], @"timeofvalidity":self.modifyUserInfo[@"timeofvalidity"]};
    [self.acFrame startAc];
    __weak UserDetailViewController *weakSelf = self;
    [self.client topupUser:dict success:^(NSURLSessionDataTask* task, id response) {
        [weakSelf.acFrame stopAc];
        if ([response[@"result"] isEqualToString:@"good"]) {
            [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"修改用户门禁使用权限成功" action:^(UIAlertAction* action) {
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }];
        }
        else {
            [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:response[@"detail"] action:^(UIAlertAction* action) {
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }];
        }
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        [weakSelf.acFrame stopAc];
        [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"网络错误，请稍后再试" action:nil];
    }];
}

- (void)onDateLabel {
    [self.datePicker showPicker];
}

- (void)onDeleteButton {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否删除该用户" preferredStyle:UIAlertControllerStyleAlert];
    __weak UserDetailViewController *weakSelf = self;
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action) {
        [weakSelf.acFrame startAc];
        [weakSelf.client deleteUser:[weakSelf.userInfo objectForKey:@"username"] success:^(NSURLSessionDataTask* task, id response) {
            [weakSelf.acFrame stopAc];
            if ([response[@"result"] isEqualToString:@"good"]) {
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }
            else {
                [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:response[@"detail"] action:nil];
            }
        } failure:^(NSURLSessionDataTask* task, NSError* error) {
            [weakSelf.acFrame stopAc];
            [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"网络出错，请稍后再试" action:nil];
        }];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)onSlideValueChanged {
    NSInteger remainopen = [[NSNumber numberWithFloat:[self.remainOpenSlide value] * 1000] integerValue];
    self.remainOpenLabel.text = [NSString stringWithFormat:@"%ld", (long)remainopen];
}

- (void)onSlideTouchUp {
    NSInteger remainopen = [[NSNumber numberWithFloat:[self.remainOpenSlide value] * 1000] integerValue];
    [self.modifyUserInfo setValue:[NSNumber numberWithInteger:remainopen] forKey:@"remainopen"];
    self.textField.text = [NSString stringWithFormat:@"%ld", (long)remainopen];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField.text.length != 0) {
        NSInteger remainopen = [textField.text integerValue];
        [self.remainOpenSlide setValue:remainopen / 1000.0];
        self.remainOpenLabel.text = [NSString stringWithFormat:@"%ld", (long)remainopen];
        [self.modifyUserInfo setValue:[NSNumber numberWithInteger:remainopen] forKey:@"remainopen"];
    }
    return YES;
}

- (void)onSegValueChanged {
    if ([self.segController selectedSegmentIndex] == 1) {
        self.textField.enabled = NO;
        [self.textField setBackgroundColor:[UIColor lightGrayColor]];
        self.remainOpenSlide.enabled = NO;
        [self.modifyUserInfo setObject:[NSNumber numberWithInteger:-1] forKey:@"remainopen"];
    }
    else {
        self.remainOpenSlide.enabled = YES;
        self.textField.enabled = YES;
        [self.textField setBackgroundColor:[UIColor clearColor]];
        NSInteger remainopen = [[NSNumber numberWithFloat:[self.remainOpenSlide value] * 1000] integerValue];
        [self.modifyUserInfo setObject:[NSNumber numberWithInteger:remainopen] forKey:@"remainopen"];
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
