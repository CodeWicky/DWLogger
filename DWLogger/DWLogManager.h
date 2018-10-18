//
//  DWLogManager.h
//  DWLogger
//
//  Created by Wicky on 2017/9/26.
//  Copyright © 2017年 Wicky. All rights reserved.
//

/**
 日志管理者
 
 提供日志管理的核心功能
 */

#import <UIKit/UIKit.h>

/**
 日志过滤器
 你可以任意组合普通/信息/警告/错误模式，但是忽略模式不可以与任意一个其他模式组合。
 如果你想保留所有日志模式，请使用全部模式
 
 Log Filter
 You can combine Normal/Info/Waring/Error but not Ignore.
 If you need all the three filter just use All.
 
 DWLoggerIgnore  忽略模式
     此模式将屏蔽所有模式的日志（使用DWLog()输出的日志不受影响），请不要与其他模式组合使用
     Don't combine with other filter,this filter will shield all log.
 
 DWLoggerNormal  普通模式
     此模式下可输出一下基本信息，这样可以通过屏蔽此类型日志来方便查看
     Use this filter for something not important so that you can shield it.
 
 DWLoggerInfo  信息模式
     在这个模式下可输出一些重要信息
     Some essential imformation in this filter.
 
 DWLoggerWarning  警告模式
     在这个模式下输出一些警告
     Maybe something unexpected or beyond calculation.
 
 DWLoggerError  错误模式
     在这个模式下输出一些错误信息
     Here are some error shouldn't occur but they do.
 
 DWLoggerAll
     使用此模式可以输出全部日志
     All filter Log.
 */
typedef NS_OPTIONS(NSUInteger, DWLoggerFilter) {
    ///忽略模式
    DWLoggerIgnore = 0,
    ///普通模式
    DWLoggerNormal = 1 << 1,
    ///信息模式
    DWLoggerInfo = 1 << 2,
    ///警告模式
    DWLoggerWarning = 1 << 3,
    ///错误模式
    DWLoggerError = 1 << 4,
    ///全局模式
    DWLoggerAll = DWLoggerNormal | DWLoggerInfo | DWLoggerWarning | DWLoggerError,
};

UIKIT_EXTERN NSNotificationName const DWLoggerDeviceShakeNotification;

@class DWLogView;
@class DWTableViewHelperModel;
@interface DWLogManager : NSObject

///是否允许Logger收集日志，若不予许收集日志则相关功能均失效（默认为NO）
///A flag indicates whether DWLogger works.All function will become invalid if you disable DWLoggerManager.（Default NO）
@property (nonatomic ,assign) BOOL disableLogger;

///是否要转化为详细日志（默认为NO）
///A flag indicates whether need log detail.（Default NO）
@property (nonatomic ,assign) BOOL particularLog;

///仅autoBackUp与saveLocalLog同时为YES时才备份日志至本地。autoBackUp用来进行全局控制，saveLocalLog用来进行过程中控制。
///Only when autoBackUp and saveLocalLog are both YES Logger should backup log to disk.You may use autoBackUp as global control and saveLocalLog as save switch.

///是否自动备份日志至沙盒（默认为NO）
///A flag indicates whether auto backup log to disk.（Default NO）
@property (nonatomic ,assign) BOOL autoBackUp;

///本地保存日志（默认为YES）
///A flag indicates whether save log to disk.(Default YES)
@property (nonatomic ,assign) BOOL saveLocalLog;

///日志显示最大长度。（默认为1024 * 5个字符）
///The max length for log to show.（default by 1024 * 5）
@property (nonatomic ,assign) NSInteger maxLogLength;

///展示的Log类型过滤器（默认为DWLoggerAll）
///Property control DWLogger Filter.DWLogger will only show the Logs among the filter.（Default DWLoggerAll）
@property (nonatomic ,assign) DWLoggerFilter logFilter;

///当前项目名称
///Current Project Name.
@property (nonatomic ,copy ,readonly) NSString * projectName;

///自动备份日志沙盒地址
///The path that auto backup to.
@property (nonatomic ,copy ,readonly) NSString * logFilePath;

///日志时间格式化（勿改）
///DataFormatter for Log.（Always do not fix it）
@property (nonatomic ,strong ,readonly) NSDateFormatter * timeFormatter;

///日志视图
///View For Logger.
@property (nonatomic ,weak ,readonly) DWLogView * logView;

///单例方法
///Singleton
+(instancetype)shareLogManager;

///添加日志（无需调用）
///Add Log to DWLogManager.（Actually you needn't call it）
+(void)addLog:(NSString *)log prefix:(NSString *)prefix filter:(DWLoggerFilter)filter;

///设置日志视图（无需调用）
///Config logView for logManager.（Actually you needn't call it）
+(void)setupLogView:(DWLogView *)logView;

///设置是否允许摇晃控制浮窗的显隐（默认允许）
///Config whether is able to shake to control float pot.Support by default
+(void)enableShakeToSwitchPot:(BOOL)enable;

///清除当前日志
///Clear current logs on screen.
+(void)clearCurrentLog;

///删除所有本地日志
///Remove all Log Backups on disk.
+(void)removeAllLogBackUp;

///删除所有本地崩溃日志
///Remove all Crash Backups on disk.
+(void)removeAllCrashBackUp;

///删除本次当前本地日志
///Remove current Log Backup on disk.
+(void)removeCurrentLogBackUp;

///配置默认Logger
///Config Logger by default.
+(void)configDefaultLogger;

///以过滤器和logView配置Logger
///Customsize the Logger yourself.
+(void)configLoggerWithFilter:(DWLoggerFilter)filter needLogView:(BOOL)need;

///打印当前调用栈信息
///Print CallStackSysbols.
+(void)printCallStackSymbols;

///打印Logger的文件主目录
///Print main path for Logger.
+(void)printLoggerMainPath;

///收集崩溃日志
///Config Logger to collect Crash.
+(void)configToCollectCrash;
@end

