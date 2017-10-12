//
//  DWLogManager.m
//  DWLogger
//
//  Created by Wicky on 2017/9/26.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "DWLogManager.h"
#import "DWLogger.h"
#import "DWFileManager.h"
#import "UIDevice+DWDeviceUtils.h"

#define FilePath [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define NSRangeNull NSMakeRange(MAXFLOAT, MAXFLOAT)

static DWLogManager * mgr = nil;
@interface DWLogManager ()

@property (nonatomic ,strong) NSMutableArray * logArr;

@property (nonatomic ,copy) NSString * filePath;

@property (nonatomic ,copy) NSString * logFileName;

@property (nonatomic ,strong) dispatch_queue_t writeFileQueue;

@end

@implementation DWLogManager
@synthesize logFilePath = _logFilePath;
@synthesize projectName = _projectName;
#pragma mark --- interface method ---
+(instancetype)shareLogManager {
#ifndef DevEvn
    return nil;
#else
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [[DWLogManager alloc] init];
        mgr.logFilter = DWLoggerAll;
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSSSSS"];
        [mgr configFormatter:formatter];
    });
    return mgr;
#endif
}

+(void)addLog:(NSString *)log prefix:(NSString *)prefix filter:(DWLoggerFilter)filter {
    DWLogManager * logger = [DWLogManager shareLogManager];
    if (logger.logView) {
        DWLogModel * model = [DWLogModel new];
        NSMutableAttributedString * aStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",prefix,log]];
        NSRange r = NSRangeNull;
        if (filter == DWLoggerNormal) {
            r = [prefix rangeOfString:@"NORMAL"];
            [aStr addAttribute:NSForegroundColorAttributeName value:[UIColor cyanColor] range:r];
        } else if (filter == DWLoggerInfo) {
            r = [prefix rangeOfString:@"INFO"];
            [aStr addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:r];
        } else if (filter == DWLoggerWarning) {
            r = [prefix rangeOfString:@"WARNING"];
            [aStr addAttribute:NSForegroundColorAttributeName value:[UIColor yellowColor] range:r];
        } else if (filter == DWLoggerError) {
            r = [prefix rangeOfString:@"ERROR"];
            [aStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:r];
        } else if (filter == DWLoggerAll) {
            r = [aStr.string rangeOfString:log];
            [aStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:r];
        }
        model.absoluteLog = log;
        model.logString = aStr;
        model.filter = filter;
        [[DWLogView loggerContainer] addObject:model];
        if (([DWLogManager shareLogManager].logFilter & DWLoggerAll) && (filter != DWLoggerIgnore)) {
            [DWLogView updateLog:model filter:filter];
        }
    }
    if (logger.autoBackUp) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (!logger.writeFileQueue) {
                logger.writeFileQueue = dispatch_queue_create("com.writeFileQueue.DWLogManager", DISPATCH_QUEUE_SERIAL);
            }
            if (![DWFileManager dw_IsFileAtPath:logger.logFilePath]) {
                dispatch_async(logger.writeFileQueue, ^{
                    [DWFileManager dw_CreateFileAtPath:logger.logFilePath];
                });
            }
        });
        [logger writeLog2File:[NSString stringWithFormat:@"%@%@",prefix,log]];
    }
}

+(void)removeAllLogBackUp {
    [DWFileManager dw_ClearDirectoryAtPath:[DWLogManager shareLogManager].filePath];
}

+(void)removeAllCrashBackUp {
    [DWFileManager dw_ClearDirectoryAtPath:[FilePath stringByAppendingPathComponent:@"Crash"]];
}

+(void)removeCurrentLogBackUp {
    [DWFileManager dw_RemoveItemAtPath:[DWLogManager shareLogManager].logFilePath];
}

+(void)setupLogView:(id)logView {
    [[DWLogManager shareLogManager] configLoggerView:logView];
}

+(void)clearCurrentLog {
    if ([DWLogManager shareLogManager].logView) {
        [[DWLogView loggerContainer] removeAllObjects];
    }
}

+(void)configDefaultLogger {
    [DWLogManager configLoggerWithFilter:DWLoggerAll needLogView:YES];
}

+(void)configLoggerWithFilter:(DWLoggerFilter)filter needLogView:(BOOL)need {
    DWLogManager * logger = [DWLogManager shareLogManager];
    logger.logFilter = filter;
    logger.particularLog = YES;
    logger.autoBackUp = YES;
    if (need) {
        [DWLogView configDefaultLogView];
        [DWLogManager setupLogView:[DWLogView shareLogView]];
    }
}

+(void)printCallStackSymbols {
    DWLog(@"Call Stack Symbols are :\n%@",[NSThread callStackSymbols]);
}

+(void)printLoggerMainPath {
    DWLog(@"Logger main path is :\n%@",FilePath);
}

+(void)configToCollectCrash {
#ifndef DevEvn
    return;
#endif
    NSSetUncaughtExceptionHandler(&exceptionHandler);
}

static void exceptionHandler(NSException *exception)
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd-HHmmss"];
    NSDate * date = [NSDate date];
    NSString * folderName = [formatter stringFromDate:date];
    NSString * path = [FilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"Crash/%@",folderName]];
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
    writeDataString2File(crashStr, crashFilePath, NULL);
    saveCrashImage2Path(path);
    printf("\nCrash Log Path Is %s\n\n",[crashFilePath cStringUsingEncoding:NSUTF8StringEncoding]);
}

#pragma mark --- tool method ---
-(void)writeLog2File:(NSString *)log {
    log = [log stringByAppendingString:@"\n"];
    writeDataString2File(log, self.logFilePath,self.writeFileQueue);
}

-(void)configLoggerView:(DWLogView *)logView {
    _logView = logView;
}

-(void)configFormatter:(NSDateFormatter *)formatter {
    _timeFormatter = formatter;
}

#pragma mark --- singleton ---

+(instancetype)allocWithZone:(struct _NSZone *)zone {
#ifndef DevEvn
    return nil;
#else
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [super allocWithZone:zone];
    });
    return mgr;
#endif
}

-(instancetype)copyWithZone:(struct _NSZone *)zone {
    return self;
}

-(id)mutableCopyWithZone:(struct _NSZone *)zone {
    return self;
}

#pragma mark --- inline method ---
static inline void writeDataString2File(NSString * data,NSString * path,dispatch_queue_t queue) {
    void(^block)(void) = ^(void) {
        NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:path];
        [file seekToEndOfFile];
        [file writeData:[data dataUsingEncoding:NSUTF8StringEncoding]];
        [file closeFile];
    };
    if (queue == NULL) {
        block();
    } else {
        dispatch_async(queue, block);
    }
}

static inline void saveCrashImage2Path(NSString * path) {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds),CGRectGetHeight([UIScreen mainScreen].bounds)),NO,1);
    [[UIApplication sharedApplication].keyWindow  drawViewHierarchyInRect:CGRectMake(0,0,CGRectGetWidth([UIScreen mainScreen].bounds),CGRectGetHeight([UIScreen mainScreen].bounds))afterScreenUpdates:NO];
    UIImage *snapshot =UIGraphicsGetImageFromCurrentImageContext();
    [UIImageJPEGRepresentation(snapshot,1.0)writeToFile:[NSString stringWithFormat:@"%@/%@",path,@"CrashSnap.jpg"] atomically:YES];
    UIGraphicsEndImageContext();
}

#pragma mark --- setter/getter ---
-(NSMutableArray *)logArr
{
    if (!_logArr) {
        if (self.logView) {
            _logArr = [DWLogView loggerContainer];
        }
    }
    return _logArr;
}

-(NSString *)filePath {
    if (!_filePath) {
        _filePath = [FilePath stringByAppendingPathComponent:@"Log"];
    }
    return _filePath;
}

-(NSString *)logFileName {
    if (!_logFileName) {
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMdd-HHmmss"];
        _logFileName = [formatter stringFromDate:[NSDate date]];
        _logFileName = [_logFileName stringByAppendingString:@".log"];
    }
    return _logFileName;
}

-(NSString *)projectName {
    if (!_projectName) {
        _projectName = [UIDevice dw_ProjectDisplayName];
    }
    return _projectName;
}

-(NSString *)logFilePath {
    if (!_logFilePath) {
        _logFilePath = [self.filePath stringByAppendingPathComponent:self.logFileName];
    }
    return _logFilePath;
}

@end
