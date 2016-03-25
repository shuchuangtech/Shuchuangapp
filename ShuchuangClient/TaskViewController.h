//
//  TaskViewController.h
//  ShuchuangClient
//
//  Created by 黄建 on 1/25/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddTaskProtocol.h"
#import "ModifyTaskProtocol.h"
@interface TaskViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, AddTaskProtocol, ModifyTaskProtocol>

@end
