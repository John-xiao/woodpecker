//
//  WPUMengManager.m
//  woodpecker
//
//  Created by QiWL on 2017/12/4.
//  Copyright © 2017年 goldsmith. All rights reserved.
//

#import "WPUMengManager.h"
#import <UMCommon/UMCommon.h>
#import <UMAnalytics/MobClick.h>

@implementation WPUMengManager
Singleton_Implementation(WPUMengManager);
- (void)configureUMeng{
    // 配置友盟SDK产品并并统一初始化
    // [UMConfigure setEncryptEnabled:YES]; // optional: 设置加密传输, 默认NO.
    // [UMConfigure setLogEnabled:YES]; // 开发调试时可在console查看友盟日志显示，发布产品必须移除。
    [UMConfigure initWithAppkey:@"5a25168af29d9874c2000113" channel:@"App Store"];
    /* appkey: 开发者在友盟后台申请的应用获得（可在统计后台的 “统计分析->设置->应用信息” 页面查看）*/

}
@end
