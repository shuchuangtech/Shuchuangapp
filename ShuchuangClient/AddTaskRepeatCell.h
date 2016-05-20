//
//  AddTaskRepeatCell.h
//  ShuchuangClient
//
//  Created by 黄建 on 5/13/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditTaskProtocol.h"
@interface AddTaskRepeatCell : UITableViewCell
@property (weak, nonatomic) id<EditTaskProtocol> editDelegate;
//- (void)setRepeatDay:(NSInteger)repeat;
- (void)initCellRepeatDay:(NSInteger)repeat;
@end
