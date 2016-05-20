//
//  DeviceDetailViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 4/30/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "DeviceDetailViewController.h"
#import "SCDeviceClient.h"
#import "SCDeviceManager.h"
#import "DeviceDetailBottomView.h"
#import "MyActivityIndicatorView.h"
#import "SCUtil.h"
#import "AnimateLabel.h"

@interface DeviceDetailViewController ()
@property (weak, nonatomic) IBOutlet UIButton *swButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet AnimateLabel *label;
@property (strong, nonatomic) UIImageView *shutdownBg;
@property (strong ,nonatomic) UIImageView *turnonBg;
@property (weak, nonatomic) IBOutlet UILabel *taskLabel;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeight;

@property (weak, nonatomic) IBOutlet DeviceDetailBottomView *taskView;
@property (weak, nonatomic) IBOutlet DeviceDetailBottomView *recordView;
@property (weak, nonatomic) IBOutlet DeviceDetailBottomView *userView;
@property (weak, nonatomic) IBOutlet DeviceDetailBottomView *deviceView;
@property (copy, nonatomic) NSString *uuid;
@property (strong, nonatomic) SCDeviceClient *client;
@property (strong, nonatomic) MyActivityIndicatorView *acFrame;
@property (nonatomic) BOOL needRefresh;
@property (nonatomic) BOOL swClose;
- (void)onLeftButton;
- (void)onSwButton;
- (void)setSwitchOpen;
- (void)setSwitchClose;

- (void)onUserViewTouchUp;
- (void)onTaskViewTouchUp;
- (void)onRecordViewTouchUp;
- (void)onDeviceViewTouchUp;
@end

@implementation DeviceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.shutdownBg = [[UIImageView alloc] init];
    [self.shutdownBg setImage:[UIImage imageNamed:@"shutdownbg"]];
    [self.bgView addSubview:self.shutdownBg];
    self.turnonBg = [[UIImageView alloc] init];
    [self.turnonBg setImage:[UIImage imageNamed:@"turnonbg"]];
    [self.bgView addSubview:self.turnonBg];
    self.client = [[SCDeviceManager instance] getDevice:self.uuid];
    UINavigationItem *naviItem = [[UINavigationItem alloc] init];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.naviBar.frame.size.width - 200, self.naviBar.frame.size.height)];
    titleLabel.text = self.client.name;
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setFont:[UIFont systemFontOfSize:17.0]];
    naviItem.titleView = titleLabel;
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    [leftButton setTintColor:[UIColor whiteColor]];
    naviItem.leftBarButtonItem = leftButton;
    [self.naviBar pushNavigationItem:naviItem animated:YES];
    [self.naviBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsCompact];
    self.naviBar.clipsToBounds = YES;
    
    //bottom view
    [self.userView setTopLine:YES bottomLine:NO leftLine:NO rightLine:YES];
    [self.taskView setTopLine:NO bottomLine:YES leftLine:NO rightLine:YES];
    [self.recordView setTopLine:NO bottomLine:YES leftLine:YES rightLine:NO];
    [self.deviceView setTopLine:YES bottomLine:NO leftLine:YES rightLine:NO];
    [self.userView addTarget:self action:@selector(onUserViewTouchUp) forControlEvents:UIControlEventTouchUpInside];
    [self.taskView addTarget:self action:@selector(onTaskViewTouchUp) forControlEvents:UIControlEventTouchUpInside];
    [self.recordView addTarget:self action:@selector(onRecordViewTouchUp) forControlEvents:UIControlEventTouchUpInside];
    [self.deviceView addTarget:self action:@selector(onDeviceViewTouchUp) forControlEvents:UIControlEventTouchUpInside];
    
    self.needRefresh = YES;
    
    [self.swButton addTarget:self action:@selector(onSwButton) forControlEvents:UIControlEventTouchUpInside];
    
    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.turnonBg setFrame:self.bgView.frame];
    [self.shutdownBg setFrame:self.bgView.frame];
    CGSize iOSDeviceScreenSize = [UIScreen mainScreen].bounds.size;
    if (iOSDeviceScreenSize.height == 480) {
        [self.bottomViewHeight setConstant:65.0];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self.acFrame startAc];
        __weak DeviceDetailViewController *weakSelf = self;
        [self.client checkDoorSuccess:^(NSURLSessionDataTask *task, id response) {
            [weakSelf.acFrame stopAc];
            if ([response[@"result"] isEqualToString:@"good"]) {
                if (weakSelf.client.switchClose) {
                    [weakSelf setSwitchClose];
                }
                else {
                    [weakSelf setSwitchOpen];
                }
            }
            else {
                [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:response[@"detail"] action:nil];
            }
            
        }
        failure:^(NSURLSessionDataTask *task, NSError *error) {
            [weakSelf.acFrame stopAc];
            [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"网络错误，获取设备状态失败" action:nil];
        }];
    }
    else {
        if (self.client.switchClose) {
            [self setSwitchClose];
        }
        else {
            [self setSwitchOpen];
        }
    }
    //task label
    NSCalendar *calender = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit unitFlasg = NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitWeekday;
    NSDate *now = [NSDate date];
    NSDateComponents *nowDateComp = [calender components:unitFlasg fromDate:now];
    NSArray *array = [self.client getLocalTasks];
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

//bottom view control events
#pragma - mark bottom view control events
- (void)onUserViewTouchUp {
    [self.userView setViewHighlighted:NO];
    [self performSegueWithIdentifier:@"DetailToUserSegue" sender:self];
}

- (void)onTaskViewTouchUp {
    [self.taskView setViewHighlighted:NO];
    [self performSegueWithIdentifier:@"DetailToTaskSegue" sender:self];
}

- (void)onRecordViewTouchUp {
    [self.recordView setViewHighlighted:NO];
    [self performSegueWithIdentifier:@"DetailToRecordSegue" sender:self];
}

- (void)onDeviceViewTouchUp {
    [self.deviceView setViewHighlighted:NO];
    [self performSegueWithIdentifier:@"DetailToDeviceSegue" sender:self];
}


- (void)onLeftButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onSwButton {
    [self.acFrame startAc];
    __weak DeviceDetailViewController *weakSelf = self;
    if (self.swClose) {
        [self.client openDoorSuccess:^(NSURLSessionDataTask *task, id response) {
            [weakSelf.acFrame stopAc];
            if ([response[@"result"] isEqualToString:@"good"]) {
                [weakSelf setSwitchOpen];
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
        [self.client closeDoorSuccess:^(NSURLSessionDataTask *task, id response) {
            [weakSelf.acFrame stopAc];
            if ([response[@"result"] isEqualToString:@"good"]) {
                [weakSelf setSwitchClose];
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

- (void)setSwitchOpen {
    [self.bgView sendSubviewToBack:self.shutdownBg];
    [self.swButton setImage:[UIImage imageNamed:@"turnon"] forState:UIControlStateNormal];
    self.swClose = NO;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"当前为解锁状态，点击锁定"];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0] range:NSMakeRange(10, 2)];
    [self.label changeLabelText:str];
}

- (void)setSwitchClose {
    [self.bgView sendSubviewToBack:self.turnonBg];
    [self.swButton setImage:[UIImage imageNamed:@"shutdown"] forState:UIControlStateNormal];
    self.swClose = YES;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"当前为锁定状态，点击解锁"];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:32.0 / 255.0 green:221.0 / 255.0 blue:153.0 / 255.0 alpha:1.0] range:NSMakeRange(10, 2)];
    [self.label changeLabelText:str];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    id desVC = segue.destinationViewController;
    [desVC setValue:self.uuid forKey:@"uuid"];
}


@end
