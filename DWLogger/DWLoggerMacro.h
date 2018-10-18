//
//  DWLoggerMacro.h
//  DWLogger
//
//  Created by Wicky on 2018/10/18.
//  Copyright © 2018年 Wicky. All rights reserved.
//

#ifndef DWLoggerMacro_h
#define DWLoggerMacro_h

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

///最大日志长度
///Max length of log,log beyond this range will be ignored
#define MaxLogLength (1024 * 5)

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

#endif /* DWLoggerMacro_h */
