//
//  AboutViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 4/7/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "AboutViewController.h"
#import "MyActivityIndicatorView.h"
#import "SCUtil.h"
@interface AboutViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) MyActivityIndicatorView *acFrame;

- (void)onLeftButton;
@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //navigation bar
    UINavigationItem *naviItem = [[UINavigationItem alloc] init];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    [leftBarButton setTintColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]];
    naviItem.leftBarButtonItem = leftBarButton;
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.naviBar.frame.size.width - 100, self.naviBar.frame.size.height)];
    [titleLab setText:@"关于我们"];
    [titleLab setTextColor:[UIColor colorWithRed:21.0 / 255.0 green:37.0 / 255.0 blue:50.0 / 255.0 alpha:1.0]];
    [titleLab setFont:[UIFont systemFontOfSize:17.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    naviItem.titleView = titleLab;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    
    self.webView.delegate = self;
    [self.webView setBackgroundColor:[UIColor clearColor]];
    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];
    
}

- (void)viewWillAppear:(BOOL)animated {
    NSURL *url = [NSURL URLWithString:@"https://www.shuchuangtech.com/m/about.php"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onLeftButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.acFrame startAc];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.acFrame stopAc];
    [SCUtil viewController:self showAlertTitle:@"提示" message:@"页面加载失败，请稍后再试" action:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.acFrame stopAc];
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
