//
//  UserinfoViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/19/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "UserinfoViewController.h"
#import "Bmob.h"
#import "MeHeadTableViewCell.h"
#import "SCMainViewController.h"
#import "ShareSDK/ShareSDK.h"
#import "ShareSDKUI/ShareSDK+SSUI.h"
#import "SCUtil.h"
#import "MyActivityIndicatorView.h"
#import "AFNetworking.h"
@interface UserinfoViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (strong ,nonatomic) MyActivityIndicatorView *acFrame;

- (void)shareMe;
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
    [titleLab setTextColor:[UIColor colorWithRed:21.0 / 255.0 green:37.0 / 255.0 blue:50.0 / 255.0 alpha:1.0]];
    [titleLab setFont:[UIFont systemFontOfSize:17.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    naviItem.titleView = titleLab;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    
    [self.view addSubview:self.naviBar];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MeHeadTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MeHeadCell"];
    
    self.logoutButton.layer.cornerRadius = 18.0;
    [self.logoutButton setBackgroundColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]];
    [self.logoutButton setAlpha:0.8];
    [self.logoutButton addTarget:self action:@selector(onLogoutButton) forControlEvents:UIControlEventTouchUpInside];
    
    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 3;
            break;
        default:
            return 0;
            break;
    }
}

- (void)shareMe {
    AFHTTPSessionManager *http;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    http = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    //init certificate
    NSString * cerPath = [[NSBundle mainBundle] pathForResource:@"server" ofType:@"cer"];
    NSData * cerData = [NSData dataWithContentsOfFile:cerPath];
    http.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:[[NSArray alloc] initWithObjects:cerData, nil]];
    //serializer
    http.requestSerializer = [AFHTTPRequestSerializer serializer];
    http.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString *baseURL = @"https://www.shuchuangtech.com/m/share/info.php";
    __block NSString *logoURL;
    __block NSString *shareTitle;
    __block NSString *shareText;
    __block NSString *shareURL;
    [self.acFrame startAc];
    [http GET:baseURL parameters:nil success:^(NSURLSessionDataTask *task, id response) {
        logoURL = response[@"logo"];
        shareURL = response[@"url"];
        shareTitle = response[@"title"];
        shareText = response[@"text"];
        [self.acFrame stopAc];
        if (shareTitle == nil) {
            [SCUtil viewController:self showAlertTitle:@"提示" message:@"分享失败， 请稍后再试" action:nil];
        }
        else {
            NSArray *imageArray = @[logoURL];
            if (imageArray) {
                NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
                [shareParams SSDKSetupShareParamsByText:shareText images:imageArray url:[NSURL URLWithString:shareURL] title:shareTitle type:SSDKContentTypeAuto];
                [ShareSDK showShareActionSheet:nil items:nil shareParams:shareParams onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                    switch (state) {
                        case SSDKResponseStateSuccess: {
                            [SCUtil viewController:self showAlertTitle:@"提示" message:@"分享成功" action:nil];
                            break;
                        }
                        case SSDKResponseStateFail: {
                            [SCUtil viewController:self showAlertTitle:@"提示" message:@"分享失败" action:nil];
                            break;
                        }
                        default:
                            break;
                    }
                }];
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self.acFrame stopAc];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 80.0;
    }
    else {
        return 35.0;
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        MeHeadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MeHeadCell" forIndexPath:indexPath];
        BmobUser *user = [BmobUser getCurrentUser];
        cell.usernameLabel.text = [user username];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MeTableCell" forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = @"";
        [cell.textLabel setTextColor:[UIColor colorWithRed:21.0 / 255.0 green:37.0 / 255.0 blue:50.0 / 255.0 alpha:1.0]];
        [cell.textLabel setFont:[UIFont systemFontOfSize:14.0]];
        switch (indexPath.row) {
            case 0: {
                cell.textLabel.text = @"社交分享";
                [cell.imageView setImage:[UIImage imageNamed:@"userShare"]];
                break;
            }
            case 1: {
                cell.textLabel.text = @"意见反馈";
                [cell.imageView setImage:[UIImage imageNamed:@"userMail"]];
                break;
            }
            case 2: {
                cell.textLabel.text =  @"关于我们";
                [cell.imageView setImage:[UIImage imageNamed:@"userInfo"]];
                break;
            }
        }
        return cell;
    }
    // Configure the cell...

    return nil;
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
            [self shareMe];
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
}

- (void)onLogoutButton {
    [BmobUser logout];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
