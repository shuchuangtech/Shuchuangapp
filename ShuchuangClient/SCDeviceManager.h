//
//  DeviceManager.h
//  ShuchuangClient
//
//  Created by 黄建 on 1/27/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCDeviceClient.h"
@interface SCDeviceManager : NSObject
+ (instancetype)instance;
- (void)loadDevicesForUser:(NSString *)username;
- (NSArray *)allDevices;
- (BOOL)addDevice:(NSString *)uuid;
- (void)removeDevice:(NSString *)uuid;
- (SCDeviceClient *)getDevice:(NSString *)uuid;
@end
