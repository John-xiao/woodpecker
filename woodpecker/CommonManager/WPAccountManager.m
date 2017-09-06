//
//  WPPassportManager.m
//  woodpecker
//
//  Created by yongche on 17/9/6.
//  Copyright © 2017年 goldsmith. All rights reserved.
//

#import "WPAccountManager.h"
@interface WPAccountManager ()
@property(nonatomic, strong) MHAccount *account;
@end

@implementation WPAccountManager
Singleton_Implementation(WPAccountManager);

- (instancetype)init {
    self = [super init];
    if (self) {
        _account = [[MHAccount alloc] initWithAppId:@"2882303761517613555" redirectUrl:@"http://mmc.mi-ae.cn/mmc/api/user/login/"];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(passportDidLogin:) name:MH_Account_Login_Sucess object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(passportLoginFailed:) name:MH_Account_Login_Failure object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(passportDidCancel:) name:MH_Account_Login_Cancel object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(passportDidLogout:) name:MH_Account_Logout_Sucess object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(passportAccessTokenInvalidOrExpired:)
                                                     name:MH_Account_AccsessToken_Expire
                                                   object:nil];
    }
    return self;
}

- (void)login {
    if (![self.account isLogin]) {
        [self.account login:@[ @1, @3, @6000 ]];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:WPNotificationKeyLoginSuccess object:nil];
    }
}

- (BOOL)isLogin {
    return [self.account isLogin];
}

- (void)logout {
    if ([self.account isLogin]) {
        [self.account logOut];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:WPNotificationKeyLogoutSuccess object:nil];
    }
}

#pragma mark - MPSessionDelegate
// 登录成功
- (void)passportDidLogin:(id)note {
    DDLogDebug(@"passport login succeeded, token:%@", self.account.accessToken);
    [self.account save];
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //      [self fetchDatas];
    //    });
    [[NSNotificationCenter defaultCenter] postNotificationName:WPNotificationKeyLoginSuccess object:nil];
}

//登录失败
- (void)passportLoginFailed:(id)note {
    /*NSDictionary *errorInfo = [note userInfo];
     NSLog(@"passport login failed with error: %ld info %@", (long)[error code], [errorInfo objectForKey: @"error_description"]);
     NSString *alertMsg = [NSString stringWithFormat:@"Error: %@\nDescription:%@\n", [errorInfo objectForKey:@"error"], [errorInfo
     objectForKey:@"error_description"]];
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message: alertMsg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
     [alert show];*/
    DDLogDebug(@">>>>>>>>>login failde:%@", note);
    [[NSNotificationCenter defaultCenter] postNotificationName:WPNotificationKeyLoginFailed object:nil];
}

// 用户取消登录
- (void)passportDidCancel:(id)note {
    DDLogDebug(@"passport login did cancel");
}

//登出成功
- (void)passportDidLogout:(id)note {
    DDLogDebug(@"passport did log out");
    [[NSNotificationCenter defaultCenter] postNotificationName:WPNotificationKeyLogoutSuccess object:nil];
}

// token过期
- (void)passportAccessTokenInvalidOrExpired:(id)note {
    DDLogDebug(@"passport accesstoken invalid or expired");
    [[NSNotificationCenter defaultCenter] postNotificationName:WPNotificationKeyTokenExpire object:nil];
}
@end