//
//  DeviceDAO.h
//  ShuchuangClient
//
//  Created by 黄建 on 1/15/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString * _Nonnull const DevNameStr;
extern NSString * _Nonnull const DevTypeStr;
extern NSString * _Nonnull const DevTokenStr;
extern NSString * _Nonnull const DevUserStr;
extern NSString * _Nonnull const DevIdStr;
@interface DeviceDAO : NSObject
+ (nonnull instancetype)instance;
//interface for device manager
- (BOOL)setUser:(nonnull NSString *)username;
- (void)loadDeviceList;
- (nonnull NSArray *)allDevices;
- (void)insertDevice:(nonnull NSString *)uuid;
- (void)removeDevice:(nonnull NSString *)uuid;

//interface for device client
- (void)setDeviceInfo:(nonnull NSDictionary *)dict token:(nonnull NSString *)token forDevice:(nonnull NSString *)uuid;
- (nonnull NSDictionary *)getDeviceInfo:(nonnull NSString *)uuid;

- (nullable NSArray *)getTasks:(nonnull NSString *)uuid;
- (void)setTasks:(nonnull NSArray *)task forDevice:(nonnull NSString *)uuid;
- (void)addTask:(nonnull NSDictionary *)task forDevice:(nonnull NSString *)uuid;
- (void)removeTask:(NSInteger)index forDevice:(nonnull NSString *)uuid;
- (void)updateTask:(nonnull NSDictionary *)task forDevice:(nonnull NSString *)uuid atIndex:(NSInteger)index;

- (nonnull NSDictionary *)getConfig:(nonnull NSString *)uuid;
- (void)setConfig:(nonnull NSDictionary *)config forDevice:(nonnull NSString *)uuid;
@end
