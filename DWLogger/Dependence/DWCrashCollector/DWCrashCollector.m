//
//  DWCrashCollector.m
//  DWLogger
//
//  Created by Wicky on 2017/10/12.
//  Copyright © 2017年 Wicky. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "DWCrashCollector.h"
#import "UIDevice+DWDeviceUtils.h"
#import "DWFileManager.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>

volatile int32_t UncaughtExceptionCount = 0;

const int32_t UncaughtExceptionMaximum = 10;


static DWCrashCollector * clt = nil;

static NSString * sP = nil;

static void (^expHandler)(NSException * exp);

@implementation DWCrashCollector

+(void)CollectCrashInDefaultWithSavePath:(NSString *)savePath {
    [self configToCollectCrashWithSavePath:savePath handler:^(NSException *exception) {
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMdd-HHmmss"];
        NSDate * date = [NSDate date];
        NSString * folderName = [formatter stringFromDate:date];
        NSString * path = [sP stringByAppendingPathComponent:[NSString stringWithFormat:@"Crash/%@",folderName]];
        NSString * crashFilePath = [path stringByAppendingPathComponent:@"CrashLog.crash"];
        [DWFileManager dw_CreateFileAtPath:crashFilePath];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString * timeStr = [formatter stringFromDate:date];
        NSString * crashStr = @"";
        crashStr = [crashStr stringByAppendingString:[NSString stringWithFormat:@"Project Name: %@\n",[UIDevice dw_ProjectDisplayName]]];
        crashStr = [crashStr stringByAppendingString:[NSString stringWithFormat:@"Project Bundle ID: %@\n",[UIDevice dw_ProjectBundleId]]];
        crashStr = [crashStr stringByAppendingString:[NSString stringWithFormat:@"Project Version: %@\n",[UIDevice dw_ProjectVersion]]];
        crashStr = [crashStr stringByAppendingString:[NSString stringWithFormat:@"Project Build: %@\n",[UIDevice dw_ProjectBuildNo]]];
        crashStr = [crashStr stringByAppendingString:[NSString stringWithFormat:@"Crash Time: %@\n",timeStr]];
        crashStr = [crashStr stringByAppendingString:[NSString stringWithFormat:@"Device Model: %@\n",[UIDevice dw_DeviceDetailModel]]];
        crashStr = [crashStr stringByAppendingString:[NSString stringWithFormat:@"Device System: %@\n",[UIDevice dw_DeviceSystemVersion]]];
        crashStr = [crashStr stringByAppendingString:[NSString stringWithFormat:@"Device CPU Arch: %@\n",[UIDevice dw_DeviceCPUType]]];
        crashStr = [crashStr stringByAppendingString:[NSString stringWithFormat:@"Crash Detail:\n%@",exception.debugDescription]];
        writeDataString2File(crashStr, crashFilePath);
        saveCrashImage2Path(path);
        printf("\nCrash Log Path Is %s\n\n",crashFilePath.UTF8String);
        
        NSSetUncaughtExceptionHandler(NULL);
        signal(SIGABRT, SIG_DFL);
        signal(SIGILL, SIG_DFL);
        signal(SIGSEGV, SIG_DFL);
        signal(SIGFPE, SIG_DFL);
        signal(SIGBUS, SIG_DFL);
        signal(SIGPIPE, SIG_DFL);
        if ([[exception name] isEqual:@"DWCrashCollectorSignalErrorName"])
        {
            kill(getpid(), [[[exception userInfo] objectForKey:@"DWCrashCollectorSignalKey"] intValue]);
        }
        else
        {
            [exception raise];
        }
    }];
}

+(void)configToCollectCrashWithSavePath:(NSString *)savePath handler:(void (^)(NSException *))handler {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        clt = [self alloc];
        [clt defaultConfigWithSavePath:savePath handler:handler];
    });
}

-(instancetype)defaultConfigWithSavePath:(NSString *)savePath handler:(void(^)(NSException * exp))handler {
    clt = [super init];
    if (clt) {
        sP = savePath;
        expHandler = handler;
        [clt configHandler];
    }
    return clt;
}

-(void)configHandler {
    NSSetUncaughtExceptionHandler(&exceptionHandler);
    signal(SIGABRT, signalCollector);
    signal(SIGILL, signalCollector);
    signal(SIGSEGV, signalCollector);
    signal(SIGFPE, signalCollector);
    signal(SIGBUS, signalCollector);
    signal(SIGPIPE, signalCollector);
}

#pragma mark --- exception Hanlder ---
static void exceptionHandler(NSException *exception)
{
    if (expHandler) {
        expHandler(exception);
    }
//    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyyMMdd-HHmmss"];
//    NSDate * date = [NSDate date];
//    NSString * folderName = [formatter stringFromDate:date];
//    NSString * path = [sP stringByAppendingPathComponent:[NSString stringWithFormat:@"Crash/%@",folderName]];
//    NSString * crashFilePath = [path stringByAppendingPathComponent:@"CrashLog.crash"];
//    [DWFileManager dw_CreateFileAtPath:crashFilePath];
//    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSString * timeStr = [formatter stringFromDate:date];
//    NSString * crashStr = @"";
//    crashStr = [crashStr stringByAppendingString:[NSString stringWithFormat:@"Project Name: %@\n",[UIDevice dw_ProjectDisplayName]]];
//    crashStr = [crashStr stringByAppendingString:[NSString stringWithFormat:@"Project Bundle ID: %@\n",[UIDevice dw_ProjectBundleId]]];
//    crashStr = [crashStr stringByAppendingString:[NSString stringWithFormat:@"Project Version: %@\n",[UIDevice dw_ProjectVersion]]];
//    crashStr = [crashStr stringByAppendingString:[NSString stringWithFormat:@"Project Build: %@\n",[UIDevice dw_ProjectBuildNo]]];
//    crashStr = [crashStr stringByAppendingString:[NSString stringWithFormat:@"Crash Time: %@\n",timeStr]];
//    crashStr = [crashStr stringByAppendingString:[NSString stringWithFormat:@"Device Model: %@\n",[UIDevice dw_DeviceDetailModel]]];
//    crashStr = [crashStr stringByAppendingString:[NSString stringWithFormat:@"Device System: %@\n",[UIDevice dw_DeviceSystemVersion]]];
//    crashStr = [crashStr stringByAppendingString:[NSString stringWithFormat:@"Device CPU Arch: %@\n",[UIDevice dw_DeviceCPUType]]];
//    crashStr = [crashStr stringByAppendingString:[NSString stringWithFormat:@"Crash Detail:\n%@",exception.debugDescription]];
//    writeDataString2File(crashStr, crashFilePath);
//    saveCrashImage2Path(path);
//    printf("\nCrash Log Path Is %s\n\n",crashFilePath.UTF8String);
//
//    NSSetUncaughtExceptionHandler(NULL);
//    signal(SIGABRT, SIG_DFL);
//    signal(SIGILL, SIG_DFL);
//    signal(SIGSEGV, SIG_DFL);
//    signal(SIGFPE, SIG_DFL);
//    signal(SIGBUS, SIG_DFL);
//    signal(SIGPIPE, SIG_DFL);
//    if ([[exception name] isEqual:@"DWCrashCollectorSignalErrorName"])
//    {
//        kill(getpid(), [[[exception userInfo] objectForKey:@"DWCrashCollectorSignalKey"] intValue]);
//    }
//    else
//    {
//        [exception raise];
//    }
}

static void signalCollector(int signal)
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
#pragma clang diagnostic pop
    if (exceptionCount > UncaughtExceptionMaximum) {
        return;
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:@"DWCrashCollectorSignalKey"];
    NSArray *callStack = getBacktrace();
    [userInfo setObject:callStack forKey:@"DWCrashCollectorBackTrace"];
    
    NSString * signalStr = @"Unknown Signal";
    if (signal == SIGABRT) {
        signalStr = @"SIGABRT";
    } else if (signal == SIGILL) {
        signalStr = @"SIGILL";
    } else if (signal == SIGSEGV) {
        signalStr = @"SIGSEGV";
    } else if (signal == SIGFPE) {
        signalStr = @"SIGFPE";
    } else if (signal == SIGBUS) {
        signalStr = @"SIGBUS";
    } else if (signal == SIGPIPE) {
        signalStr = @"SIGPIPE";
    }
    
    NSString * reason = [NSString stringWithFormat:@"%@ error was raised.",
                         signalStr];
    NSException * exc =[NSException exceptionWithName:@"DWCrashCollectorSignalErrorName" reason:reason userInfo:userInfo];
    exceptionHandler(exc);
}

#pragma mark --- inline method ---

static inline void saveCrashImage2Path(NSString * path) {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds),CGRectGetHeight([UIScreen mainScreen].bounds)),NO,1);
    [[UIApplication sharedApplication].keyWindow  drawViewHierarchyInRect:CGRectMake(0,0,CGRectGetWidth([UIScreen mainScreen].bounds),CGRectGetHeight([UIScreen mainScreen].bounds))afterScreenUpdates:NO];
    UIImage *snapshot =UIGraphicsGetImageFromCurrentImageContext();
    [UIImageJPEGRepresentation(snapshot,1.0)writeToFile:[NSString stringWithFormat:@"%@/%@",path,@"CrashSnap.jpg"] atomically:YES];
    UIGraphicsEndImageContext();
}

static inline void writeDataString2File(NSString * data,NSString * path) {
    NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:path];
    [file seekToEndOfFile];
    [file writeData:[data dataUsingEncoding:NSUTF8StringEncoding]];
    [file closeFile];
}

static inline NSArray * getBacktrace() {
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (i = 0;i < backtrace.count;i++)
    {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    return backtrace;
}


#pragma mark --- over write ---
-(instancetype)init {
    return nil;
}

-(id)copyWithZone:(struct _NSZone *)zone {
    return nil;
}

-(id)mutableCopyWithZone:(struct _NSZone *)zone {
    return nil;
}

@end

