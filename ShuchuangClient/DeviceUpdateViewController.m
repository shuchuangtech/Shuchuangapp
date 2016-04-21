//
//  DeviceUpdateViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 3/26/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "DeviceUpdateViewController.h"
#import "SCDeviceClient.h"
#import "SCDeviceManager.h"
#import "MyActivityIndicatorView.h"
#import "SCUtil.h"
#import "UpdateTableViewCell.h"
@interface DeviceUpdateViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (copy, nonatomic) NSString* uuid;
@property (strong, nonatomic) SCDeviceClient* client;
@property (nonatomic) BOOL deviceCheckFinish;
@property (nonatomic) BOOL serverCheckFinish;
@property (strong, nonatomic) MyActivityIndicatorView* acFrame;
@property (strong, nonatomic) NSDictionary* deviceVersion;
@property (strong, nonatomic) NSDictionary* serverVersion;
@property (nonatomic) BOOL isSelected;
@property (nonatomic) BOOL canOpen;
@property (strong, nonatomic) UILabel* featureLabel;
@property (strong, nonatomic) UIImageView *barBg;
@property (strong, nonatomic) UIImageView *bgView;
- (void)onLeftButton;
- (void)checkDeviceVersion;
- (void)checkServerVersion;
- (void)onButtonUpdate;
@end

@implementation DeviceUpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UINavigationItem *naviItem = [[UINavigationItem alloc] init];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    [leftButton setTintColor:[UIColor whiteColor]];
    naviItem.leftBarButtonItem = leftButton;
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.naviBar.frame.size.width - 100, self.naviBar.frame.size.height)];
    [titleLab setText:@"检查更新"];
    [titleLab setTextColor:[UIColor whiteColor]];
    [titleLab setFont:[UIFont systemFontOfSize:17.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    naviItem.titleView = titleLab;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    [self.naviBar setBackgroundImage:[UIImage imageNamed:@"barBg"] forBarMetrics:UIBarMetricsCompact];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    self.client = [[SCDeviceManager instance] getDevice:self.uuid];
    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];
    self.isSelected = NO;
    self.featureLabel = [[UILabel alloc] init];
    [self.tableView registerNib:[UINib nibWithNibName:@"UpdateTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"UpdateTableViewCell"];
    
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
    [self.barBg setFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    [self.bgView setFrame:CGRectMake(0, self.barBg.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.barBg.frame.size.height)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)onLeftButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onButtonUpdate {
    [self.acFrame startAc];
    __weak DeviceUpdateViewController *weakSelf = self;
    [self.client updateDeviceTo:self.serverVersion[@"version"] success:^(NSURLSessionDataTask* task, id response) {
        [weakSelf.acFrame stopAc];
        if ([response[@"result"] isEqualToString:@"good"]) {
            [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"设备正在升级，升级成功后设备会重新启动" action:nil];
        }
        else {
            [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:response[@"detail"] action:nil];
        }
    } failure:^(NSURLSessionDataTask* taskk, NSError* error) {
        [weakSelf.acFrame stopAc];
        [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"网络错误，请稍后再试" action:nil];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    self.deviceCheckFinish = NO;
    self.serverCheckFinish = NO;
    [self.acFrame startAc];
    [self checkDeviceVersion];
    [self checkServerVersion];
    [super viewDidAppear:animated];
}

- (void)checkDeviceVersion {
    __weak DeviceUpdateViewController *weakSelf = self;
    [self.client checkDeviceVersionSuccess:^(NSURLSessionDataTask* task, id response) {
        weakSelf.deviceCheckFinish = YES;
        if (weakSelf.deviceCheckFinish && weakSelf.serverCheckFinish) {
            if ([weakSelf.acFrame isAnimating]) {
                [weakSelf.acFrame stopAc];
                [weakSelf.tableView reloadData];
            }
        }
        if ([response[@"result"] isEqualToString:@"good"]) {
            weakSelf.deviceVersion = [[NSDictionary alloc] initWithDictionary:response[@"param"]];
        }
        else {
            weakSelf.deviceVersion = @{@"buildtime" : @"unkown", @"version" : @"unkown"};
        }
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        weakSelf.deviceCheckFinish = YES;
        if (weakSelf.deviceCheckFinish && weakSelf.serverCheckFinish) {
            if ([weakSelf.acFrame isAnimating]) {
                [weakSelf.acFrame stopAc];
                [weakSelf.tableView reloadData];
            }
        }
        weakSelf.deviceVersion = @{@"buildtime" : @"unkown", @"version" : @"unkown"};
    }];
}

- (void)checkServerVersion {
    __weak DeviceUpdateViewController *weakSelf = self;
    [self.client checkServerVersionSuccess:^(NSURLSessionDataTask* task, id response) {
        weakSelf.serverCheckFinish = YES;
        if (weakSelf.deviceCheckFinish && weakSelf.serverCheckFinish) {
            if ([weakSelf.acFrame isAnimating]) {
                [weakSelf.acFrame stopAc];
                [weakSelf.tableView reloadData];
            }
        }
        if ([response[@"result"] isEqualToString:@"good"]) {
            weakSelf.serverVersion = [[NSDictionary alloc] initWithDictionary:response[@"param"][@"update"]];
            NSString* featureString = [[NSString alloc] init];
            NSArray* featureArray = weakSelf.serverVersion[@"newfeature"];
            for (NSUInteger i = 0; i < [featureArray count] - 1; i ++) {
                featureString = [featureString stringByAppendingFormat:@"%@\n", [featureArray objectAtIndex:i]];
            }
            featureString = [featureString stringByAppendingFormat:@"%@", [featureArray objectAtIndex:([featureArray count] - 1)]];
            CGSize featureSize = [featureString boundingRectWithSize:CGSizeMake(weakSelf.view.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]} context:nil].size;
            weakSelf.featureLabel.numberOfLines = [featureArray count];
            weakSelf.featureLabel.text = featureString;
            weakSelf.featureLabel.font = [UIFont systemFontOfSize:14.0];
            [weakSelf.featureLabel setFrame:CGRectMake(5.0, 48.0, weakSelf.view.frame.size.width, featureSize.height)];
        }
        else {
            weakSelf.serverVersion = @{@"version" : @"unkown", @"buildtime" : @"unkown"};
        }
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        weakSelf.serverCheckFinish = YES;
        if (weakSelf.deviceCheckFinish && weakSelf.serverCheckFinish) {
            if ([weakSelf.acFrame isAnimating]) {
                [weakSelf.acFrame stopAc];
                [weakSelf.tableView reloadData];
            }
        }
        weakSelf.serverVersion = @{@"version" : @"unkown", @"buildtime" : @"unkown"};
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - TableView Delegate Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1) {
        self.isSelected = YES;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 44;
    }
    else{
        if (!self.isSelected || !self.canOpen) {
            return 44.0;
        }
        else {
            return self.featureLabel.frame.size.height + 48.0;
        }
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"UpdatePrototypeCell" forIndexPath:indexPath];
        cell.textLabel.text = @"当前版本";
        NSString* buildTime = self.deviceVersion[@"buildtime"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@(%@)", self.deviceVersion[@"version"], [buildTime substringToIndex:[buildTime length] - 6]];
        [cell setBackgroundColor:[UIColor clearColor]];
        return cell;
    }
    else {
        UpdateTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"UpdateTableViewCell" forIndexPath:indexPath];
        cell.myTextLabel.text = @"最新版本";
        if ([self.deviceVersion[@"version"] isEqualToString:self.serverVersion[@"version"]]) {
            [cell.myImageView setImage:nil];
            self.canOpen = NO;
        }
        else {
            [cell.myImageView setImage:[UIImage imageNamed:@"reddot"]];
            self.canOpen = YES;
        }
        NSString* buildTime = self.serverVersion[@"buildtime"];
        cell.myDetailTextLabel.text = [NSString stringWithFormat:@"%@(%@)", self.serverVersion[@"version"], [buildTime substringToIndex:[buildTime length] - 6]];
        cell.featureLabel.text = self.featureLabel.text;
        cell.featureLabel.numberOfLines = self.featureLabel.numberOfLines;
        if (!self.isSelected || !self.canOpen) {
            cell.featureLabel.hidden = YES;
            cell.buttonUpdate.hidden = YES;
        }
        else {
            cell.featureLabel.hidden = NO;
            cell.buttonUpdate.hidden = NO;
        }
        [cell.buttonUpdate addTarget:self action:@selector(onButtonUpdate) forControlEvents:UIControlEventTouchUpInside];
        [cell setBackgroundColor:[UIColor clearColor]];
        return cell;
    }
}
@end
