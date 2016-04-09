//
//  UserViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/25/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "UserViewController.h"
#import "UserTableViewCell.h"
#import "SCDeviceClient.h"
#import "SCDeviceManager.h"
#import "SCUtil.h"
#import "MyActivityIndicatorView.h"
#import "MJRefresh.h"
@interface UserViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *usersArray;
@property (strong, nonatomic) NSMutableArray *invalidArray;
@property (strong, nonatomic) NSMutableArray *normalIndex;
@property (strong, nonatomic) SCDeviceClient *client;
@property (strong, nonatomic) MyActivityIndicatorView *acFrame;
@property (strong, nonatomic) NSString *uuid;
@property (nonatomic) NSInteger selectedIndex;
- (void)onSegValueChanged;
- (void)onLeftButton;
- (void)onRightButton;
- (void)loadMoreData;
@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UINavigationItem *naviItem = [[UINavigationItem alloc] init];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    [leftButton setTintColor:[UIColor colorWithRed:1.0 green:129.0 / 255.0 blue:0 alpha:1]];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add"] style:UIBarButtonItemStylePlain target:self action:@selector(onRightButton)];
    [rightButton setTintColor:[UIColor colorWithRed:1.0 green:129.0 / 255.0 blue:0 alpha:1]];
    naviItem.leftBarButtonItem = leftButton;
    naviItem.rightBarButtonItem = rightButton;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    [self.segmentController addTarget:self action:@selector(onSegValueChanged) forControlEvents:UIControlEventValueChanged];
    //tableview
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerNib:[UINib nibWithNibName:@"UserTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"UserTableViewCell"];
    
    self.usersArray = [[NSMutableArray alloc] init];
    self.invalidArray = [[NSMutableArray alloc] init] ;
    self.normalIndex = [[NSMutableArray alloc] init];
    self.client = [[SCDeviceManager instance] getDevice:self.uuid];
    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.usersArray removeAllObjects];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    [self loadMoreData];
    [super viewDidAppear:animated];
}

- (void)loadMoreData {
    NSDictionary *condition = @{@"limit":[NSNumber numberWithInt:10], @"offset":[NSNumber numberWithUnsignedInteger:[self.usersArray count]]};
    [self.acFrame startAc];
    [self.client getUsers:condition success:^(NSURLSessionDataTask *task, id response) {
        if ([response[@"result"] isEqualToString:@"good"]) {
            NSArray *array = [[NSArray alloc] initWithArray:response[@"Users"]];
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSUInteger unitFlag = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
            for (int i = 0; i < [array count]; i++) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[array objectAtIndex:i]];
                NSInteger timestamp = [dict[@"timeofvalidity"] integerValue];
                NSTimeInterval timeInterval = timestamp / 1000000.0;
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
                NSDateComponents *comp = [calendar components:unitFlag fromDate:date];
                NSString *timeStr = [NSString stringWithFormat:@"%04ld-%02ld-%02ld", [comp year], [comp month], [comp day]];
                [dict setObject:timeStr forKey:@"timestring"];
                if ([dict[@"remainopen"] integerValue] == 0) {
                    [dict setObject:[NSNumber numberWithBool:YES] forKey:@"openInvalid"];
                    [self.invalidArray addObject:dict];
                }
                else if ([date compare:[NSDate date]] == NSOrderedAscending) {
                    [dict setObject:[NSNumber numberWithBool:YES] forKey:@"timeInvalid"];
                    [self.invalidArray addObject:dict];
                }
                else {
                    [dict setObject:[NSNumber numberWithBool:NO] forKey:@"openInvalid"];
                    [dict setObject:[NSNumber numberWithBool:NO] forKey:@"timeInvalid"];
                    [self.normalIndex addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                }
                [self.usersArray addObject:dict];
            }
            if ([self.tableView.mj_header isRefreshing]) {
                [self.tableView.mj_header endRefreshing];
            }
            if ([array count] < 10) {
                if ([self.tableView.mj_footer isRefreshing]) {
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                }
            }
            else {
                if ([self.tableView.mj_footer isRefreshing]) {
                    [self.tableView.mj_footer endRefreshing];
                }
            }
            [self.tableView reloadData];
            [self.acFrame stopAc];
        }
        else {
            [self.acFrame stopAc];
            [SCUtil viewController:self showAlertTitle:@"提示" message:response[@"detail"] action:nil];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self.acFrame stopAc];
        [SCUtil viewController:self showAlertTitle:@"提示" message:@"网络错误，请稍后再试" action:nil];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onSegValueChanged {
    if ([self.segmentController selectedSegmentIndex] == 0) {
        //all users
        [self.tableView insertRowsAtIndexPaths:self.normalIndex withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {
        //invalid users
        [self.tableView deleteRowsAtIndexPaths:self.normalIndex withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)onLeftButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onRightButton {
    [self performSegueWithIdentifier:@"UserToAddSegue" sender:self];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    id desVC = segue.destinationViewController;
    [desVC setValue:self.uuid forKey:@"uuid"];
    if ([segue.identifier isEqualToString:@"UserToDetailSegue"]) {
        if ([self.segmentController selectedSegmentIndex] == 0) {
            [desVC setValue:[self.usersArray objectAtIndex:self.selectedIndex] forKey:@"userInfo"];
        }
        else {
            [desVC setValue:[self.invalidArray objectAtIndex:self.selectedIndex] forKey:@"userInfo"];
        }
    }
}


#pragma mark - TableView DataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserTableViewCell" forIndexPath:indexPath];
    if ([self.segmentController selectedSegmentIndex] == 0) {
        NSDictionary *dict = [self.usersArray objectAtIndex:indexPath.row];
        NSInteger remainOpen = [[dict objectForKey:@"remainopen"] integerValue];
        cell.usernameLabel.text = [dict objectForKey:@"binduser"];
        cell.timeOfValidityLabel.text = [dict objectForKey:@"timestring"];
        if ([[dict objectForKey:@"openInvalid"] boolValue]) {
            [cell.remainOpenLabel setTextColor:[UIColor redColor]];
            [cell.usernameLabel setTextColor:[UIColor redColor]];
        }
        else if ([[dict objectForKey:@"timeInvalid"] boolValue]) {
            [cell.timeOfValidityLabel setTextColor:[UIColor redColor]];
            [cell.usernameLabel setTextColor:[UIColor redColor]];
        }
        if ( remainOpen < 0) {
            cell.remainOpenLabel.text = @"无限制";
        }
        else {
            cell.remainOpenLabel.text = [NSString stringWithFormat:@"%ld", [[dict objectForKey:@"remainopen"] integerValue]];
        }
        if ([[dict objectForKey:@"authority"] integerValue] == 9) {
            cell.authLabel.text = @"管理者";
        }
        else {
            cell.authLabel.text = @"普通用户";
        }
        return cell;
    }
    else {
        NSDictionary *dict = [self.usersArray objectAtIndex:indexPath.row];
        NSInteger remainOpen = [[dict objectForKey:@"remainopen"] integerValue];
        cell.usernameLabel.text = [dict objectForKey:@"binduser"];
        cell.timeOfValidityLabel.text = [dict objectForKey:@"timestring"];
        if ([[dict objectForKey:@"openInvalid"] boolValue]) {
            [cell.remainOpenLabel setTextColor:[UIColor redColor]];
            [cell.usernameLabel setTextColor:[UIColor redColor]];
        }
        else if ([[dict objectForKey:@"timeInvalid"] boolValue]) {
            [cell.timeOfValidityLabel setTextColor:[UIColor redColor]];
            [cell.usernameLabel setTextColor:[UIColor redColor]];
        }
        if ( remainOpen < 0) {
            cell.remainOpenLabel.text = @"无限制";
        }
        else {
            cell.remainOpenLabel.text = [NSString stringWithFormat:@"%ld", [[dict objectForKey:@"remainopen"] integerValue]];
        }
        if ([[dict objectForKey:@"authority"] integerValue] == 9) {
            cell.authLabel.text = @"管理者";
        }
        else {
            cell.authLabel.text = @"普通用户";
        }
        return cell;
    }
}

#pragma mark - TableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.segmentController selectedSegmentIndex] == 0) {
        return [self.usersArray count];
    }
    else {
        return [self.invalidArray count];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.segmentController selectedSegmentIndex] == 0 && indexPath.row == 0) {
        return;
    }
    self.selectedIndex = indexPath.row;
    [self performSegueWithIdentifier:@"UserToDetailSegue" sender:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}
@end
