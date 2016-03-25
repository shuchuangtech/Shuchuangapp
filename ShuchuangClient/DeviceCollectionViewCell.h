//
//  DeviceCollectionViewCell.h
//  ShuchuangClient
//
//  Created by 黄建 on 1/12/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *lockImg;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) NSString *uuid;
- (void)startEdit:(BOOL)small;
- (void)stopEdit;
@end
