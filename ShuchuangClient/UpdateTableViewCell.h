//
//  UpdateTableViewCell.h
//  ShuchuangClient
//
//  Created by 黄建 on 3/29/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpdateTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *myImageView;
@property (weak, nonatomic) IBOutlet UILabel *myTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *myDetailTextLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstr;
@property (copy, nonatomic) NSString* featureString;
@property (weak, nonatomic) IBOutlet UILabel *featureLabel;
@property (weak, nonatomic) IBOutlet UIButton *buttonUpdate;


@end
