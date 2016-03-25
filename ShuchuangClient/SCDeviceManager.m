//
//  DeviceManager.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/27/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "SCDeviceManager.h"
#import "DeviceDAO.h"
@interface SCDeviceManager()
@property (retain, nonatomic) NSMutableDictionary *devices;
@end
@implementation SCDeviceManager
static SCDeviceManager* sharedMem = nil;
+ (instancetype)instance {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedMem = [[self alloc] init];
    });
    return sharedMem;
}

- (void)loadDevicesForUser:(NSString *)username {
    DeviceDAO *devDao = [DeviceDAO instance];
    [devDao setUser:username];
    [devDao loadDeviceList];
    NSArray *devs = [devDao allDevices];
    self.devices = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < [devs count]; i++) {
        NSString *uuid = [devs objectAtIndex:i];
        NSDictionary *devInfo = [devDao getDeviceInfo:uuid];
        SCDeviceClient *client = [[SCDeviceClient alloc] initWithId:devInfo[DevIdStr] user:devInfo[DevUserStr] name:devInfo[DevNameStr] type:devInfo[DevTypeStr] token:devInfo[DevTokenStr]];
        [self.devices setObject:client forKey:uuid];
    }
}

- (NSArray *)allDevices {
    return [self.devices allKeys];
}

- (BOOL)addDevice:(NSString *)uuid {
    if ([self.devices objectForKey:uuid]) {
        return NO;
    }
    SCDeviceClient *client = [[SCDeviceClient alloc] initWithId:uuid user:@"nil" name:@"nil" type:@"nil" token:@"nil"];
    [client createDevice];
    [self.devices setObject:client forKey:uuid];
    return YES;
}

- (void)removeDevice:(NSString *)uuid {
    SCDeviceClient *client = [self.devices objectForKey:uuid];
    if (client != nil) {
        [client removeDevice];
        [self.devices removeObjectForKey:uuid];
    }
}

- (SCDeviceClient *)getDevice:(NSString *)uuid {
    SCDeviceClient *client = [self.devices objectForKey:uuid];
    return client;
}

@end
