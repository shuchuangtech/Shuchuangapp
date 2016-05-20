//
//  DeviceTableViewCell.h
//  ShuchuangClient
//
//  Created by 黄建 on 4/27/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *lockStateImg;
@property (weak, nonatomic) IBOutlet UILabel *netStateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *netStateImg;
@property (copy, nonatomic) NSString *uuid;
@end
