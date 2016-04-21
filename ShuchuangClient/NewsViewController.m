//
//  NewsViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/19/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "NewsViewController.h"
#import "NewsTableViewCell.h"
#import "AFNetworking.h"
@interface NewsViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *news;
@property (strong, nonatomic) AFHTTPSessionManager *http;
@property (strong, nonatomic) UIImageView *barBg;
@property (strong, nonatomic) UIImageView *bgView;


@end

@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView registerNib:[UINib nibWithNibName:@"NewsTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"NewsTableCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    UINavigationItem *naviItem = [[UINavigationItem alloc] init];
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.naviBar.frame.size.width - 100, self.naviBar.frame.size.height)];
    [titleLab setText:@"发现"];
    [titleLab setTextColor:[UIColor whiteColor]];
    [titleLab setFont:[UIFont systemFontOfSize:17.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    naviItem.titleView = titleLab;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    [self.naviBar setBackgroundImage:[UIImage imageNamed:@"barBg"] forBarMetrics:UIBarMetricsCompact];
    [self.view addSubview:self.naviBar];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.http = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    //init certificate
    NSString * cerPath = [[NSBundle mainBundle] pathForResource:@"server" ofType:@"cer"];
    NSData * cerData = [NSData dataWithContentsOfFile:cerPath];
    self.http.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:[[NSArray alloc] initWithObjects:cerData, nil]];
    //serializer
    self.http.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.http.responseSerializer = [AFJSONResponseSerializer serializer];
    
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
    [self.barBg setFrame:CGRectMake(0, 0, self.view.frame.size.width, 64.0)];
    [self.bgView setFrame:CGRectMake(0, self.barBg.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.barBg.frame.size.height)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *baseURL = @"https://www.shuchuangtech.com/m/new/index.php";
    __weak NewsViewController *weakSelf = self;
    [self.http GET:baseURL parameters:nil success:^(NSURLSessionDataTask *task, id response) {
        NSArray *news = response[@"news"];
        weakSelf.news = news;
        __block NSInteger finishNews = 0;
        NSFileManager *file = [NSFileManager defaultManager];
        for(NSUInteger i = 0; i < [weakSelf.news count]; i++) {
            NSString *new = [weakSelf.news objectAtIndex:i];
            NSURL *cacheDirectoryURL = [file URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            NSURL *newsDir = [cacheDirectoryURL URLByAppendingPathComponent:@"news"];
            NSURL *downloadDir = [newsDir URLByAppendingPathComponent:new];
            BOOL isDir;
            if (![file fileExistsAtPath:[downloadDir relativePath] isDirectory:&isDir]) {
                [file createDirectoryAtURL:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
                NSURL *newURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.shuchuangtech.com/m/new/%@/cover.png", new]];
                NSURLRequest *request = [NSURLRequest requestWithURL:newURL];
                NSURLSessionDownloadTask *downloadTask = [weakSelf.http downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                    NSURL *downloadFilePath = [downloadDir URLByAppendingPathComponent:@"cover.png"];
                    return downloadFilePath;
                } completionHandler:^(NSURLResponse *response, NSURL *fileURL, NSError *error) {
                    finishNews++;
                    if (finishNews == [weakSelf.news count]) {
                        [weakSelf.tableView reloadData];
                    }
                }];
                [downloadTask resume];
            }
            else {
                finishNews++;
                if (finishNews == [weakSelf.news count]) {
                    [weakSelf.tableView reloadData];
                }
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {

    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.news count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsTableCell" forIndexPath:indexPath];
    NSString *new = [self.news objectAtIndex:indexPath.row];
    NSFileManager *file = [NSFileManager defaultManager];
    NSURL *cacheDirectoryURL = [file URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSURL *coverPath = [cacheDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"/news/%@/cover.png", new]];
    NSData *imgData = [NSData dataWithContentsOfURL:coverPath];
    [cell.myImageView setImage:[UIImage imageWithData:imgData]];
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"News" bundle:[NSBundle mainBundle]];
    UIViewController *vc = [story instantiateViewControllerWithIdentifier:@"NewsMainVC"];
    [vc setValue:[self.news objectAtIndex:indexPath.row] forKey:@"newsTitle"];
    [self presentViewController:vc animated:YES completion:nil];
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
