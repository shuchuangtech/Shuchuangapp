//
//  SCErrorString.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/22/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "SCErrorString.h"

@implementation SCErrorString
+ (NSString *)errorString:(NSString *)code {
    NSString *detail;
    switch ([code integerValue]) {
        case 100:
            detail = @"请求格式不是JSON";
            break;
        case 101:
            detail = @"请求参数格式错误";
            break;
        case 102:
            detail = @"请求类型错误";
            break;
        case 103:
            detail = @"param参数不是JSON格式";
            break;
        case 104:
            detail = @"param参数不全";
            break;
        case 105:
            detail = @"action格式错误";
            break;
        case 200:
            detail = @"组件component错误";
            break;
        case 201:
            detail = @"组件method错误";
            break;
        case 300:
            detail = @"服务器密钥校验失败";
            break;
        case 401:
            detail = @"token参数缺失";
            break;
        case 402:
            detail = @"token不合法";
            break;
        case 410:
            detail = @"用户名缺失";
            break;
        case 411:
            detail = @"用户不存在";
            break;
        case 412:
            detail = @"用户已过期";
            break;
        case 413:
            detail = @"token参数缺失";
            break;
        case 414:
            detail = @"token错误";
            break;
        case 415:
            detail = @"密码参数缺失";
            break;
        case 416:
            detail = @"密码不匹配";
            break;
        case 417:
            detail = @"新密码缺失";
            break;
        case 419:
            detail = @"未知错误";
            break;
        case 420:
            detail = @"设备描述文件打开失败";
            break;
        case 430:
            detail = @"任务数已满";
            break;
        case 431:
            detail = @"任务参数缺失";
            break;
        case 432:
            detail = @"任务参数不齐全";
            break;
        case 433:
            detail = @"任务参数不合法";
            break;
        case 434:
            detail = @"任务已存在";
            break;
        case 435:
            detail = @"任务不存在";
            break;
        case 440:
            detail = @"缺少起止时间";
            break;
        case 441:
            detail = @"数据库查询出错";
        default:
            detail = code;
            break;
    }
    return detail;
}
@end
