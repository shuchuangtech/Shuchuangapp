//
//  UserinfoViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/19/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "UserinfoViewController.h"
#import "Bmob.h"
#import "MeHeaderTableViewCell.h"
#import "MeTableViewCell.h"
#import "SCMainViewController.h"
#import "ShareSDK/ShareSDK.h"
#import "ShareSDKUI/ShareSDK+SSUI.h"
#import "SCUtil.h"
@interface UserinfoViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (strong, nonatomic) UIImageView *barBg;
@property (strong, nonatomic) UIImageView *bgView;

@end

@implementation UserinfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    UINavigationItem *naviItem = [[UINavigationItem alloc] init];
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.naviBar.frame.size.width - 100, self.naviBar.frame.size.height)];
    [titleLab setText:@"我"];
    [titleLab setTextColor:[UIColor whiteColor]];
    [titleLab setFont:[UIFont systemFontOfSize:17.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    naviItem.titleView = titleLab;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    [self.naviBar setBackgroundImage:[UIImage imageNamed:@"barBg"] forBarMetrics:UIBarMetricsCompact];
    [self.view addSubview:self.naviBar];
    
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
    [self.bgView  setFrame:CGRectMake(0, self.barBg.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.barBg.frame.size.height)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 3;
            break;
        case 2:
            return 1;
            break;
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.view.frame.size.width / 6 + 40;
    }
    else {
        return 44;
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell" forIndexPath:indexPath];
        BmobUser *user = [BmobUser getCurrentUser];
        [(MeHeaderTableViewCell *)cell setUserName:[user username]];
    }
    else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MiddleCell" forIndexPath:indexPath];
        switch (indexPath.row) {
            case 0: {
                [(MeTableViewCell *)cell setLabelText:@"社交分享"];
                [(MeTableViewCell *)cell setLeftImage:[UIImage imageNamed:@"tableShare"]];
                break;
            }
            case 1: {
                [(MeTableViewCell *)cell setLabelText:@"意见反馈"];
                [(MeTableViewCell *)cell setLeftImage:[UIImage imageNamed:@"tableCommu"]];
                break;
            }
            case 2: {
                [(MeTableViewCell *)cell setLabelText:@"关于我们"];
                [(MeTableViewCell *)cell setLeftImage:[UIImage imageNamed:@"tableAbout"]];
                break;
            }
        }
    }
    else if (indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"FooterCell" forIndexPath:indexPath];
        [(MeTableViewCell *)cell setLabelText:@"退出登录"];
        [(MeTableViewCell *)cell setLeftImage:[UIImage imageNamed:@"melogout"]];
    }
    // Configure the cell...

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"UserInfo" bundle:[NSBundle mainBundle]];
        UIViewController *vc = [story instantiateViewControllerWithIdentifier:@"UserSettingVC"];
        [self presentViewController:vc animated:YES completion:nil];
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            NSArray *imageArray = @[@"http://mob.com/Assets/images/logo.png?v=20150320"];
            if (imageArray) {
                NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
                [shareParams SSDKSetupShareParamsByText:@"分享内容" images:imageArray url:[NSURL URLWithString:@"http://mob.com"] title:@"测试分享" type:SSDKContentTypeAuto];
                __weak UserinfoViewController *weakSelf = self;
                [ShareSDK showShareActionSheet:nil items:nil shareParams:shareParams onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                    switch (state) {
                        case SSDKResponseStateSuccess: {
                            [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"分享成功" action:nil];
                            break;
                        }
                        case SSDKResponseStateFail: {
                            [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"分享失败" action:nil];
                            break;
                        }
                        default:
                            break;
                    }
                }];
            }
        }
        else if (indexPath.row == 1) {
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"UserInfo" bundle:[NSBundle mainBundle]];
            UIViewController *vc = [story instantiateViewControllerWithIdentifier:@"UserInfoVC"];
            [self presentViewController:vc animated:YES completion:nil];
        }
        else if (indexPath.row == 2) {
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"UserInfo" bundle:[NSBundle mainBundle]];
            UIViewController *vc = [story instantiateViewControllerWithIdentifier:@"AboutVC"];
            [self presentViewController:vc animated:YES completion:nil];
        }
    }
    if (indexPath.section == 2 && indexPath.row == 0) {
        if ([self.presentingViewController isKindOfClass:[SCMainViewController class]]) {
            [BmobUser logout];
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
        //
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
