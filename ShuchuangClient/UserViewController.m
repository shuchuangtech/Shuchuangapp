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
@property (strong, nonatomic) UINavigationItem *naviItem;
@property (strong, nonatomic) UIBarButtonItem *rightEditButton;
@property (strong, nonatomic) UIBarButtonItem *rightFinishButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

@property (strong, nonatomic) NSMutableArray *usersArray;
@property (strong, nonatomic) NSMutableArray *invalidArray;
@property (strong, nonatomic) NSMutableArray *normalIndex;
@property (weak, nonatomic) SCDeviceClient *client;
@property (strong, nonatomic) MyActivityIndicatorView *acFrame;
@property (copy, nonatomic) NSString *uuid;
@property (nonatomic) NSInteger selectedIndex;

- (void)onSegValueChanged;
- (void)onButtonAdd;
- (void)onLeftButton;
- (void)onRightButton;
- (void)loadMoreData;
@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.naviItem = [[UINavigationItem alloc] init];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    [leftButton setTintColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]];
    self.rightEditButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit"] style:UIBarButtonItemStylePlain target:self action:@selector(onRightButton)];
    [self.rightEditButton setTintColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]];
    self.rightFinishButton = [[UIBarButtonItem alloc] initWithTitle:@"完成  " style:UIBarButtonItemStylePlain target:self action:@selector(onRightButton)];
    [self.rightFinishButton setTintColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]];
    self.naviItem.leftBarButtonItem = leftButton;
    self.naviItem.rightBarButtonItem = self.rightEditButton;
    [self.naviBar pushNavigationItem:self.naviItem animated:NO];
    
    [self.segmentController addTarget:self action:@selector(onSegValueChanged) forControlEvents:UIControlEventValueChanged];
    [self.segmentController setTintColor:[UIColor colorWithRed:237.0 / 255.0 green:57.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]];
    
    //tableview
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerNib:[UINib nibWithNibName:@"UserTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"UserTableViewCell"];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    self.usersArray = [[NSMutableArray alloc] init];
    self.invalidArray = [[NSMutableArray alloc] init] ;
    self.normalIndex = [[NSMutableArray alloc] init];
    self.client = [[SCDeviceManager instance] getDevice:self.uuid];
    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];

    [self.view bringSubviewToFront:self.segmentController];
    
    [self.addButton addTarget:self action:@selector(onButtonAdd) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.tableView.editing) {
        [self.tableView setEditing:NO animated:YES];
        self.naviItem.rightBarButtonItem = self.rightEditButton;
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.usersArray removeAllObjects];
    [self.normalIndex removeAllObjects];
    [self.invalidArray removeAllObjects];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    [self loadMoreData];
    [super viewDidAppear:animated];
}

- (void)loadMoreData {
    NSDictionary *condition = @{@"limit":[NSNumber numberWithInt:10], @"offset":[NSNumber numberWithUnsignedInteger:[self.usersArray count]]};
    [self.acFrame startAc];
    __weak UserViewController *weakSelf = self;
    [self.client getUsers:condition success:^(NSURLSessionDataTask *task, id response) {
        if ([response[@"result"] isEqualToString:@"good"]) {
            NSArray *array = [[NSArray alloc] initWithArray:response[@"Users"]];
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSUInteger unitFlag = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
            for (int i = 0; i < [array count]; i++) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[array objectAtIndex:i]];
                long long timestamp = [dict[@"timeofvalidity"] longLongValue];
                NSTimeInterval timeInterval = timestamp / 1000000.0;
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
                NSDateComponents *comp = [calendar components:unitFlag fromDate:date];
                NSString *timeStr = [NSString stringWithFormat:@"%02ld/%02ld/%04ld", (long)[comp day], (long)[comp month], (long)[comp year]];
                [dict setObject:timeStr forKey:@"timestring"];
                if ([dict[@"remainopen"] integerValue] == 0) {
                    [dict setObject:[NSNumber numberWithBool:YES] forKey:@"openInvalid"];
                    [weakSelf.invalidArray addObject:dict];
                }
                else if ([date compare:[NSDate date]] == NSOrderedAscending) {
                    [dict setObject:[NSNumber numberWithBool:YES] forKey:@"timeInvalid"];
                    [weakSelf.invalidArray addObject:dict];
                }
                else {
                    [dict setObject:[NSNumber numberWithBool:NO] forKey:@"openInvalid"];
                    [dict setObject:[NSNumber numberWithBool:NO] forKey:@"timeInvalid"];
                    [weakSelf.normalIndex addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                }
                [weakSelf.usersArray addObject:dict];
            }
            if ([weakSelf.tableView.mj_header isRefreshing]) {
                [weakSelf.tableView.mj_header endRefreshing];
            }
            if ([array count] < 10) {
                if ([weakSelf.tableView.mj_footer isRefreshing]) {
                    [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                }
            }
            else {
                if ([weakSelf.tableView.mj_footer isRefreshing]) {
                    [weakSelf.tableView.mj_footer endRefreshing];
                }
            }
            [weakSelf.tableView reloadData];
            [weakSelf.acFrame stopAc];
        }
        else {
            [weakSelf.acFrame stopAc];
            [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:response[@"detail"] action:nil];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakSelf.acFrame stopAc];
        [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"网络错误，请稍后再试" action:nil];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onButtonAdd {
    [self performSegueWithIdentifier:@"UserToAddSegue" sender:self];
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
    if (self.tableView.editing) {
        [self.tableView setEditing:NO animated:YES];
        self.naviItem.rightBarButtonItem = self.rightEditButton;
    }
    else {
        [self.tableView setEditing:YES animated:YES];
        self.naviItem.rightBarButtonItem = self.rightFinishButton;
    }
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
    NSDictionary *dict;
    if ([self.segmentController selectedSegmentIndex] == 0) {
        dict = [self.usersArray objectAtIndex:indexPath.row];
    }
    else {
        dict = [self.usersArray objectAtIndex:indexPath.row];
    }
    NSInteger remainOpen = [[dict objectForKey:@"remainopen"] integerValue];
    NSString *username = [dict objectForKey:@"binduser"];
    NSString *time = [dict objectForKey:@"timestring"];
    BOOL openInvalid = [[dict objectForKey:@"openInvalid"] boolValue];
    BOOL timeInvalid = [[dict objectForKey:@"timeInvalid"] boolValue];
    NSInteger auth = [[dict objectForKey:@"authority"] integerValue];
    [cell setUsername:username authority:auth remainOpen:remainOpen timeOfValidity:time remainOpenInvalid:openInvalid timeInvalid:timeInvalid];
    return cell;
}

#pragma mark - TableView Delegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && [self.segmentController selectedSegmentIndex] == 0) {
        return NO;
    }
    else {
        return YES;
    }
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!tableView.editing) {
        return UITableViewCellEditingStyleNone;
    }
    else {
        return UITableViewCellEditingStyleDelete;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.segmentController selectedSegmentIndex] == 0) {
        return [self.usersArray count];
    }
    else {
        return [self.invalidArray count];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *userInfo;
        if ([self.segmentController selectedSegmentIndex] == 0) {
            userInfo = [self.usersArray objectAtIndex:indexPath.row];
        }
        else {
            userInfo = [self.invalidArray objectAtIndex:indexPath.row];
        }
        [self.acFrame startAc];
        __weak UserViewController *weakSelf = self;
        [self.client deleteUser:userInfo[@"username"] success:^(NSURLSessionDataTask *task, id response) {
            [weakSelf.acFrame stopAc];
            if ([response[@"result"] isEqualToString:@"good"]) {
                [weakSelf.usersArray removeAllObjects];
                [weakSelf.normalIndex removeAllObjects];
                [weakSelf.invalidArray removeAllObjects];
                weakSelf.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:weakSelf refreshingAction:@selector(loadMoreData)];
                [weakSelf loadMoreData];
            }
            else {
                [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:response[@"detail"] action:nil];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [weakSelf.acFrame stopAc];
            [SCUtil viewController:weakSelf showAlertTitle:@"提示" message:@"网络错误，请稍后再试" action:nil];
        }];
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
