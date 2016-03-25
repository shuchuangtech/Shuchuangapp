//
//  SetPasswordViewController.h
//  ShuchuangClient
//
//  Created by 黄建 on 1/6/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetPasswordViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) NSString *phoneNumber;
@property (weak, nonatomic) NSString *email;
@property (weak, nonatomic) NSString *SMSCode;
@property (nonatomic) BOOL registerNewUser;
@end
