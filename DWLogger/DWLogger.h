//
//  DWLogger.h
//  DWLogger
//
//  Created by Wicky on 2017/9/26.
//  Copyright © 2017年 Wicky. All rights reserved.
//

/**
 DWLogger
 日志扩展管理类
 
 提供Debug模式下的日志管理功能，Release模式下屏蔽日志输出及管理功能。
 提供不同日志输出等级，并提供手机端日志查看助手。
 提供日志备份及崩溃捕捉等功能
 
 DWLog() 此Log模式不受过滤器影响，任何情况下均高亮显示
 DWLogNormal() 此模式为普通日志模式，可以通过过滤器过滤掉此类日志以方便查看重要信息（默认情况下NSLog会被替换为此模式日志）
 DWLogInfo() 此模式为信息模式，输出重要信息，可通过过滤器控制显隐
 DWLogWarning() 此模式为警告模式，输出警告信息，可通过过滤器控制显隐
 DWLogError() 此模式为错误模式，输出错误信息，可通过过滤器控制显隐
 
 请在Appdelegate中程序启动后调用[DWLogManager configDefaultLogger]进行日志捕捉。若想在Debug模式下手机崩溃日志可调用[DWLogManager configToCollectCrash]进行手机。
 
 其他一些辅助工具属性请查看DWLogManager中属性注释并合理使用。
 
 version 1.0.0
 提供不同等级日志输出
 提供手机端日志查看助手
 提供日志备份及崩溃捕捉功能
 Release模式下屏蔽所有功能
 
 version 1.0.0.1
 添加NSLog替换为DWLog的日志替换宏
 DWLog中日志输出函数改为printf函数，防止NSLog宏的循环调用
 修复不选详细日志模式时模式前缀颜色失效问题
 
 version 1.0.0.2
 过滤器逻辑修改
 添加日志搜索模式相关逻辑
 添加iOS11适配
 修复tableView的header、footer高度适配
 适配iOS8
 
 version 1.0.0.3
 增加DWLogNormal()模式，并以此替换系统日志，方便过滤基本日志
 崩溃日志增加设备的基本信息
 搜索模式忽略大小写
 
 version 1.0.1
 修改崩溃日志保存策略，以防保存失败，同时添加崩溃截图
 添加删除崩溃日志API
 修改路径打印文案
 
 */

#ifndef DWLogger_h
#define DWLogger_h

#import "DWLogManager.h"
#import "DWLogView.h"

#if DEBUG
///开发环境标识符
///Develop Environment Flag
#define DevEvn
#endif

#ifndef ReplaceSystemLog
///替换NSLog日志标识符，若无需替换系统日志，注释掉此宏定义
///The flag that indicates whether replace NSLog with DWLogNormal.If there hasn't any need to replace,just annotate this flag.
#define ReplaceSystemLog
#endif

#ifdef ReplaceSystemLog
#define NSLog(...) DWLogNormal(__VA_ARGS__)
#endif

#define DWLog(...) \
do {\
    DWLogWithFilter(DWLoggerAll,__VA_ARGS__);\
} while (0)

#define DWLogNormal(...) \
do {\
DWLogWithFilter(DWLoggerNormal,__VA_ARGS__);\
} while (0)

#define DWLogInfo(...) \
do {\
DWLogWithFilter(DWLoggerInfo,__VA_ARGS__);\
} while (0)

#define DWLogWarning(...) \
do {\
DWLogWithFilter(DWLoggerWarning,__VA_ARGS__);\
} while (0)

#define DWLogError(...) \
do {\
DWLogWithFilter(DWLoggerError,__VA_ARGS__);\
} while (0)

#ifdef DevEvn

#define DWLogWithFilter(f,...) \
do {\
DWLogManager * logger = [DWLogManager shareLogManager];\
NSString * log = [NSString stringWithFormat:__VA_ARGS__];\
NSString * filterStr = nil;\
switch (f) {\
case DWLoggerNormal:\
filterStr = @"NORMAL: ";\
break;\
case DWLoggerInfo:\
filterStr = @"INFO: ";\
break;\
case DWLoggerError:\
filterStr = @"ERROR: ";\
break;\
case DWLoggerWarning:\
filterStr = @"WARNING: ";\
break;\
default:\
filterStr = @"";\
break;\
}\
NSString * prefix = @"";\
NSString * timeStr = [logger.timeFormatter stringFromDate:[NSDate date]];\
prefix = [prefix stringByAppendingString:timeStr];\
prefix = [prefix stringByAppendingString:[NSString stringWithFormat:@" %@",logger.projectName]];\
NSString * file = [[NSString stringWithUTF8String:__FILE__] lastPathComponent];\
prefix = [prefix stringByAppendingString:[NSString stringWithFormat:@"[%@",file]];\
prefix = [prefix stringByAppendingString:[NSString stringWithFormat:@" line:%d method:%@] ",__LINE__,NSStringFromSelector(_cmd)]];\
prefix = [prefix stringByAppendingString:filterStr];\
if (logger.logFilter & f) {\
printf("%s%s\n",prefix.UTF8String,log.UTF8String);\
}\
if (!logger.disableLogger) {\
if (!logger.particularLog) {\
prefix = filterStr;\
}\
[DWLogManager addLog:log prefix:prefix filter:f];\
}\
} while (0)

#else

#define DWLogWithFilter(f,...)

#endif

#endif /* DWLogger_h */
