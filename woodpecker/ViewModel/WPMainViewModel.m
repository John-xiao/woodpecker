//
//  MMCMainViewModel.m
//  mmcS2
//
//  Created by 肖君 on 16/10/24.
//  Copyright © 2016年 johnxiao. All rights reserved.
//

#import "WPMainViewModel.h"
#import "WPStatusViewController.h"
#import "WPTemperatureViewController.h"
#import "WPMyViewController.h"
#import "WPNetInterface.h"
#import "WPConnectDeviceManager.h"
#import "NSDate+Extension.h"
#import "WPTemperatureModel.h"
#import "MMCDeviceManager.h"
#import "NSDate+ext.h"
#import "WPEventItemModel.h"
#import "XJFDBManager.h"

@implementation WPMainViewModel
- (instancetype)init {
    self = [super init];
    if (self) {
        _controllerList = [NSMutableArray array];
        WPStatusViewController *statusVC = [[WPStatusViewController alloc] init];
        [statusVC.tabBarItem setImage:[[UIImage imageNamed:@"btn-tab-status-u"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [statusVC.tabBarItem setSelectedImage:[[UIImage imageNamed:@"btn-tab-status-s"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [_controllerList addObject:statusVC];
        
        WPTemperatureViewController *temperatureRecord = [[WPTemperatureViewController alloc] init];
        [temperatureRecord.tabBarItem setImage:[[UIImage imageNamed:@"btn-tab-curve-u"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [temperatureRecord.tabBarItem setSelectedImage:[[UIImage imageNamed:@"btn-tab-curve-p"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [_controllerList addObject:temperatureRecord];

        WPMyViewController *myVC= [[WPMyViewController alloc] init];
        [myVC.tabBarItem setImage:[[UIImage imageNamed:@"btn-tab-me-u"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [myVC.tabBarItem setSelectedImage:[[UIImage imageNamed:@"btn-tab-me-p"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [_controllerList addObject:myVC];
    }
    return self;
}

- (void)updateData{
    [WPNetInterface getUserinfoWithUserId:kDefaultObjectForKey(USER_DEFAULT_USER_ID) password:kDefaultObjectForKey(USER_DEFAULT_ACCOUNT_TOKEN) success:^(NSDictionary* userDic) {
        if (userDic) {
            kDefaultSetObjectForKey(userDic, USER_DEFAULT_ACCOUNT_USER);
        }
        [self getProfile];
        [self getDevice];
        [self getPeriods];
        [self getEvents];
        [self getTemperatures];
        [self checkVersion];
        
    } failure:^(NSError *error) {
        [self getPeriods];
        [self getEvents];
        [self getTemperatures];
        [self checkVersion];
    }];

}

- (void)getProfile{
    WPUserModel *user = [[WPUserModel alloc] init];
    [user loadDataFromkeyValues:kDefaultObjectForKey(USER_DEFAULT_ACCOUNT_USER)];
    if (![NSString leie_isBlankString:user.profile_id]) {
        [WPNetInterface getProfileWithId:user.profile_id success:^(NSDictionary *profileDic) {
            if (profileDic) {
                kDefaultSetObjectForKey(profileDic, USER_DEFAULT_PROFILE);
                WPProfileModel *profile = [[WPProfileModel alloc] init];
                [profile loadDataFromkeyValues:profileDic];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:WPNotificationKeyUpdateProfile object:nil];
        } failure:^(NSError *error) {
            
        }];
    }
}

- (void)getDevice{
    WPUserModel *user = [[WPUserModel alloc] init];
    [user loadDataFromkeyValues:kDefaultObjectForKey(USER_DEFAULT_ACCOUNT_USER)];
    if (![NSString leie_isBlankString:user.device_id]) {
        [WPNetInterface getDeviceWithId:user.device_id success:^(NSDictionary *deviceDic) {
            if (deviceDic) {
                kDefaultSetObjectForKey(deviceDic, USER_DEFAULT_DEVICE);
                [[NSNotificationCenter defaultCenter] postNotificationName:WPNotificationKeyUpdateDevice object:nil];
                [[WPConnectDeviceManager defaultInstance] startTimer];
            }else{
                kDefaultRemoveForKey(USER_DEFAULT_DEVICE);
            }
        } failure:^(NSError *error) {
            [[WPConnectDeviceManager defaultInstance] startTimer];
        }];
    }
}

- (void)getTemperatures{
    WPUserModel *user = [[WPUserModel alloc] init];
    [user loadDataFromkeyValues:kDefaultObjectForKey(USER_DEFAULT_ACCOUNT_USER)];
    //    NSString *temp_updatetime = kDefaultObjectForKey(TEMPERATURE_DEFAULT_UPDATETIME);
    //开始时间当前设备最后一条温度的时间
    WPTemperatureModel *temperature = [[WPTemperatureModel alloc] init];
    temperature.sync = @"1";
    NSArray *tempsArr = [XJFDBManager searchModelsWithCondition:temperature andpage:0 andOrderby:@"lastupdate" isAscend:NO];
    WPTemperatureModel *localTemp = tempsArr.firstObject;
    NSString *temp_updatetime = nil;
    if (localTemp) {
        temp_updatetime = localTemp.lastupdate;
    }
    [WPNetInterface getTemperaturesWithUserId:user.user_id startTime:temp_updatetime end_update_time:nil success:^(NSArray *temperatures) {
        for (NSDictionary *tempDic in temperatures) {
            WPTemperatureModel *temp = [[WPTemperatureModel alloc] init];
            [temp loadDataFromkeyValues:tempDic];
            temp.sync = @"1";
            [self insertTemperature:temp];
        }
        kDefaultSetObjectForKey([NSNumber numberWithBool:YES], TEMPERATURE_DEFAULT_GETTEMP);
        [[NSNotificationCenter defaultCenter] postNotificationName:WPNotificationKeyGetTemp object:nil];
    } failure:^(NSError *error) {
        kDefaultSetObjectForKey([NSNumber numberWithBool:YES], TEMPERATURE_DEFAULT_GETTEMP);
        [[NSNotificationCenter defaultCenter] postNotificationName:WPNotificationKeyGetTemp object:nil];
    }];
}

- (void)insertTemperature:(WPTemperatureModel *)temp{
    NSDate *date = [NSDate dateFromUTCString:temp.time format:DATE_FORMATE_SEC_STRING];
    if (date) {
        NSTimeInterval time = [date timeIntervalSince2000];
        if (time >= 0) {
            WPTemperatureModel *temperature = [[WPTemperatureModel alloc] init];
            temperature.date = [NSDate stringFromDate:date format:DATE_FORMATE_STRING];
            NSArray *tempsArr = [XJFDBManager searchModelsWithCondition:temperature andpage:-1 andOrderby:@"time" isAscend:NO];
            WPTemperatureModel *localTemp = tempsArr.firstObject;
            temp.date = temperature.date;
            temp.time = [NSString stringWithFormat:@"%f",time] ;
            if (localTemp) {
                if ([temp.time longLongValue] >= [localTemp.time longLongValue]) {
                    //替换当前记录
                    [XJFDBManager deleteModel:localTemp dependOnKeys:nil];
                    [temp insertToDB];
                }
            }else{
                //插入当前时间
                [temp insertToDB];
            }
        }
    }
}

- (void)getPeriods{
    WPUserModel *user = [[WPUserModel alloc] init];
    [user loadDataFromkeyValues:kDefaultObjectForKey(USER_DEFAULT_ACCOUNT_USER)];
    if (![NSString leie_isBlankString:user.user_id]) {
        WPPeriodModel *period = [[WPPeriodModel alloc] init];
        NSArray *periodsArr = [XJFDBManager searchModelsWithCondition:period andpage:0 andOrderby:@"lastupdate" isAscend:NO];
        WPPeriodModel *localPeriod= periodsArr.firstObject;
        NSString *updatetime = nil;
        if (localPeriod) {
            updatetime = localPeriod.lastupdate;
        }
        [WPNetInterface getPeriod:user.user_id start_update_time:updatetime end_update_time:nil success:^(NSArray *periods) {
            for (NSDictionary *periodDic in periods) {
                WPPeriodModel *period = [[WPPeriodModel alloc] init];
                [period loadDataFromkeyValues:periodDic];
                period.pid = period.period_id;
                if ([period.removed boolValue]) {
                    [XJFDBManager deleteModel:period dependOnKeys:nil];
                }else{
                    if (![period insertToDB]) {
                        [period updateToDBDependsOn:nil];
                    }
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:WPNotificationKeyGetPeriod object:nil];
        } failure:^(NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:WPNotificationKeyGetPeriod object:nil];
        }];
    }
}

-(void)getEvents{
    WPUserModel *user = [[WPUserModel alloc] init];
    [user loadDataFromkeyValues:kDefaultObjectForKey(USER_DEFAULT_ACCOUNT_USER)];
    if (![NSString leie_isBlankString:user.user_id]) {
        WPEventItemModel *eventItem = [[WPEventItemModel alloc] init];
        NSArray *eventsArr = [XJFDBManager searchModelsWithCondition:eventItem andpage:0 andOrderby:@"lastupdate" isAscend:NO];
        WPEventItemModel *localEventItem = eventsArr.firstObject;
        NSString *updatetime = nil;
        if (localEventItem) {
            updatetime = localEventItem.lastupdate;
        }
        [WPNetInterface getEvent:user.user_id start_update_time:updatetime end_update_time:nil success:^(NSArray *events) {
            for (NSDictionary *eventDic in events) {
                WPEventItemModel *item = [[WPEventItemModel alloc] init];
                [item loadDataFromkeyValues:eventDic];
                item.pid = item.event_id;
                item.brief = [eventDic objectForKey:@"description"];
                if ([item.removed boolValue]) {
                    [XJFDBManager deleteModel:item dependOnKeys:nil];
                }else{
                    if (![item insertToDB]) {
                        [item updateToDBDependsOn:nil];
                    }
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:WPNotificationKeyGetEvent object:nil];
        } failure:^(NSError *error) {
            
        }];
    }
}

- (void)checkVersion{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULT_SUPPORTED_LOWEST_VERSION];
    [WPNetInterface getVersionSuccess:^(NSString *supportedLowestVersion) {
        kDefaultSetObjectForKey(supportedLowestVersion, USER_DEFAULT_SUPPORTED_LOWEST_VERSION);
        [[NSNotificationCenter defaultCenter] postNotificationName:WPNotificationKeyVersion object:nil];
    } failure:^(NSError *error) {
        
    }];
}
@end
