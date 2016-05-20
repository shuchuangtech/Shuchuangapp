//
//  AddTableViewCell2.h
//  ShuchuangClient
//
//  Created by 黄建 on 4/28/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuthorityChangeProtocol.h"

@interface AddTableViewCell2 : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *authLabel;
@property (weak, nonatomic) IBOutlet UIButton *authButton;
@property (nonatomic) NSInteger authority;
@property (weak, nonatomic) id<AuthorityChangeProtocol> authDelegate;
@end
