//
//  AddTaskViewController.h
//  ShuchuangClient
//
//  Created by 黄建 on 3/2/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddTaskProtocol.h"
#import "EditTaskProtocol.h"
@interface AddTaskViewController : UIViewController <EditTaskProtocol, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) id<AddTaskProtocol> addTaskDelegate;
@end
