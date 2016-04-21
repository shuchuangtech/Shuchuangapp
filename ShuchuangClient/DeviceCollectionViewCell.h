//
//  DeviceCollectionViewCell.h
//  ShuchuangClient
//
//  Created by 黄建 on 1/12/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeleteDeviceProtocol.h"
@interface DeviceCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *lockImg;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) NSString *uuid;
@property (weak, nonatomic) id<DeleteDeviceProtocol> deleteDelegate;
- (void)startEdit:(BOOL)small;
- (void)stopEdit;
@end
