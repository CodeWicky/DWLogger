//
//  DWLogger.h
//  DWLogger
//
//  Created by Wicky on 2017/9/26.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#ifndef DWLogger_h
#define DWLogger_h

#import "DWLogManager.h"
#import "DWLogView.h"

#if DEBUG
#define DevEvn//开发环境标识符
#endif

#define DWLog(...) \
do {\
    DWLogWithFilter(DWLoggerAll,__VA_ARGS__);\
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
NSString * temp = [NSString stringWithFormat:__VA_ARGS__];\
NSString * prefix = nil;\
switch (f) {\
case DWLoggerInfo:\
prefix = @"INFO: ";\
break;\
case DWLoggerError:\
prefix = @"ERROR: ";\
break;\
case DWLoggerWarning:\
prefix = @"WARNING: ";\
break;\
default:\
prefix = @"";\
break;\
}\
temp = [prefix stringByAppendingString:temp];\
if (logger.logFilter & f) {\
NSLog(@"%@",temp);\
}\
if (!logger.disableLogger) {\
NSString * logStr = @"";\
if (logger.particularLog) {\
NSString * timeStr = [logger.timeFormatter stringFromDate:[NSDate date]];\
logStr = [logStr stringByAppendingString:timeStr];\
NSString * file = [[NSString stringWithUTF8String:__FILE__] lastPathComponent];\
logStr = [logStr stringByAppendingString:[NSString stringWithFormat:@" [%@",file]];\
logStr = [logStr stringByAppendingString:[NSString stringWithFormat:@" line:%d method:%@] ",__LINE__,NSStringFromSelector(_cmd)]];\
}\
logStr = [logStr stringByAppendingString:temp];\
[DWLogManager addLog:logStr filter:f];\
}\
} while (0)

#else

#define DWLogWithFilter(f,FORMAT, ...)

#endif



#endif /* DWLogger_h */
