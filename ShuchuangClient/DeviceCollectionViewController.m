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
#import "MyActivityIndicatorView.h"
#import "MJRefresh.h"

@interface DeviceCollectionViewController ()
@property (strong, nonatomic) NSArray *devices;
@property BOOL isEditing;
@property BOOL needRefresh;
@property (strong, nonatomic) MyActivityIndicatorView *acFrame;
@property (weak, nonatomic) SCDeviceManager *devManager;
@property (weak, nonatomic) IBOutlet UINavigationItem *naviItem;

- (void)refreshDevicesState;
- (void)deleteCompletion:(NSNotification *)noti;
- (void)addCompletion:(NSNotification *)noti;
@end

@implementation DeviceCollectionViewController

static NSString * const reuseIdentifier = @"CollectionCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    //[self.collectionView registerClass:[DeviceCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
    [self.naviItem setTitle:@"设备"];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add"] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit"] style:UIBarButtonItemStylePlain target:self action:@selector(onRightButton)];
    [leftButton setTintColor:[UIColor colorWithRed:1.0 green:129.0/255.0 blue:0.0 alpha:1.0]];
    [rightButton setTintColor:[UIColor colorWithRed:1.0 green:129.0/255.0 blue:0.0 alpha:1.0]];
    [self.naviItem setLeftBarButtonItem:leftButton];
    [self.naviItem setRightBarButtonItem:rightButton];
   

    // Do any additional setup after loading the view.
    self.isEditing = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteCompletion:) name:@"DeleteCompletionNoti" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addCompletion:) name:@"AddCompletionNoti" object:nil];
    self.devManager = [SCDeviceManager instance];
    self.devices = [self.devManager allDevices];
    self.needRefresh = YES;
    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.needRefresh = YES;
        [self refreshDevicesState];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    //self.needRefresh = YES;
    [self refreshDevicesState];
}
//add
- (void)onLeftButton {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Device" bundle:[NSBundle mainBundle]];
    UIViewController *next = [story instantiateViewControllerWithIdentifier:@"DeviceAddVC"];
    [self presentViewController:next animated:YES completion:nil];
}

//edit
- (void)onRightButton {
    self.isEditing = !self.isEditing;
    [self.collectionView reloadData];
}

- (void)deleteCompletion:(NSNotification *)noti {
    NSDictionary *dict = [noti userInfo];
    NSString *uuid = dict[@"devId"];
    [[SCDeviceManager instance] removeDevice:uuid];
    self.devices = [[SCDeviceManager instance] allDevices];
    [self.collectionView reloadData];
}

- (void)addCompletion:(NSNotification *)noti {
    self.devices = [[SCDeviceManager instance] allDevices];
    [self.collectionView reloadData];
}

- (void)refreshDevicesState {
    NSInteger num = [self.devices count];
    if (num > 0 && self.needRefresh) {
        [self.acFrame startAc];
        __block NSInteger finished = 0;
        for (int i = 0; i < num; i++) {
            NSString *key = [self.devices objectAtIndex:i];
            SCDeviceClient* client = [[SCDeviceManager instance] getDevice:key];
            [client checkDoorSuccess:^(NSURLSessionDataTask *task, id response) {
                finished++;
                if (finished == num ) {
                    if ([self.acFrame isAnimating]) {
                        [self.acFrame stopAc];
                    }
                    if ([self.collectionView.mj_header isRefreshing]) {
                        [self.collectionView.mj_header endRefreshing];
                    }
                    [self.collectionView reloadData];
                }
            } failure:^(NSURLSessionDataTask *task, NSError* error) {
                finished++;
                if (finished == num) {
                    if ([self.acFrame isAnimating]) {
                        [self.acFrame stopAc];
                    }
                }
                if ([self.collectionView.mj_header isRefreshing]) {
                    [self.collectionView.mj_header endRefreshing];
                }
                [self.collectionView reloadData];
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
    cell.imageView.image = [UIImage imageNamed:@"browser"];
    if (client.doorClose) {
        //NSLog(@"%@, doorClose yes", client.uuid);
        cell.lockImg.image = [UIImage imageNamed:@"lock"];
    }
    else {
        //NSLog(@"%@, doorClose no", client.uuid);
        cell.lockImg.image = [UIImage imageNamed:@"unlock"];
    }
    if (self.isEditing) {
        [cell startEdit:(indexPath.row%2 == 0)?YES:NO];
    }
    else {
        [cell stopEdit];
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
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
