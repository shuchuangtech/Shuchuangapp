//
//  NewsViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/19/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "NewsViewController.h"
#import "NewsTableViewCell.h"
@interface NewsViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"NewsTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"NewsTableCell"];
    UINavigationItem *naviItem = [[UINavigationItem alloc] initWithTitle:@"发现"];
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    [self.view addSubview:self.naviBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsTableCell" forIndexPath:indexPath];
    [cell.myImageView setImage:[UIImage imageNamed:@"discover"]];
    return cell;
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
