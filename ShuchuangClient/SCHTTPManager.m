//
//  SCHTTPManager.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/13/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "SCHTTPManager.h"
#import "AFNetworking.h"

@interface SCHTTPManager ()
@property (strong, nonatomic) AFHTTPSessionManager *http;
@property (strong, nonatomic) NSString *baseURL;
@end

@implementation SCHTTPManager
static SCHTTPManager *sharedManager = nil;
+ (instancetype)instance {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)initWithCertificate:(NSString *)cer serverAddress:(NSString *)addr port:(NSInteger)port {
    self.http = [AFHTTPSessionManager manager];
    //init certificate
    NSString * cerPath = [[NSBundle mainBundle] pathForResource:cer ofType:@"cer"];
    NSData * cerData = [NSData dataWithContentsOfFile:cerPath];
    self.http.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:[[NSArray alloc] initWithObjects:cerData, nil]];
    //serializer
    self.http.requestSerializer = [AFJSONRequestSerializer serializer];
    self.http.responseSerializer = [AFJSONResponseSerializer serializer];
    self.baseURL = [[NSString alloc] initWithFormat: @"https://%@:%ld", addr, (long)port];
}

- (void)sendMessage:(id)param success:(void (^)(NSURLSessionDataTask * _Nullable, id _Nonnull))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    [self.http POST:self.baseURL parameters:param success:success failure:failure];
}

- (NSString *)getBaseURL {
    return self.baseURL;
}
@end
