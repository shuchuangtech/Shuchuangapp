//
//  AppDelegate.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/4/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "AppDelegate.h"
#import "Bmob.h"
#import "SCHTTPManager.h"
#import "SCDeviceManager.h"
#import "ShareSDK/ShareSDK.h"
#import "ShareSDKConnector/ShareSDKConnector.h"
#import "WXApi.h"

@interface AppDelegate ()

@end

static void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack trace: %@", [exception callStackSymbols]);
}

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    //Bmob
    [Bmob registerWithAppKey:@"27f1f3599a223cfa40bb5c5e5daedd7a"];
    UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
    categorys.identifier = @"com.Shuchuang.ShuchuangClient";
    UIUserNotificationSettings *userNotifiSetting = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:[NSSet setWithObjects:categorys, nil]];
    [[UIApplication sharedApplication] registerUserNotificationSettings:userNotifiSetting];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    //SCHTTPManager
    SCHTTPManager *http = [SCHTTPManager instance];
    [http initWithCertificate:@"server" serverAddress:@"www.shuchuangtech.com" port:9888];
    //shareSDK
    [ShareSDK registerApp:@"1157afc798210" activePlatforms:@[@(SSDKPlatformTypeWechat)] onImport:^(SSDKPlatformType platformType) {
        switch (platformType) {
            case SSDKPlatformTypeWechat :
                [ShareSDKConnector connectWeChat:[WXApi class]];
                break;
            default:
                break;
        }
    } onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
        switch (platformType) {
            case SSDKPlatformTypeWechat:
                [appInfo SSDKSetupWeChatByAppId:@"wxb03a7bb272f830e7" appSecret:@"18a8971fa41cff248e254e24a7b38937"];
                break;
            default:
                break;
        }
    }];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken {
    BmobInstallation *currentInstallation = [BmobInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    NSString *mobile_token = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    if(userDef != nil) {
        [userDef setObject:mobile_token forKey:@"MobileToken"];
        [userDef synchronize];
    }
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

}

@end
