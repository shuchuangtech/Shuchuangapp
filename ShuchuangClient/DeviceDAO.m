//
//  DeviceDAO.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/15/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "DeviceDAO.h"
#import "SSkeychain.h"
NSString * const DevNameStr = @"Name";
NSString * const DevTypeStr = @"Type";
NSString * const DevTokenStr = @"Token";
NSString * const DevUserStr = @"User";
NSString * const DevIdStr = @"Uuid";

@interface DeviceDAO()
@property (strong, nonatomic) NSMutableArray *devices;
@property (strong, nonatomic) NSString *deviceListPath;
@property (strong, nonatomic) NSString *userRootPath;
- (BOOL)createEditableCopyOfDataIfNeeded:(nonnull NSString *)filePath;
- (NSString *)userDocumentsDirectoryFile:(NSString *)file;
@end
@implementation DeviceDAO
static DeviceDAO* sharedMem = nil;
+ (instancetype)instance {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedMem = [[self alloc] init];
    });
    return sharedMem;
}

- (BOOL)createEditableCopyOfDataIfNeeded:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL dbexists = [fileManager fileExistsAtPath:filePath];
    if (!dbexists) {
        BOOL success = [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        return success;
    }
    return YES;
}

- (NSString *)userDocumentsDirectoryFile:(NSString *)file {
    NSString *path = [self.userRootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", file]];
    return path;
}

- (BOOL)setUser:(NSString *)username {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", username]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        if ([[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil]) {
            self.userRootPath = path;
            return YES;
        }
        else {
            NSLog(@"create user root path failed");
            return NO;
        }
    }
    else {
        self.userRootPath = path;
        return YES;
    }
}

- (void)loadDeviceList {
    self.deviceListPath = [self userDocumentsDirectoryFile:@"DeviceList"];
    [self createEditableCopyOfDataIfNeeded:self.deviceListPath];
    NSMutableArray *data = [[NSMutableArray alloc] initWithContentsOfFile:self.deviceListPath];
    if (data != nil) {
        self.devices = data;
    }
    else {
        self.devices = [[NSMutableArray alloc] init];
    }
}

- (NSArray *)allDevices {
    return self.devices;
}

- (void)insertDevice:(NSString *)uuid{
    if ([self.devices containsObject:uuid]) {
        return;
    }
    //update DeviceList
    [self.devices addObject:uuid];
    [self.devices writeToFile:self.deviceListPath atomically:YES];
    
    //create directory
    NSString *path = [self.userRootPath stringByAppendingPathComponent:uuid];
    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
	
    //write device file
    NSString *infoFile = [NSString stringWithFormat:@"%@/Info", uuid];
    NSString *taskFile = [NSString stringWithFormat:@"%@/Task", uuid];
    NSString *configFile = [NSString stringWithFormat:@"%@/Config", uuid];
    NSString *infoPath = [self userDocumentsDirectoryFile:infoFile];
    NSString *taskPath = [self userDocumentsDirectoryFile:taskFile];
    NSString *configPath = [self userDocumentsDirectoryFile:configFile];
    [self createEditableCopyOfDataIfNeeded:infoPath];
    [self createEditableCopyOfDataIfNeeded:taskPath];
    [self createEditableCopyOfDataIfNeeded:configPath];
    
}

- (void)removeDevice:(NSString *)uuid {
    if (![self.devices containsObject:uuid]) {
        return;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *devicePath = [self.userRootPath stringByAppendingPathComponent:uuid];
    NSError *err;
    if ([fileManager removeItemAtPath:devicePath error:&err]) {
        [self.devices removeObject:uuid];
        [self.devices writeToFile:self.deviceListPath atomically:YES];
        [SSKeychain deletePasswordForService:@"Shuchuang" account:uuid];
    }
    else {
        NSLog(@"remove device failed, error %@", err);
    }
}

- (NSDictionary *)getDeviceInfo:(NSString *)uuid {
    NSString *infoFile = [NSString stringWithFormat:@"%@/Info", uuid];
    NSString *infoPath = [self userDocumentsDirectoryFile:infoFile];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:infoPath];
    [data setObject:[SSKeychain passwordForService:@"Shuchuang" account:uuid] forKey:DevTokenStr];
    return data;
}

- (void)setDeviceInfo:(NSDictionary *)dict token:(NSString *)token forDevice:(NSString *)uuid {
    NSString *infoFile = [NSString stringWithFormat:@"%@/Info", uuid];
    NSString *infoPath = [self userDocumentsDirectoryFile:infoFile];
    [dict writeToFile:infoPath atomically:YES];
    [SSKeychain setPassword:token forService:@"Shuchuang" account:uuid];
}

- (NSArray *)getTasks:(NSString *)uuid {
    NSString *taskFile = [NSString stringWithFormat:@"%@/Task", uuid];
    NSString *taskPath = [self userDocumentsDirectoryFile:taskFile];
    NSArray *array = [[NSArray alloc] initWithContentsOfFile:taskPath];
    return array;
}

- (void)setTasks:(NSArray *)task forDevice:(NSString *)uuid {
    NSString *taskFile = [NSString stringWithFormat:@"%@/Task", uuid];
    NSString *taskPath = [self userDocumentsDirectoryFile:taskFile];
    [task writeToFile:taskPath atomically:YES];
}

- (void)addTask:(NSDictionary *)task forDevice:(NSString *)uuid {
    NSString *taskFile = [NSString stringWithFormat:@"%@/Task", uuid];
    NSString *taskPath = [self userDocumentsDirectoryFile:taskFile];
    NSArray *arr = [[NSArray alloc] initWithContentsOfFile:taskPath];
    NSMutableArray *array = nil;
    if (arr == nil) {
        array = [[NSMutableArray alloc] init];
    }
    else {
        array = [[NSMutableArray alloc] initWithArray:arr];
    }
    [array addObject:task];
    [array writeToFile:taskPath atomically:YES];
}

- (void)removeTask:(NSInteger)index forDevice:(NSString *)uuid {
    NSString *taskFile = [NSString stringWithFormat:@"%@/Task", uuid];
    NSString *taskPath = [self userDocumentsDirectoryFile:taskFile];
    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:taskPath];
    [array removeObjectAtIndex:index];
    [array writeToFile:taskPath atomically:YES];
}

- (void)clearTasksForDevice:(NSString *)uuid {
    NSString *taskFile = [NSString stringWithFormat:@"%@/Task", uuid];
    NSString *taskPath = [self userDocumentsDirectoryFile:taskFile];
    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:taskPath];
    [array removeAllObjects];
    [array writeToFile:taskPath atomically:YES];
}

- (void)updateTask:(NSDictionary *)task forDevice:(NSString *)uuid atIndex:(NSInteger)index{
    NSString *taskFile = [NSString stringWithFormat:@"%@/Task", uuid];
    NSString *taskPath = [self userDocumentsDirectoryFile:taskFile];
    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:taskPath];
    if (index >= [array count]) {
        return;
    }
    if ([[array objectAtIndex:index][@"id"] integerValue] == [task[@"id"] integerValue]) {
        [array setObject:task atIndexedSubscript:index];
        [array writeToFile:taskPath atomically:YES];
    }
}

- (NSDictionary *)getConfig:(NSString *)uuid {
    NSString *configFile = [NSString stringWithFormat:@"%@/Config", uuid];
    NSString *configPath = [self userDocumentsDirectoryFile:configFile];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:configPath];
    return dict;
}

- (void)setConfig:(NSDictionary *)config forDevice:(NSString *)uuid {
    NSString *configFile = [NSString stringWithFormat:@"%@/Config", uuid];
    NSString *configPath = [self userDocumentsDirectoryFile:configFile];
    [config writeToFile:configPath atomically:YES];
}

@end
