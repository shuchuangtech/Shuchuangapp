//
//  AddTableViewCell1.h
//  ShuchuangClient
//
//  Created by 黄建 on 4/28/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCTextField.h"
#import "ScanQRCodeProtocol.h"
@interface AddTableViewCell1 : UITableViewCell <ScanQRCodeProtocol>
@property (weak, nonatomic) IBOutlet UIButton *scanButton;
@property (weak, nonatomic) IBOutlet SCTextField *uuidTextField;

@end
