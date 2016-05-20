//
//  SCDeviceClient.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/26/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "SCDeviceClient.h"
#import "SCHTTPManager.h"
#import "SCUtil.h"
#import "SCErrorString.h"
#import "DeviceDAO.h"
#import "RPCDef.h"
#import "Bmob.h"
@interface SCDeviceClient()
@property (strong, nonatomic) NSString *token;
@property (weak, nonatomic) DeviceDAO *devDao;

- (void)updateDeviceInfo;
- (void)updateDeviceConfig:(NSDictionary *)config;
@end
@implementation SCDeviceClient
- (nonnull id)initWithId:(NSString *)uuid user:(NSString *)user name:(NSString *)name type:(NSString *)type token:(NSString *)token {
    self = [super init];
    self.uuid = uuid;
    self.user = user;
    self.name = name;
    self.type = type;
    self.token = token;
    self.devDao = [DeviceDAO instance];
    return self;
}

- (void)createDevice {
    [self.devDao insertDevice:self.uuid];
    NSDictionary *dict = @{DevNameStr:self.name, DevTypeStr:self.type, DevUserStr:self.user, DevIdStr:self.uuid};
    [self.devDao setDeviceInfo:dict token:self.token forDevice:self.uuid];
}

- (void)removeDevice {
    [self.devDao removeDevice:self.uuid];
}

- (void)updateDeviceName:(NSString *)name {
    self.name = name;
    [self updateDeviceInfo];
}

- (void)serverCheckSuccess:(void (^)(NSURLSessionDataTask * _Nullable, id _Nonnull))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    SCHTTPManager *http = [SCHTTPManager instance];
    NSDictionary *dict = @{KEY_TYPE_STR:@"request", KEY_ACTION_STR:@"server.check", KEY_PARAM_STR:@{@"uuid":self.uuid}};
    __weak SCDeviceClient *weakSelf = self;
    [http sendMessage:dict
              success:^(NSURLSessionDataTask *task, id serverResponse) {
                  NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
                  if ([serverResponse[KEY_RESULT_STR] isEqualToString:RESULT_GOOD_STR]) {
                      NSDictionary *param = serverResponse[KEY_PARAM_STR];
                      [response setValue:@"good" forKey:@"result"];
                      [response setValue:param[DEVICE_STATE_STR] forKey:DEVICE_STATE_STR];
                      if (param[REG_DEV_TYPE_STR] != nil) {
                          [response setValue:param[REG_DEV_TYPE_STR] forKey:REG_DEV_TYPE_STR];
                          weakSelf.type = param[REG_DEV_TYPE_STR];
                          [weakSelf updateDeviceInfo];
                      }
                  }
                  else {
                      NSString *detail = [SCErrorString errorString:serverResponse[KEY_DETAIL_STR]];
                      [response setValue:@"fail" forKey:@"result"];
                      [response setValue:detail forKey:@"detail"];
                  }
                  success(task, response);
              }
              failure:failure];
}

- (void)login:(nonnull NSString *)username password:(nonnull NSString *)password success:(void (^)(NSURLSessionDataTask * _Nullable, id _Nonnull))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    self.user = username;
    BmobUser *user = [BmobUser getCurrentUser];
    NSString *binduser = [user username];
    SCHTTPManager *http = [SCHTTPManager instance];
    NSString *action = [NSString stringWithFormat:@"%@.%@", COMPONENT_USER_STR, USER_METHOD_LOGIN];
    NSDictionary *dict = @{KEY_TYPE_STR:TYPE_REQUEST_STR, KEY_ACTION_STR:action, KEY_PARAM_STR:@{USER_USERNAME_STR:username, USER_UUID_STR:self.uuid, USER_BINDUSER_STR:binduser}};
    __weak SCDeviceClient *weakSelf = self;
    [http sendMessage:dict
                 success:^(NSURLSessionDataTask *task, id responseObject_step1) {
                     NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
                     if ([responseObject_step1[KEY_RESULT_STR] isEqualToString:RESULT_GOOD_STR]) {
                         NSDictionary * responseParam = responseObject_step1[KEY_PARAM_STR];
                         weakSelf.token = responseParam[REG_TOKEN_STR];
                         NSString * challenge = responseParam[USER_CHALLENGE_STR];
                         NSMutableString * passwordmd5 = [SCUtil generateMD5Password:password withChallenge:challenge andPrefix:@"login"];
                         NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
                         NSString *mobile_token;
                         if(userDef != nil) {
                             mobile_token = [userDef objectForKey:@"MobileToken"];
                             if (mobile_token == nil) {
                                 mobile_token = @"";
                             }
                         }
                         else {
                             mobile_token = @"";
                         }
                         NSDictionary * parameter2 = @{@"action":@"user.login", @"type":@"request", @"param":@{@"uuid":self.uuid, @"token":self.token, @"password":passwordmd5, @"username":username, @"binduser":binduser, @"mobiletoken":mobile_token}};
                         [http sendMessage:parameter2 success:^(NSURLSessionDataTask *task, id responseObject_step2) {
                             if([responseObject_step2[@"result"] isEqualToString:@"good"]) {
                                 [response setValue:@"good" forKey:@"result"];
                                 [weakSelf updateDeviceInfo];
                             }
                             else {
                                 NSString *detail = [SCErrorString errorString:responseObject_step2[@"detail"]];
                                 [response setValue:@"fail" forKey:@"result"];
                                 [response setValue:detail forKey:@"detail"];
                             }
                             success(task, response);
                         }
                        failure:failure];
                     }
                     else {
                         NSString *detail = [SCErrorString errorString:[responseObject_step1 objectForKey:@"detail"]];
                         [response setValue:@"fail" forKey:@"result"];
                         [response setValue:detail forKey:@"detail"];
                         success(task, response);
                     }
                 }
                 failure:failure];
}

- (void)logoutSuccess:(void (^)(NSURLSessionDataTask * _Nullable, id _Nonnull))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    SCHTTPManager *http = [SCHTTPManager instance];
    NSDictionary *dict = @{@"type":@"request", @"action":@"user.logout", @"param":@{@"uuid":self.uuid, @"token":self.token}};
    [http sendMessage:dict success:^(NSURLSessionDataTask* task, id serverResponse) {
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        if ([serverResponse[@"result"] isEqualToString:@"good"]) {
            [response setValue:@"good" forKey:@"result"];
        }
        else {
            NSString *detail = [SCErrorString errorString:serverResponse[@"detail"]];
            [response setValue:@"fail" forKey:@"result"];
            [response setValue:detail forKey:@"detail"];
        }
        success(task, response);
    } failure:failure];
}

- (void)changeOldPassword:(NSString *)oldPassword newPassword:(NSString *)newpassword success:(void (^)(NSURLSessionDataTask * _Nullable, id _Nonnull))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    NSDictionary *dict_step1 = @{@"type":@"request", @"action":@"user.passwd", @"param":@{@"uuid":self.uuid, @"token":self.token}};
    SCHTTPManager *http = [SCHTTPManager instance];
    __weak SCDeviceClient *weakSelf = self;
    [http sendMessage:dict_step1 success:^(NSURLSessionDataTask *task, id response_step1) {
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        if ([response_step1[@"result"] isEqualToString:@"good"]) {
            NSDictionary *param_response = [response_step1 objectForKey:@"param"];
            NSString *challenge = param_response[@"challenge"];
            NSMutableString *challengemd5pass = [SCUtil generateMD5Password:oldPassword withChallenge:challenge andPrefix:@"passwd"];
            NSDictionary *dict_step2 = @{@"type":@"request", @"action":@"user.passwd", @"param":@{@"uuid":weakSelf.uuid, @"token":weakSelf.token, @"password":challengemd5pass, @"newpassword":[SCUtil generateSHA1String:newpassword]}};
            [http sendMessage:dict_step2
                      success:^(NSURLSessionDataTask *task, id response_step2) {
                          if ([response_step2[@"result"] isEqualToString:@"good"]) {
                              [response setValue:@"good" forKey:@"result"];
                          }
                          else {
                              NSString *detail = [[NSString alloc] initWithFormat:@"修改设备密码失败！%@", [SCErrorString errorString:response_step2[@"detail"]]];
                              [response setValue:@"fail" forKey:@"result"];
                              [response setValue:detail forKey:@"detail"];
                          }
                          success(task, response);
                      }
                      failure:failure];
        }
        else {
            NSString *detail = [SCErrorString errorString:response_step1[@"detail"]];
            [response setValue:@"fail" forKey:@"result"];
            [response setValue:detail forKey:@"detail"];
            success(task, response);
        }
    }
    failure:failure];
}

- (void)addUser:(NSDictionary *)user success:(void (^)(NSURLSessionDataTask * _Nullable, id _Nonnull))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    SCHTTPManager* http = [SCHTTPManager instance];
    NSString *action = [NSString stringWithFormat:@"%@.%@", COMPONENT_USER_STR, USER_METHOD_ADD];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] initWithDictionary:user];
    [param setObject:self.uuid forKey:REG_UUID_STR];
    [param setObject:self.token forKey:REG_TOKEN_STR];
    NSDictionary *dict = @{KEY_TYPE_STR:TYPE_REQUEST_STR, KEY_ACTION_STR:action, KEY_PARAM_STR:param};
    [http sendMessage:dict success:^(NSURLSessionDataTask* task, id serverResponse) {
        NSMutableDictionary* response = [[NSMutableDictionary alloc] init];
        if ([serverResponse[@"result"] isEqualToString:@"good"]) {
            [response setObject:@"good" forKey:@"result"];
        }
        else {
            NSString *detail = [SCErrorString errorString:serverResponse[@"detail"]];
            [response setValue:@"fail" forKey:@"result"];
            [response setValue:detail forKey:@"detail"];
        }
        success(task, response);
    } failure:failure];
}

- (void)deleteUser:(NSString *)username success:(void (^)(NSURLSessionDataTask * _Nullable, id _Nonnull))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    SCHTTPManager* http = [SCHTTPManager instance];
    NSString *action = [NSString stringWithFormat:@"%@.%@", COMPONENT_USER_STR, USER_METHOD_DELETE];
    NSDictionary* dict = @{KEY_TYPE_STR:TYPE_REQUEST_STR, KEY_ACTION_STR:action, KEY_PARAM_STR:@{REG_UUID_STR:self.uuid, REG_TOKEN_STR:self.token, USER_USERNAME_STR:username}};
    [http sendMessage:dict success:^(NSURLSessionDataTask* task, id serverResponse) {
        NSMutableDictionary* response = [[NSMutableDictionary alloc] init];
        if ([serverResponse[@"result"] isEqualToString:@"good"]) {
            [response setObject:@"good" forKey:@"result"];
        }
        else {
            NSString *detail = [SCErrorString errorString:serverResponse[@"detail"]];
            [response setValue:@"fail" forKey:@"result"];
            [response setValue:detail forKey:@"detail"];
        }
        success(task, response);
    } failure:failure];
}

- (void)topupUser:(NSDictionary *)user success:(void (^)(NSURLSessionDataTask * _Nullable, id _Nonnull))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    SCHTTPManager* http = [SCHTTPManager instance];
    NSString *action = [NSString stringWithFormat:@"%@.%@", COMPONENT_USER_STR, USER_METHOD_TOPUP];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] initWithDictionary:user];
    [param setObject:self.uuid forKey:REG_UUID_STR];
    [param setObject:self.token forKey:REG_TOKEN_STR];
    NSDictionary *dict = @{KEY_TYPE_STR:TYPE_REQUEST_STR, KEY_ACTION_STR:action, KEY_PARAM_STR:param};
    [http sendMessage:dict success:^(NSURLSessionDataTask* task, id serverResponse) {
        NSMutableDictionary* response = [[NSMutableDictionary alloc] init];
        if ([serverResponse[@"result"] isEqualToString:@"good"]) {
            [response setObject:@"good" forKey:@"result"];
        }
        else {
            NSString *detail = [SCErrorString errorString:serverResponse[@"detail"]];
            [response setValue:@"fail" forKey:@"result"];
            [response setValue:detail forKey:@"detail"];
        }
        success(task, response);
    } failure:failure];
}

- (void)getUsers:(NSDictionary *)condition success:(void (^)(NSURLSessionDataTask * _Nullable, id _Nonnull))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    SCHTTPManager *http = [SCHTTPManager instance];
    NSString *action = [NSString stringWithFormat:@"%@.%@", COMPONENT_USER_STR, USER_METHOD_LIST];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] initWithDictionary:condition];
    [param setObject:self.token forKey:REG_TOKEN_STR];
    [param setObject:self.uuid forKey:REG_UUID_STR];
    NSDictionary *dict = @{KEY_TYPE_STR:TYPE_REQUEST_STR, KEY_ACTION_STR:action, KEY_PARAM_STR:param};
    [http sendMessage:dict success:^(NSURLSessionDataTask *task, id serverResponse) {
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        if ([serverResponse[@"result"] isEqualToString:@"good"]) {
            [response setObject:@"good" forKey:@"result"];
            NSDictionary *param = serverResponse[@"param"];
            [response setObject:param[@"Users"] forKey:@"Users"];
        }
        else {
            NSString *detail = [SCErrorString errorString:serverResponse[@"detail"]];
            [response setValue:@"fail" forKey:@"result"];
            [response setValue:detail forKey:@"detail"];
        }
        success(task, response);
    } failure:failure];
}

- (void)checkDoorSuccess:(void (^)(NSURLSessionDataTask * _Nullable, id _Nonnull))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    SCHTTPManager *http = [SCHTTPManager instance];
    NSDictionary *dict = @{@"type":@"request", @"action":@"device.check", @"param":@{@"uuid":self.uuid, @"token":self.token}};
    __weak SCDeviceClient *weakSelf = self;
    [http sendMessage:dict
              success:^(NSURLSessionDataTask *task, id serverResponse) {
                  NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
                  if ([[serverResponse objectForKey:@"result"] isEqualToString:@"good"]) {
                      NSDictionary *param = [serverResponse objectForKey:@"param"];
                      [response setValue:param[@"state"] forKey:@"state"];
                      if ([response[@"state"] isEqualToString:@"close"]) {
                          weakSelf.doorClose = YES;
                      }
                      else {
                          weakSelf.doorClose = NO;
                      }
                      [response setValue:param[@"switch"] forKey:@"switch"];
                      if ([response[@"switch"] isEqualToString:@"close"]) {
                          weakSelf.switchClose = YES;
                      }
                      else {
                          weakSelf.switchClose = NO;
                      }
                      [response setValue:@"good" forKey:@"result"];
                      weakSelf.online = YES;
                  }
                  else {
                      NSString *detail = [SCErrorString errorString:serverResponse[@"detail"]];
                      [response setValue:@"fail" forKey:@"result"];
                      [response setValue:detail forKey:@"detail"];
                      weakSelf.online = NO;
                      weakSelf.switchClose = NO;
                      weakSelf.doorClose = NO;
                  }
                  success(task, response);
              }
              failure:failure];
}

- (void)openDoorSuccess:(void (^)(NSURLSessionDataTask * _Nullable, id _Nonnull))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    SCHTTPManager *http = [SCHTTPManager instance];
    NSDictionary *dict = @{@"type":@"request", @"action":@"device.open", @"param":@{@"uuid":self.uuid, @"token":self.token}};
    [http sendMessage:dict
              success:^(NSURLSessionDataTask *task, id serverResponse) {
                  NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
                  if ([serverResponse[@"result"] isEqualToString:@"good"]) {
                      [response setValue:@"good" forKey:@"result"];
                  }
                  else {
                      NSString *detail = [SCErrorString errorString:serverResponse[@"detail"]];
                      [response setValue:@"fail" forKey:@"result"];
                      [response setValue:detail forKey:@"detail"];
                  }
                  success(task, response);
              }
              failure:failure];
}

- (void)closeDoorSuccess:(void (^)(NSURLSessionDataTask * _Nullable, id _Nonnull))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    SCHTTPManager *http = [SCHTTPManager instance];
    NSDictionary *dict = @{@"type":@"request", @"action":@"device.close", @"param":@{@"uuid":self.uuid, @"token":self.token}};
    [http sendMessage:dict
              success:^(NSURLSessionDataTask *task, id serverResponse) {
                  NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
                  if ([serverResponse[@"result"] isEqualToString:@"good"]) {
                      [response setValue:@"good" forKey:@"result"];
                  }
                  else {
                      NSString *detail = [SCErrorString errorString:serverResponse[@"detail"]];
                      [response setValue:@"fail" forKey:@"result"];
                      [response setValue:detail forKey:@"detail"];
                  }
                  success(task, response);
              }
              failure:failure];
}

- (void)getDeviceModeSuccess:(void (^)(NSURLSessionDataTask * _Nullable, id _Nonnull))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    SCHTTPManager *http = [SCHTTPManager instance];
    NSDictionary *dict = @{@"type":@"request", @"action":@"device.getmode", @"param":@{@"uuid":self.uuid, @"token":self.token}};
    self.mode = -1;
    [http sendMessage:dict
              success:^(NSURLSessionDataTask *task, id serverResponse) {
                  NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
                  if ([serverResponse[@"result"] isEqualToString:@"good"]) {
                      [response setValue:@"good" forKey:@"result"];
                      [response setValue:serverResponse[@"param"][@"mode"] forKey:@"mode"];
                      self.mode = [serverResponse[@"param"][@"mode"] integerValue];
                  }
                  else {
                      NSString *detail = [SCErrorString errorString:serverResponse[@"detail"]];
                      [response setValue:@"fail" forKey:@"result"];
                      [response setValue:detail forKey:@"detail"];
                  }
                  success(task, response);
              }
              failure:failure];
}

- (void)changeDeviceMode:(NSInteger)mode success:(void (^)(NSURLSessionDataTask * _Nullable, id _Nonnull))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    SCHTTPManager *http = [SCHTTPManager instance];
    NSDictionary *dict = @{@"type":@"request", @"action":@"device.chmode", @"param":@{@"uuid":self.uuid, @"token":self.token, @"mode":[NSNumber numberWithInteger:mode]}};
    [http sendMessage:dict
              success:^(NSURLSessionDataTask *task, id serverResponse) {
                  NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
                  if ([serverResponse[@"result"] isEqualToString:@"good"]) {
                      [response setValue:@"good" forKey:@"result"];
                      self.mode = mode;
                  }
                  else {
                      NSString *detail = [SCErrorString errorString:serverResponse[@"detail"]];
                      [response setValue:@"fail" forKey:@"result"];
                      [response setValue:detail forKey:@"detail"];
                  }
                  success(task, response);
              }
              failure:failure];
}

- (void)getTasksSuccess:(void (^)(NSURLSessionDataTask * _Nullable, id _Nonnull))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    SCHTTPManager *http = [SCHTTPManager instance];
    NSString *action = [NSString stringWithFormat:@"%@.%@", COMPONENT_TASK_STR, TASK_METHOD_LIST];
    NSDictionary *dict = @{KEY_TYPE_STR:TYPE_REQUEST_STR, KEY_ACTION_STR:action, KEY_PARAM_STR:@{@"uuid":self.uuid, @"token":self.token}};
    __weak SCDeviceClient *weakSelf = self;
    [http sendMessage:dict
              success:^(NSURLSessionDataTask *task, id serverResponse) {
                  NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
                  if ([serverResponse[@"result"] isEqualToString:@"good"]) {
                      NSDictionary *param = serverResponse[@"param"];
                      [response setValue:@"good" forKey:@"result"];
                      NSArray *taskArr = param[@"tasks"];
                      if (taskArr != nil) {
                          [response setObject:taskArr forKey:@"tasks"];
                          [weakSelf.devDao setTasks:taskArr forDevice:weakSelf.uuid];
                      }
                  }
                  else {
                      NSString *detail = [SCErrorString errorString:serverResponse[@"detail"]];
                      [response setValue:@"fail" forKey:@"result"];
                      [response setValue:detail forKey:@"detail"];
                  }
                  success(task, response);
              }
              failure:failure];
}

- (void)addTask:(NSDictionary *)task success:(void (^)(NSURLSessionDataTask * _Nullable, id _Nonnull))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    SCHTTPManager *http = [SCHTTPManager instance];
    NSString *action = [NSString stringWithFormat:@"%@.%@", COMPONENT_TASK_STR, TASK_METHOD_ADD];
    NSDictionary *dict = @{KEY_TYPE_STR:TYPE_REQUEST_STR, KEY_ACTION_STR:action, KEY_PARAM_STR:@{REG_TOKEN_STR:self.token, REG_UUID_STR:self.uuid, @"task":task}};
    __weak SCDeviceClient *weakSelf = self;
    [http sendMessage:dict success:^(NSURLSessionDataTask *dataTask, id serverResponse){
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        if ([serverResponse[KEY_RESULT_STR] isEqualToString:RESULT_GOOD_STR]) {
            [response setValue:@"good" forKey:@"result"];
            [response setValue:serverResponse[@"param"][@"task"][@"id"] forKey:@"id"];
            NSMutableDictionary *setTask = [[NSMutableDictionary alloc] initWithDictionary:task];
            [setTask setValue:serverResponse[@"param"][@"task"][@"id"] forKey:@"id"];
            [weakSelf.devDao addTask:setTask forDevice:weakSelf.uuid];
        }
        else {
            NSString *detail = [SCErrorString errorString:serverResponse[@"detail"]];
            [response setValue:@"fail" forKey:@"result"];
            [response setValue:detail forKey:@"detail"];
        }
        success(dataTask, response);
    } failure:failure];
}

- (void)removeTask:(NSInteger)taskId atIndex:(NSInteger)index success:(void (^)(NSURLSessionDataTask * _Nullable, id _Nonnull))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    SCHTTPManager *http = [SCHTTPManager instance];
    NSString *action = [NSString stringWithFormat:@"%@.%@", COMPONENT_TASK_STR, TASK_METHOD_REMOVE];
    NSDictionary *dict = @{KEY_TYPE_STR:TYPE_REQUEST_STR, KEY_ACTION_STR:action, KEY_PARAM_STR:@{REG_TOKEN_STR:self.token, REG_UUID_STR:self.uuid, @"task":@{@"id":[NSNumber numberWithInteger:taskId]}}};
    __weak SCDeviceClient *weakSelf = self;
    [http sendMessage:dict success:^(NSURLSessionDataTask *dataTask, id serverResponse){
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        if ([serverResponse[KEY_RESULT_STR] isEqualToString:RESULT_GOOD_STR]) {
            [response setValue:@"good" forKey:@"result"];
            [weakSelf.devDao removeTask:index forDevice:weakSelf.uuid];
        }
        else {
            NSString *detail = [SCErrorString errorString:serverResponse[@"detail"]];
            [response setValue:@"fail" forKey:@"result"];
            [response setValue:detail forKey:@"detail"];
        }
        success(dataTask, response);
    } failure:failure];
}

- (void)updateTask:(NSDictionary *)task atIndex:(NSInteger)index success:(void (^)(NSURLSessionDataTask * _Nullable, id _Nonnull))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    SCHTTPManager *http = [SCHTTPManager instance];
    NSString *action = [NSString stringWithFormat:@"%@.%@", COMPONENT_TASK_STR, TASK_METHOD_MODIFY];
    NSDictionary *dict = @{KEY_TYPE_STR:TYPE_REQUEST_STR, KEY_ACTION_STR:action, KEY_PARAM_STR:@{REG_TOKEN_STR:self.token, REG_UUID_STR:self.uuid, @"task":task}};
    __weak SCDeviceClient *weakSelf = self;
    [http sendMessage:dict success:^(NSURLSessionDataTask *dataTask, id serverResponse){
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        if ([serverResponse[KEY_RESULT_STR] isEqualToString:RESULT_GOOD_STR]) {
            [response setValue:@"good" forKey:@"result"];
            [weakSelf.devDao updateTask:task forDevice:weakSelf.uuid atIndex:index];
        }
        else {
            NSString *detail = [SCErrorString errorString:serverResponse[@"detail"]];
            [response setValue:@"fail" forKey:@"result"];
            [response setValue:detail forKey:@"detail"];
        }
        success(dataTask, response);
    } failure:failure];
}

- (void)getRecord:(NSDictionary *)condition success:(void (^)(NSURLSessionDataTask * _Nullable, id _Nonnull))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    SCHTTPManager *http = [SCHTTPManager instance];
    NSString *action = [NSString stringWithFormat:@"%@.%@", COMPONENT_RECORD_STR, RECORD_METHOD_GET];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] initWithDictionary:condition];
    [param setObject:self.token forKey:REG_TOKEN_STR];
    [param setObject:self.uuid forKey:REG_UUID_STR];
    NSDictionary *dict = @{KEY_TYPE_STR:TYPE_REQUEST_STR, KEY_ACTION_STR:action, KEY_PARAM_STR:param};
    [http sendMessage:dict success:^(NSURLSessionDataTask *task, id serverResponse) {
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        if ([serverResponse[@"result"] isEqualToString:@"good"]) {
            [response setObject:@"good" forKey:@"result"];
            NSDictionary *param = serverResponse[@"param"];
            [response setObject:param[@"records"] forKey:@"records"];
        }
        else {
            NSString *detail = [SCErrorString errorString:serverResponse[@"detail"]];
            [response setValue:@"fail" forKey:@"result"];
            [response setValue:detail forKey:@"detail"];
        }
        success(task, response);
    } failure:failure];
}

- (void)resetDeviceSuccess:(void (^)(NSURLSessionDataTask * _Nullable, id _Nonnull))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    SCHTTPManager *http = [SCHTTPManager instance];
    NSString *action = [NSString stringWithFormat:@"%@.%@", COMPONENT_SYSTEM_STR, SYSTEM_METHOD_RESET];
    NSDictionary* param = @{REG_UUID_STR:self.uuid, REG_TOKEN_STR:self.token};
    NSDictionary* dict = @{KEY_TYPE_STR:TYPE_REQUEST_STR, KEY_ACTION_STR:action, KEY_PARAM_STR:param};
    [http sendMessage:dict success:^(NSURLSessionDataTask *dataTask, id serverResponse){
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        if ([serverResponse[KEY_RESULT_STR] isEqualToString:RESULT_GOOD_STR]) {
            [response setValue:@"good" forKey:@"result"];
        }
        else {
            NSString *detail = [SCErrorString errorString:serverResponse[@"detail"]];
            [response setValue:@"fail" forKey:@"result"];
            [response setValue:detail forKey:@"detail"];
        }
        success(dataTask, response);
    } failure:failure];

}

- (void)checkDeviceVersionSuccess:(void (^)(NSURLSessionDataTask * _Nullable, id _Nonnull))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    SCHTTPManager *http = [SCHTTPManager instance];
    NSString* action = [NSString stringWithFormat:@"%@.%@", COMPONENT_SYSTEM_STR, SYSTEM_METHOD_VERSION];
    NSDictionary* param = @{REG_UUID_STR:self.uuid, REG_TOKEN_STR:self.token};
    NSDictionary* dict = @{KEY_TYPE_STR:TYPE_REQUEST_STR, KEY_ACTION_STR:action, KEY_PARAM_STR:param};
    [http sendMessage:dict success:^(NSURLSessionDataTask *dataTask, id serverResponse){
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        if ([serverResponse[KEY_RESULT_STR] isEqualToString:RESULT_GOOD_STR]) {
            [response setValue:@"good" forKey:@"result"];
            [response setValue:serverResponse[@"param"] forKey:@"param"];
        }
        else {
            NSString *detail = [SCErrorString errorString:serverResponse[@"detail"]];
            [response setValue:@"fail" forKey:@"result"];
            [response setValue:detail forKey:@"detail"];
        }
        success(dataTask, response);
    } failure:failure];
}

- (void)checkServerVersionSuccess:(void (^)(NSURLSessionDataTask * _Nullable, id _Nonnull))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    SCHTTPManager *http = [SCHTTPManager instance];
    NSString* action = [NSString stringWithFormat:@"%@.%@", COMPONENT_UPDATE_STR, UPDATE_METHOD_CHECK];
    NSDictionary* param = @{REG_UUID_STR:self.uuid, REG_DEV_TYPE_STR:self.type};
    NSDictionary* dict = @{KEY_TYPE_STR:TYPE_REQUEST_STR, KEY_ACTION_STR:action, KEY_PARAM_STR:param};
    [http sendMessage:dict success:^(NSURLSessionDataTask *dataTask, id serverResponse){
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        if ([serverResponse[KEY_RESULT_STR] isEqualToString:RESULT_GOOD_STR]) {
            [response setValue:@"good" forKey:@"result"];
            [response setValue:serverResponse[@"param"] forKey:@"param"];
        }
        else {
            NSString *detail = [SCErrorString errorString:serverResponse[@"detail"]];
            [response setValue:@"fail" forKey:@"result"];
            [response setValue:detail forKey:@"detail"];
        }
        success(dataTask, response);
    } failure:failure];
}

- (void)updateDeviceTo:(NSString *)version success:(void (^)(NSURLSessionDataTask * _Nullable, id _Nonnull))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    SCHTTPManager *http = [SCHTTPManager instance];
    NSString* action = [NSString stringWithFormat:@"%@.%@", COMPONENT_SYSTEM_STR, SYSTEM_METHOD_UPDATE];
    NSDictionary* param = @{REG_UUID_STR:self.uuid, REG_TOKEN_STR:self.token, SYSTEM_VERSION_STR:version};
    NSDictionary* dict = @{KEY_TYPE_STR:TYPE_REQUEST_STR, KEY_ACTION_STR:action, KEY_PARAM_STR:param};
    [http sendMessage:dict success:^(NSURLSessionDataTask *dataTask, id serverResponse){
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        if ([serverResponse[KEY_RESULT_STR] isEqualToString:RESULT_GOOD_STR]) {
            [response setValue:@"good" forKey:@"result"];
        }
        else {
            NSString *detail = [SCErrorString errorString:serverResponse[@"detail"]];
            [response setValue:@"fail" forKey:@"result"];
            [response setValue:detail forKey:@"detail"];
        }
        success(dataTask, response);
    } failure:failure];
}

- (void)updateDeviceInfo {
    NSDictionary *dict = @{DevNameStr:self.name, DevTypeStr:self.type, DevUserStr:self.user, DevIdStr:self.uuid};
    [self.devDao setDeviceInfo:dict token:self.token forDevice:self.uuid];
}

- (void)updateDeviceConfig:(NSDictionary *)config {
    
}

- (NSArray *)getLocalTasks {
    return [self.devDao getTasks:self.uuid];
}

- (void)clearLocalTasks {
    [self.devDao clearTasksForDevice:self.uuid];
}

@end
