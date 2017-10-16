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
#import "WPEventModel.h"
#import "NSDate+Extension.h"
#import "WPTemperatureModel.h"
#import "MMCDeviceManager.h"

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
        NSDictionary *userDic = kDefaultObjectForKey(USER_DEFAULT_ACCOUNT_USER);
        NSDictionary *profileDic = kDefaultObjectForKey(USER_DEFAULT_PROFILE);
        NSDictionary *deviceDic = kDefaultObjectForKey(USER_DEFAULT_DEVICE);
        [_user loadDataFromkeyValues:userDic];
        [_profile loadDataFromkeyValues:profileDic];
        [_device loadDataFromkeyValues:deviceDic];
    }
    return self;
}

- (void)updateData{
    [WPNetInterface getUserinfoWithUserId:kDefaultObjectForKey(USER_DEFAULT_USER_ID) password:kDefaultObjectForKey(USER_DEFAULT_ACCOUNT_TOKEN) success:^(NSDictionary* userDic) {
        if (userDic) {
            kDefaultSetObjectForKey(userDic, USER_DEFAULT_ACCOUNT_USER);
            _user = [[WPUserModel alloc] init];
            [_user loadDataFromkeyValues:userDic];
            [self getProfile];
            [self getDevice];
        }else{
            _user = nil;
            kDefaultRemoveForKey(USER_DEFAULT_ACCOUNT_USER);
        }
    } failure:^(NSError *error) {
        
    }];
    [self getTemperatures];
}

- (void)getProfile{
    if (![NSString leie_isBlankString:_user.profile_id]) {
        [WPNetInterface getProfileWithId:_user.profile_id success:^(NSDictionary *profileDic) {
            if (profileDic) {
                kDefaultSetObjectForKey(profileDic, USER_DEFAULT_PROFILE);
                _profile = [[WPProfileModel alloc] init];
                [_profile loadDataFromkeyValues:profileDic];
                WPEventModel *event = [[WPEventModel alloc] init];
                event.status = @"1";
                event.date = _profile.lastperiod;
                event.pid = event.date;
                [event insertOrupdateToDBDependsOn:nil];
            }else{
                _profile = nil;
                kDefaultRemoveForKey(USER_DEFAULT_PROFILE);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:WPNotificationKeyUpdateProfile object:nil];
        } failure:^(NSError *error) {
            
        }];
    }
}

- (void)getDevice{
    if (![NSString leie_isBlankString:_user.device_id]) {
        [WPNetInterface getDeviceWithId:_user.device_id success:^(NSDictionary *deviceDic) {
            if (deviceDic) {
                kDefaultSetObjectForKey(deviceDic, USER_DEFAULT_DEVICE);
                _device = [[WPDeviceModel alloc] init];
                [_device loadDataFromkeyValues:deviceDic];
                [[NSNotificationCenter defaultCenter] postNotificationName:WPNotificationKeyUpdateDevice object:nil];
                [[WPConnectDeviceManager defaultInstance] startTimer];
            }else{
                _device = nil;
                kDefaultRemoveForKey(USER_DEFAULT_DEVICE);
            }
        } failure:^(NSError *error) {
            [[WPConnectDeviceManager defaultInstance] startTimer];
        }];
    }
}

- (void)getTemperatures{
//    NSString *temp_updatetime = kDefaultObjectForKey(TEMPERATURE_DEFAULT_UPDATETIME);
    //开始时间当前设备最后一条温度的时间
    WPTemperatureModel *temperature = [[WPTemperatureModel alloc] init];
    NSArray *tempsArr = [XJFDBManager searchModelsWithCondition:temperature andpage:0 andOrderby:@"time" isAscend:NO];
    WPTemperatureModel *localTemp = tempsArr.firstObject;
    NSString *temp_updatetime = nil;
    if (localTemp) {
        temp_updatetime = localTemp.time;
    }
    [WPNetInterface getTemperaturesWithUserId:_user.user_id startTime:temp_updatetime end_update_time:nil success:^(NSArray *temperatures) {
        for (NSDictionary *tempDic in temperatures) {
            WPTemperatureModel *temp = [[WPTemperatureModel alloc] init];
            [temp loadDataFromkeyValues:tempDic];
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
    if (temp.time.length == 9) {
        NSDate *date = [NSDate dateWithTimeIntervalSince2000:[temp.time longLongValue]];
        if (date) {
            WPDeviceModel *device = [[WPDeviceModel alloc] init];
            [device loadDataFromkeyValues:kDefaultObjectForKey(USER_DEFAULT_DEVICE)];
            WPTemperatureModel *temperature = [[WPTemperatureModel alloc] init];
            temperature.date = [NSDate stringFromDate:date format:@"yyyy MM dd"];
            NSArray *tempsArr = [XJFDBManager searchModelsWithCondition:temperature andpage:-1 andOrderby:@"time" isAscend:NO];
            WPTemperatureModel *localTemp = tempsArr.firstObject;
            temp.date = temperature.date;
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
@end
