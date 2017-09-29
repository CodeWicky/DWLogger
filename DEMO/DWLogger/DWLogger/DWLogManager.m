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

#define FilePath [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

static DWLogManager * mgr = nil;
@interface DWLogManager ()

@property (nonatomic ,strong) NSMutableArray * logArr;

@property (nonatomic ,copy) NSString * filePath;

@property (nonatomic ,copy) NSString * logFileName;

@property (nonatomic ,strong) dispatch_queue_t writeFileQueue;

@end

@implementation DWLogManager
@synthesize logFilePath = _logFilePath;
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

+(void)addLog:(NSString *)log filter:(DWLoggerFilter)filter {
    DWLogManager * logger = [DWLogManager shareLogManager];
    if (logger.logFilter & filter && logger.logView) {
        DWLogModel * model = [DWLogModel new];
        
        NSMutableAttributedString * aStr = [[NSMutableAttributedString alloc] initWithString:log];
        if (logger.particularLog) {
            NSRange r;
            if (filter == DWLoggerInfo) {
                r = [log rangeOfString:@"INFO"];
                [aStr addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:r];
            } else if (filter == DWLoggerWarning) {
                r = [log rangeOfString:@"WARNING"];
                [aStr addAttribute:NSForegroundColorAttributeName value:[UIColor yellowColor] range:r];
            } else if (filter == DWLoggerError) {
                r = [log rangeOfString:@"ERROR"];
                [aStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:r];
            }
        }
        model.logString = aStr;
        [[DWLogView loggerContainer] addObject:model];
        [DWLogView updateLog];
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
        [logger writeLog2File:log];
    }
}

+(void)removeAllLogBackUp {
    [DWFileManager dw_ClearDirectoryAtPath:[DWLogManager shareLogManager].filePath];
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
    DWLog(@"%@",[NSThread callStackSymbols]);
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
    NSString * crashFileName = [formatter stringFromDate:[NSDate date]];
    crashFileName = [crashFileName stringByAppendingString:@".crash"];
    NSString * path = [FilePath stringByAppendingPathComponent:@"Crash"];
    NSString * crashFilePath = [path stringByAppendingPathComponent:crashFileName];
    [DWFileManager dw_CreateFileAtPath:crashFilePath];
    writeDataString2File(exception.debugDescription, crashFilePath, dispatch_queue_create("com.crashQueue.DWLogManager", DISPATCH_QUEUE_SERIAL));
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
    dispatch_async(queue, ^{
        NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:path];
        [file seekToEndOfFile];
        [file writeData:[data dataUsingEncoding:NSUTF8StringEncoding]];
        [file closeFile];
    });
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

-(NSString *)logFilePath {
    if (!_logFilePath) {
        _logFilePath = [self.filePath stringByAppendingPathComponent:self.logFileName];
    }
    return _logFilePath;
}

@end
