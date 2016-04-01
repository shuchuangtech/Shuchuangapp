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
@interface UserinfoViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;

@end

@implementation UserinfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UINavigationItem *naviItem = [[UINavigationItem alloc] initWithTitle:@"我"];
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    [self.view addSubview:self.naviBar];
    
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
                [(MeTableViewCell *)cell setLeftImage:[UIImage imageNamed:@"tablecell4"]];
                break;
            }
            case 1: {
                [(MeTableViewCell *)cell setLabelText:@"意见反馈"];
                [(MeTableViewCell *)cell setLeftImage:[UIImage imageNamed:@"tablecell2"]];
                break;
            }
            case 2: {
                [(MeTableViewCell *)cell setLabelText:@"关于我们"];
                [(MeTableViewCell *)cell setLeftImage:[UIImage imageNamed:@"tablecell5"]];
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
