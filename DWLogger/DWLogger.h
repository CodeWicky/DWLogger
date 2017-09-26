//
//  DWLogger.h
//  DWLogger
//
//  Created by Wicky on 2017/9/26.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#ifndef DWLogger_h
#define DWLogger_h

#if DEBUG
#define DevEvn//开发环境标识符
#endif

#import "DWLogManager.h"

#ifdef DevEvn

#define DWLog(FORMAT, ...) \
do {\
NSLog(FORMAT,##__VA_ARGS__);\
DWLogManager * logger = [DWLogManager shareLogManager];\
if (!logger.disableLogger) {\
NSString * logStr = @"";\
if (logger.particularLog) {\
NSString * timeStr = [logger.timeFormatter stringFromDate:[NSDate date]];\
logStr = [logStr stringByAppendingString:timeStr];\
NSString * file = [[NSString stringWithUTF8String:__FILE__] lastPathComponent];\
logStr = [logStr stringByAppendingString:[NSString stringWithFormat:@" [%@",file]];\
logStr = [logStr stringByAppendingString:[NSString stringWithFormat:@" line:%d method:%@] ",__LINE__,NSStringFromSelector(_cmd)]];\
}\
logStr = [logStr stringByAppendingString:[NSString stringWithFormat:FORMAT,##__VA_ARGS__]];\
[DWLogManager addLog:logStr];\
}\
} while (0);

#else

#define DWLog(FORMAT, ...)

#endif

#endif /* DWLogger_h */
