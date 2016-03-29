//
//  SCDeviceClient.h
//  ShuchuangClient
//
//  Created by 黄建 on 1/26/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface SCDeviceClient : NSObject
@property (strong, nonatomic) NSString * _Nonnull uuid;
@property (strong, nonatomic) NSString * _Nonnull name;
@property (strong, nonatomic) NSString * _Nonnull type;
@property (nonatomic) BOOL doorClose;
@property (nonatomic) BOOL switchClose;

- (nonnull id)initWithId:(nonnull NSString *)uuid user:(nonnull NSString *)user name:(nonnull NSString *)name type:(nonnull NSString *)type token:(nonnull NSString *)token;

- (void)createDevice;

- (void)removeDevice;

- (void)updateDeviceName:(nonnull NSString *)name;

- (void)serverCheckSuccess:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nonnull responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

//user option
- (void)login:(nonnull NSString *)username password:(nonnull NSString *)password success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nonnull responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

- (void)logoutSuccess:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nonnull responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

- (void)changeOldPassword:(nonnull NSString *)oldPassword newPassword:(nonnull NSString *)newpassword success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nonnull responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

- (void)addUser:(nonnull NSDictionary*)user success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nonnull responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

- (void)getUsers:(NSDictionary * _Nonnull)condition success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nonnull responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *   _Nonnull error))failure;

- (void)deleteUser:(nonnull NSString*)username success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nonnull responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *   _Nonnull error))failure;

- (void)topupUser:(nonnull NSDictionary*)user success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nonnull responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *   _Nonnull error))failure;

//door option
- (void)checkDoorSuccess:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nonnull responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

- (void)openDoorSuccess:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nonnull responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

- (void)closeDoorSuccess:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nonnull responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

//task option
- (void)getTasksSuccess:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nonnull responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *   _Nonnull error))failure;

- (void)addTask:(NSDictionary * _Nonnull)task success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nonnull responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *   _Nonnull error))failure;

- (void)removeTask:(NSInteger)taskId atIndex:(NSInteger)index success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nonnull responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *   _Nonnull error))failure;

- (void)updateTask:(NSDictionary * _Nonnull)task atIndex:(NSInteger)index success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nonnull responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *   _Nonnull error))failure;

//record option
- (void)getRecord:(NSDictionary * _Nonnull)condition success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nonnull responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *   _Nonnull error))failure;

//device system option
- (void)resetDeviceSuccess:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nonnull responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *   _Nonnull error))failure;

- (void)checkDeviceVersionSuccess:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nonnull responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *   _Nonnull error))failure;

- (void)checkServerVersionSuccess:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nonnull responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *   _Nonnull error))failure;

- (void)updateDeviceTo:(nonnull NSString*)version success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nonnull responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *   _Nonnull error))failure;

- (nullable NSArray *)getLocalTasks;

- (void)clearLocalTasks;

@end
