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
        case 106:
            detail = @"method方法错误";
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
        case 400:
            detail = @"param参数不齐全";
            break;
        case 401:
            detail = @"token参数缺失";
            break;
        case 402:
            detail = @"用户身份不合法或者登录已失效";
            break;
        case 403:
            detail = @"没有权限的操作";
            break;
        case 410:
            detail = @"用户已存在";
            break;
        case 411:
            detail = @"用户不存在";
            break;
        case 412:
            detail = @"用户无权限操作";
            break;
        case 413:
            detail = @"添加用户失败";
            break;
        case 414:
            detail = @"删除用户失败";
            break;
        case 415:
            detail = @"用户数据查询出错";
            break;
        case 416:
            detail = @"密码不匹配";
            break;
        case 417:
            detail = @"充值用户失败";
            break;
        case 418:
            detail = @"设备已被其他用户绑定";
            break;
        case 419:
            detail = @"未知错误";
            break;
        case 420:
            detail = @"设备描述文件打开失败";
            break;
        case 421:
            detail = @"用户无权限开门";
            break;
        case 422:
            detail = @"当前操作需要管理员身份";
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
            break;
        case 450:
            detail = @"缺少设备类型参数";
            break;
        case 451:
            detail = @"设备类型错误，找不到更新程序";
            break;
        case 452:
            detail = @"服务器错误";
            break;
        case 453:
            detail = @"升级信息获取失败";
            break;
        case 460:
            detail = @"配置恢复默认失败";
            break;
        case 461:
            detail = @"用户数据恢复失败";
            break;
        case 462:
            detail = @"操作记录清除失败";
            break;
        case 463:
            detail = @"设备正在升级";
            break;
        case 464:
            detail = @"设备升级参数缺失";
            break;
        default:
            detail = code;
            break;
    }
    return detail;
}
@end
