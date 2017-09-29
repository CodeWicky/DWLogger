//
//  DWLogManager.h
//  DWLogger
//
//  Created by Wicky on 2017/9/26.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 You can combine Info/Waring/Error but not Ignore.
 If you need all the three filter just use All.
 */
typedef NS_OPTIONS(NSUInteger, DWLoggerFilter) {
    DWLoggerIgnore = 0,///Don't combine with other filter,this filter will shield all log.
    DWLoggerInfo = 1 << 1,
    DWLoggerWarning = 1 << 2,
    DWLoggerError = 1 << 3,
    DWLoggerAll = DWLoggerInfo | DWLoggerWarning | DWLoggerError,
};

@class DWLogView;
@class DWTableViewHelperModel;
@interface DWLogManager : NSObject

///是否允许Logger收集日志，若不予许收集日志则相关功能均失效（默认为NO）
@property (nonatomic ,assign) BOOL disableLogger;

///是否要转化为详细日志（默认为NO）
@property (nonatomic ,assign) BOOL particularLog;

///是否自动备份日志至沙盒（默认为NO）
@property (nonatomic ,assign) BOOL autoBackUp;

///展示的Log类型过滤器
@property (nonatomic ,assign) DWLoggerFilter logFilter;

///自动备份日志沙盒地址
@property (nonatomic ,copy ,readonly) NSString * logFilePath;

///日志时间格式化（勿改）
@property (nonatomic ,strong ,readonly) NSDateFormatter * timeFormatter;

///日志视图
@property (nonatomic ,weak ,readonly) DWLogView * logView;

///单例方法
+(instancetype)shareLogManager;

///添加日志
+(void)addLog:(NSString *)log filter:(DWLoggerFilter)filter;

///设置日志视图
+(void)setupLogView:(DWLogView *)logView;

///清除当前日志
+(void)clearCurrentLog;

///删除所有本地日志
+(void)removeAllLogBackUp;

///删除本次当前本地日志
+(void)removeCurrentLogBackUp;

///配置默认Logger
+(void)configDefaultLogger;

///以过滤器和logView配置Logger
+(void)configLoggerWithFilter:(DWLoggerFilter)filter needLogView:(BOOL)need;
@end

