//
//  NewsDetailViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 4/12/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "NewsDetailViewController.h"

@interface NewsDetailViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) NSString *newsTitle;
@property (strong, nonatomic) UIImageView *barBg;

- (void)onLeftButton;
@end

@implementation NewsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UINavigationItem *naviItem = [[UINavigationItem alloc] init];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    [leftBarButton setTintColor:[UIColor whiteColor]];
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.naviBar.frame.size.width - 100, self.naviBar.frame.size.height)];
    [titleLab setText:@"活动详情"];
    [titleLab setTextColor:[UIColor whiteColor]];
    [titleLab setFont:[UIFont systemFontOfSize:17.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    naviItem.titleView = titleLab;
    naviItem.leftBarButtonItem = leftBarButton;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    [self.naviBar setBackgroundImage:[UIImage imageNamed:@"barBg"] forBarMetrics:UIBarMetricsCompact];
    [self.view addSubview:self.naviBar];
    self.barBg = [[UIImageView alloc] init];
    [self.barBg setImage:[UIImage imageNamed:@"barBg"]];
    [self.view addSubview:self.barBg];
    [self.view bringSubviewToFront:self.naviBar];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.barBg setFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
}

- (void)viewWillAppear:(BOOL)animated {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.shuchuangtech.com/m/new/%@/detail.html", self.newsTitle]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    [super viewWillAppear:animated];
}

- (void)onLeftButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
