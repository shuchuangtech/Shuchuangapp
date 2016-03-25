//
//  SCUtil.h
//  ShuchuangClient
//
//  Created by 黄建 on 1/5/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#ifndef SCUtil_h
#define SCUtil_h
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface SCUtil : NSObject
+ (BOOL)validateEmail:(NSString *)email;
+ (BOOL)validateMobile:(NSString *)mobile;
+ (NSMutableString *) generateMD5Password:(NSString *) password withChallenge:(NSString *) challenge andPrefix:(NSString *) prefix;
+ (NSMutableString *) generateSHA1String:(NSString *)content;
//ios8+ api
+ (void)viewController:(UIViewController *)view showAlertTitle:(NSString *)title message:(NSString *)message action:(void (^)(UIAlertAction * alertAction))action;
+ (void)viewController:(UIViewController *)view showAlertTitle:(NSString *)title message:(NSString *)message yesAction:(void (^)(UIAlertAction * alertAction))yesAction noAction:(void (^)(UIAlertAction * alertAction))noAction;
//ios8- api
@end
#endif /* SCUtil_h */
