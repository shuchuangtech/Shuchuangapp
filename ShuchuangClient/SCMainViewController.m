//
//  SCMainViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/8/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "SCMainViewController.h"
#import "Bmob.h"
#import "SCDeviceManager.h"
@interface SCMainViewController ()
- (void)nextView;
@end

@implementation SCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [self performSelectorOnMainThread:@selector(nextView) withObject:nil waitUntilDone:NO];
}

- (void)nextView {
    BmobUser *user = [BmobUser getCurrentUser];
    NSString *storyName;
    NSString *vcId;
    if (user == nil) {
        storyName = @"Welcome";
        vcId = @"WelcomeVC";
    }
    else {
        storyName = @"Tabbar";
        vcId = @"TabbarVC";
        [[SCDeviceManager instance] loadDevicesForUser:user.username];
    }
    UIStoryboard *story = [UIStoryboard storyboardWithName:storyName bundle:[NSBundle mainBundle]];
    UIViewController *next = [story instantiateViewControllerWithIdentifier:vcId];
    [self presentViewController:next animated:YES completion:nil];
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
