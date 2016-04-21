//
//  DeviceCollectionViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/12/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "DeviceCollectionViewController.h"
#import "DeviceCollectionViewCell.h"
#import "DeviceDetailViewController.h"
#import "DeviceAddViewController.h"
#import "SCDeviceManager.h"
#import "MJRefresh.h"
#import "DeleteDeviceProtocol.h"
#import "SCUtil.h"

@interface DeviceCollectionViewController () <DeleteDeviceProtocol>
@property (strong, nonatomic) NSArray *devices;
@property BOOL isEditing;
@property BOOL needRefresh;
@property (weak, nonatomic) SCDeviceManager *devManager;
@property (weak, nonatomic) IBOutlet UINavigationItem *naviItem;
@property (strong, nonatomic) UIImageView *barBg;
@property (strong, nonatomic) UIImageView *bgView;

- (void)refreshDevicesState;
- (void)addCompletion:(NSNotification *)noti;
@end

@implementation DeviceCollectionViewController

static NSString * const reuseIdentifier = @"CollectionCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"barBg"] forBarMetrics:UIBarMetricsCompact];
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width - 100, self.navigationController.navigationBar.frame.size.height)];
    [titleLab setText:@"设备"];
    [titleLab setTextColor:[UIColor whiteColor]];
    [titleLab setFont:[UIFont systemFontOfSize:17.0]];
    titleLab.textAlignment = NSTextAlignmentCenter;
    self.naviItem.titleView = titleLab;
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add"] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit"] style:UIBarButtonItemStylePlain target:self action:@selector(onRightButton)];
    [leftButton setTintColor:[UIColor whiteColor]];
    [rightButton setTintColor:[UIColor whiteColor]];
    [self.naviItem setLeftBarButtonItem:leftButton];
    [self.naviItem setRightBarButtonItem:rightButton];
   

    // Do any additional setup after loading the view.
    self.isEditing = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addCompletion:) name:@"AddCompletionNoti" object:nil];
    self.devManager = [SCDeviceManager instance];
    self.devices = [self.devManager allDevices];
    self.needRefresh = YES;
    __weak DeviceCollectionViewController *weakSelf = self;
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.needRefresh = YES;
        [weakSelf refreshDevicesState];
    }];
    
    self.barBg = [[UIImageView alloc] init];
    [self.barBg setImage:[UIImage imageNamed:@"barBg"]];
    [self.view addSubview:self.barBg];
    [self.view bringSubviewToFront:self.navigationController.navigationBar];
    self.bgView = [[UIImageView alloc] init];
    [self.bgView setImage:[UIImage imageNamed:@"background"]];
    [self.collectionView setBackgroundView:self.bgView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.barBg setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y)];
    [self.bgView setFrame:CGRectMake(0, 0, self.collectionView.frame.size.width, self.collectionView.frame.size.height)];
}

- (void)viewWillAppear:(BOOL)animated {
    //self.needRefresh = YES;
    [self refreshDevicesState];
    [super viewWillAppear:animated];
}

//add
- (void)onLeftButton {
    if (self.isEditing) {
        self.isEditing = NO;
        [self.collectionView reloadData];
    }
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Device" bundle:[NSBundle mainBundle]];
    UIViewController *next = [story instantiateViewControllerWithIdentifier:@"DeviceAddVC"];
    [self presentViewController:next animated:YES completion:nil];
}

//edit
- (void)onRightButton {
    self.isEditing = !self.isEditing;
    [self.collectionView reloadData];
}

- (void)onDeleteDevice:(NSString *)uuid {
    __weak DeviceCollectionViewController *weakSelf = self;
    [SCUtil viewController:self showAlertTitle:@"提示" message:@"确认删除这个设备吗" yesAction:^(UIAlertAction *action) {
        SCDeviceClient *client = [[SCDeviceManager instance] getDevice:uuid];
        [client logoutSuccess:^(NSURLSessionDataTask *task, id response) {
            [[SCDeviceManager instance] removeDevice:uuid];
            weakSelf.devices = [[SCDeviceManager instance] allDevices];
            [weakSelf.collectionView reloadData];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {

        }];
    } noAction:^(UIAlertAction *action) {

    }];
}

- (void)addCompletion:(NSNotification *)noti {
    self.devices = [[SCDeviceManager instance] allDevices];
    [self.collectionView reloadData];
}

- (void)refreshDevicesState {
    if (self.isEditing) {
        self.isEditing = NO;
        [self.collectionView reloadData];
    }
    NSInteger num = [self.devices count];
    if (num == 0) {
        [self.collectionView.mj_header endRefreshing];
        self.needRefresh = NO;
    }
    else if (num > 0 && self.needRefresh) {
        __block NSInteger finished = 0;
        for (int i = 0; i < num; i++) {
            NSString *key = [self.devices objectAtIndex:i];
            SCDeviceClient* client = [[SCDeviceManager instance] getDevice:key];
            __weak DeviceCollectionViewController *weakSelf = self;
            [client checkDoorSuccess:^(NSURLSessionDataTask *task, id response) {
                finished++;
                if (finished == num ) {
                    if ([weakSelf.collectionView.mj_header isRefreshing]) {
                        [weakSelf.collectionView.mj_header endRefreshing];
                    }
                    [weakSelf.collectionView reloadData];
                }
            } failure:^(NSURLSessionDataTask *task, NSError* error) {
                finished++;
                if ([weakSelf.collectionView.mj_header isRefreshing]) {
                    [weakSelf.collectionView.mj_header endRefreshing];
                }
                [weakSelf.collectionView reloadData];
            }];
        }
        self.needRefresh = NO;
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


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.needRefresh) {
        return 0;
    }
    else {
        return 1;
    }
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.needRefresh) {
        return 0;
    }
    else {
        return [self.devices count];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DeviceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    SCDeviceClient *client = [self.devManager getDevice:[self.devices objectAtIndex:indexPath.row]];
    cell.label.text = client.name;
    cell.uuid = client.uuid;
    cell.deleteDelegate = self;
    if (client.doorClose) {
        cell.imageView.image = [UIImage imageNamed:@"deviceLock"];
    }
    else {
        cell.imageView.image = [UIImage imageNamed:@"deviceUnlock"];
    }
    if (client.online) {
        cell.lockImg.image = [UIImage imageNamed:@"online"];
    }
    else {
        cell.lockImg.image = [UIImage imageNamed:@"offline"];
    }
    if (self.isEditing) {
        [cell stopEdit];
        [cell startEdit:(indexPath.row%2 == 0)?YES:NO];
    }
    else {
        [cell stopEdit];
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isEditing) {
        self.isEditing = NO;
        [collectionView reloadData];
    }
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    SCDeviceClient *client = [self.devManager getDevice:[self.devices objectAtIndex:indexPath.row]];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Device" bundle:[NSBundle mainBundle]];
    UIViewController *next = [story instantiateViewControllerWithIdentifier:@"DeviceDetailVC"];
    [next setValue:client.uuid forKey:@"uuid"];
    [self presentViewController:next animated:YES completion:nil];
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
