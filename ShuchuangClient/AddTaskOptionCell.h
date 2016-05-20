//
//  AddTaskOptionCell.h
//  ShuchuangClient
//
//  Created by 黄建 on 5/13/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditTaskProtocol.h"
@interface AddTaskOptionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *swButton;
@property (weak, nonatomic) IBOutlet UILabel *swLabel;
@property (weak, nonatomic) id<EditTaskProtocol> editDelegate;

- (void)initCellOption:(NSInteger)option;
@end
