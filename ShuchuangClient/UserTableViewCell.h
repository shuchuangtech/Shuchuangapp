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
@property (weak, nonatomic) IBOutlet UILabel *remainOpenTag;
@property (weak, nonatomic) IBOutlet UILabel *remainOpenTag2;
@property (weak, nonatomic) IBOutlet UILabel *timeTag;


- (void)setUsername:(NSString *)username authority:(NSInteger)auth remainOpen:(NSInteger)remainOpen timeOfValidity:(NSString *)time remainOpenInvalid:(BOOL)openInvalid timeInvalid:(BOOL)timeInvalid;
@end
