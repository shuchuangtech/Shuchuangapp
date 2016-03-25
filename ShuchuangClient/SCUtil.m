//
//  SCUtil.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/5/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//
#import "SCUtil.h"
#import <CommonCrypto/CommonDigest.h>
@implementation SCUtil
+(BOOL) validateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+(BOOL) validateMobile:(NSString *)mobile {
    NSString *mobileRegex = @"1[3|5|7|8][0-9]{9}";
    NSPredicate *mobileTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobileRegex];
    return [mobileTest evaluateWithObject:mobile];
}

+ (NSMutableString *) generateMD5Password:(NSString *)password withChallenge:(NSString *)challenge andPrefix:(NSString *)prefix {
    const char* pass_cStr = [password cStringUsingEncoding:NSUTF8StringEncoding];
    NSData * sha1passData = [NSData dataWithBytes:pass_cStr length:password.length];
    uint8_t sha1[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(sha1passData.bytes, (CC_LONG)sha1passData.length, sha1);
    NSMutableString * sha1pass = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [sha1pass appendFormat:@"%02x", sha1[i]];
    NSString * prefix_passwd = [[NSString alloc] initWithFormat:@"%@%@", prefix, sha1pass];
    const char* prefix_passwd_cStr = [prefix_passwd cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char md5[CC_MD5_DIGEST_LENGTH];
    CC_MD5(prefix_passwd_cStr, (CC_LONG)strlen(prefix_passwd_cStr), md5);
    NSMutableString * prefixpassmd5 = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [prefixpassmd5 appendFormat:@"%02x", md5[i]];
    }
    [prefixpassmd5 appendString:challenge];
    const char* prefixpassmd5_cStr = [prefixpassmd5 cStringUsingEncoding:NSUTF8StringEncoding];
    CC_MD5(prefixpassmd5_cStr, (CC_LONG)strlen(prefixpassmd5_cStr), md5);
    NSMutableString * outputString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i =0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [outputString appendFormat:@"%02x", md5[i]];
    }
    return outputString;
}

+ (NSMutableString *) generateSHA1String:(NSString *)content {
    const char* pass_cStr = [content cStringUsingEncoding:NSUTF8StringEncoding];
    NSData * sha1passData = [NSData dataWithBytes:pass_cStr length:content.length];
    uint8_t sha1[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(sha1passData.bytes, (CC_LONG)sha1passData.length, sha1);
    NSMutableString * sha1pass = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [sha1pass appendFormat:@"%02x", sha1[i]];
    return sha1pass;
}

+ (void)viewController:(UIViewController *)view showAlertTitle:(NSString *)title message:(NSString *)message action:(void (^)(UIAlertAction * alertAction))action {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:action];
    [alert addAction:defaultAction];
    [view presentViewController:alert animated:YES completion:nil];
}

+ (void)viewController:(UIViewController *)view showAlertTitle:(NSString *)title message:(NSString *)message yesAction:(void (^)(UIAlertAction * alertAction))yesAction noAction:(void (^)(UIAlertAction * alertAction))noAction {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * yAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:yesAction];
    UIAlertAction * nAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:noAction];
    [alert addAction:yAction];
    [alert addAction:nAction];
    [view presentViewController:alert animated:YES completion:nil];
}
@end
