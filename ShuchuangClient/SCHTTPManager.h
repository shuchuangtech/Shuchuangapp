//
//  SCHTTPManager.h
//  ShuchuangClient
//
//  Created by 黄建 on 1/13/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface SCHTTPManager : NSObject
+ (_Nonnull instancetype)instance;
- (void)initWithCertificate:(nonnull NSString *)cer serverAddress:(nonnull NSString *)addr port:(NSInteger)port;
- (void)sendMessage:(nullable id)param
            success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nonnull responseObject))success
            failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;
- (nonnull NSString *)getBaseURL;
@end
