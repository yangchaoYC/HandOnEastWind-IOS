//
//  AppDelegate.m
//  HandOnEastWind
//
//  Created by 李迪 on 14-2-22.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import "AppDelegate.h"
#import "FMDatabase.h"
#import "ADWindow.h"
#import "UMSocial.h"

#import <ShareSDK/ShareSDK.h>
#import "WeiboSDK.h"
#import "WXApi.h"
#import "WeiboApi.h"
#import "WXApiObject.h"
#import "YXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

#define DB_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initDatabase];

    self.adWindow = [[ADWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.adWindow.windowLevel = UIWindowLevelStatusBar + 1;
    self.adWindow.hidden = NO;
    [self.adWindow show];
    [self.adWindow makeKeyAndVisible];
    
    [UIView animateWithDuration:1.0f delay:2.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.adWindow.frame = CGRectMake(-1 * self.adWindow.frame.size.width, self.adWindow.frame.origin.y,
                                         self.adWindow.frame.size.width, self.adWindow.frame.size.height);
    }completion:^(BOOL completion){
        [self.adWindow show];
    }];
    
    
    [UMSocialData setAppKey:@"507fcab25270157b37000010"];
    
    
    
    [ShareSDK registerApp:@"15415d0dd348"];
    
    //添加新浪微博应用
    [ShareSDK connectSinaWeiboWithAppKey:@"3201194191"
                               appSecret:@"0334252914651e8f76bad63337b3b78f"
                             redirectUri:@"http://appgo.cn"];
    
    //添加腾讯微博应用
    [ShareSDK connectTencentWeiboWithAppKey:@"801307650"
                                  appSecret:@"ae36f4ee3946e1cbb98d6965b0b2ff5c"
                                redirectUri:@"http://www.sharesdk.cn"];
    
    
    //添加微信应用
    [ShareSDK connectWeChatWithAppId:@"wx6dd7a9b94f3dd72a"        //此参数为申请的微信AppID
                           wechatCls:[WXApi class]];
    
    //连接短信分享
    [ShareSDK connectSMS];
    
    //连接邮件
    [ShareSDK connectMail];
    
    
    return YES;
}



- (BOOL)application:(UIApplication *)application  handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}



- (void)initDatabase
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[DB_PATH stringByAppendingPathComponent:@"poketeastwind.db"]]) {
        FMDatabase *db = [FMDatabase databaseWithPath:[DB_PATH stringByAppendingPathComponent:@"poketeastwind.db"]];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"cache" ofType:@"sql" ];
        NSError *error;
        NSString *sqlStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
        NSArray *sqls = [sqlStr componentsSeparatedByString:@"\n"];
        if ([db open])
        {
            [db beginTransaction];
            for (int i=0; i<sqls.count; i++) {
                [db executeUpdate:[sqls objectAtIndex:i]];
            }
            [db commit];
        }
    };
}
						
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
