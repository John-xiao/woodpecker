//
//  AppDelegate.m
//  woodpecker
//
//  Created by yongche on 17/8/25.
//  Copyright © 2017年 goldsmith. All rights reserved.
//

#import "AppDelegate.h"
#import "WPMainViewController.h"
#import "initServer.h"
#import "WPLoginViewController.h"
#import "WPAccountManager.h"
#import "XJFServerManager.h"
#import "WPDatabaseTableManager.h"
#import "WPAccountManager.h"
#import "WPUMengManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //启动页太快
    [NSThread sleepForTimeInterval:2.0];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = kColor_10;
    [initServer load];
    [[WPDatabaseTableManager defaultInstance] initDatabase];
    [[WPUMengManager defaultInstance] configureUMeng];
    // Override point for customization after application launch.
    if ([[WPAccountManager defaultInstance] isLogin]) {
        //主页
        NSString *user_id = kDefaultObjectForKey(USER_DEFAULT_USER_ID);
        if ([NSString leie_isBlankString:user_id]) {
            //登录
            WPLoginViewController *loginVC = [[WPLoginViewController alloc] init];
            _navigationC = [[XJFBaseNavigationController alloc] initWithRootViewController:loginVC];
        }else{
            NSDictionary *userDic = kDefaultObjectForKey(USER_DEFAULT_ACCOUNT_USER);
            NSDictionary *profileDic = kDefaultObjectForKey(USER_DEFAULT_PROFILE);
            NSString *profile_id1 = [userDic objectForKey:@"profile_id"];
            NSString *profile_id2 = [profileDic objectForKey:@"profile_id"];
            if (userDic && profileDic && ([profile_id1 integerValue] == [profile_id2 integerValue])) {
                WPMainViewController *mainVC = [[WPMainViewController alloc] init];
                _navigationC = [[XJFBaseNavigationController alloc] initWithRootViewController:mainVC];
            }else{
                WPLoginViewController *loginVC = [[WPLoginViewController alloc] init];
                _navigationC = [[XJFBaseNavigationController alloc] initWithRootViewController:loginVC];
            }
        }
    }else{
        //登录
        WPLoginViewController *loginVC = [[WPLoginViewController alloc] init];
        _navigationC = [[XJFBaseNavigationController alloc] initWithRootViewController:loginVC];
    }
    self.window.rootViewController = _navigationC;
    [self checkDB];
    [self.window makeKeyAndVisible];
    //[NSThread sleepForTimeInterval:1];
    return YES;
}

- (void)checkDB{
    NSNumber *version = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_LOCAL_VERSION];
    if (version) {
        if ([version integerValue] == USER_DEFAULT_CURRENT_VERSION) {
            //当前版本
            return;
        }else{
            //历史版本
            //根据版本需要改变数据库
            //            [NSFileManager removeDirectoryAtPath:DATABASE_PATH];
            //            XJFDBOperator *operator= [XJFDBOperator defaultInstance];
            //            [operator close];
            //            [operator open];
            //            [XJFDBManager createTableWithModel:[EMMeasureModel class]];
            //            NSInteger currentVersion = USER_DEFAULT_CURRENT_VERSION;
            //            NSInteger localVersion = version;
            //
            //            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:USER_DEFAULT_CURRENT_VERSION] forKey:USER_DEFAULT_LOCAL_VERSION];
            
        }
    }else{
        //第一次进入
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:USER_DEFAULT_CURRENT_VERSION] forKey:USER_DEFAULT_LOCAL_VERSION];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an
    // incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your
    // application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background,
    // optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    NSLog(@"url: %@, source application: %@, annotation:%@", url, sourceApplication, annotation);
    [[WPAccountManager defaultInstance].account handleOpenURL:url];
    return YES;
}

@end
