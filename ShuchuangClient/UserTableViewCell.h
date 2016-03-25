//
//  UserTableViewCell.h
//  ShuchuangClient
//
//  Created by 黄建 on 3/21/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeOfValidityLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainOpenLabel;
@property (weak, nonatomic) IBOutlet UILabel *authLabel;

@end
