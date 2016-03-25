//
//  DeviceDetailViewController.h
//  ShuchuangClient
//
//  Created by 黄建 on 1/20/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
@property (strong, nonatomic) NSString* uuid;
@end
