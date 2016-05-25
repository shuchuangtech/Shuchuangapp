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

- (void)onLeftButton;
@end

@implementation NewsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UINavigationItem *naviItem = [[UINavigationItem alloc] init];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_highlight"] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    [leftBarButton setTintColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]];
    naviItem.leftBarButtonItem = leftBarButton;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
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
