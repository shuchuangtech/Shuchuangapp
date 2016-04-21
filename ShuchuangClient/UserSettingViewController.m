//
//  UserSettingViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 4/12/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "UserSettingViewController.h"
#import "SCUtil.h"

@interface UserSettingViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIImageView *barBg;
@property (strong, nonatomic) UIImageView *bgView;

- (void)onLeftButton;
- (unsigned long long)fileSizeAtPath:(NSString *)filePath;
- (CGFloat)folderSizeAtPath:(NSString *)folderPath;
@end

@implementation UserSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UINavigationItem *naviItem = [[UINavigationItem alloc] init];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    [leftBarButton setTintColor:[UIColor whiteColor]];
    naviItem.leftBarButtonItem = leftBarButton;
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.naviBar.frame.size.width - 100, self.naviBar.frame.size.height)];
    [titleLab setText:@"用户设置"];
    [titleLab setTextColor:[UIColor whiteColor]];
    [titleLab setFont:[UIFont systemFontOfSize:17.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    naviItem.titleView = titleLab;
    [self.naviBar setBackgroundImage:[UIImage imageNamed:@"barBg"] forBarMetrics:UIBarMetricsCompact];
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
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

- (unsigned long long)fileSizeAtPath:(NSString *)filePath {
    NSFileManager *manager = [NSFileManager defaultManager];
    unsigned long long fileSize = [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    return fileSize;
}

- (CGFloat)folderSizeAtPath:(NSString *)folderPath {
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath])
        return 0;
    NSEnumerator *childFilesEnumrator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    unsigned long long folderSize = 0;
    NSString *fileName;
    while ((fileName = [childFilesEnumrator nextObject]) != nil) {
        NSString *fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize / 1024.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserSettingPrototypeCell" forIndexPath:indexPath];
    if (indexPath.row == 0)
    {
        cell.textLabel.text = @"清除缓存";
        NSURL *cacheDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        NSURL *newsDir = [cacheDirectoryURL URLByAppendingPathComponent:@"news"];
        CGFloat fileSize = [self folderSizeAtPath:[newsDir relativePath]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.3f KB", fileSize];
    }
    else if (indexPath.row == 1) {
        cell.textLabel.text = @"修改密码";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = @"";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        NSFileManager *manager = [NSFileManager defaultManager];
        NSURL *cacheDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        NSURL *newsDir = [cacheDirectoryURL URLByAppendingPathComponent:@"news"];
        [manager removeItemAtPath:[newsDir relativePath] error:nil];
        [manager createDirectoryAtURL:newsDir withIntermediateDirectories:YES attributes:nil error:nil];
        __weak UserSettingViewController *weakSelf = self;
        [SCUtil viewController:self showAlertTitle:@"提示" message:@"缓存已清除" action:^(UIAlertAction *action) {
            [weakSelf.tableView reloadData];
        }];
    }
    else if (indexPath.row == 1) {
        [self performSegueWithIdentifier:@"SettingToChpassSegue" sender:self];
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
