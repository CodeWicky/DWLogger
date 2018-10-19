//
//  DWLogManager.m
//  DWLogger
//
//  Created by Wicky on 2017/9/26.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "DWLogManager.h"
#import "DWLogger.h"
#import "DWLogView.h"
#import "DWFileManager.h"
#import "UIDevice+DWDeviceUtils.h"
#import "DWCrashCollector.h"
#import "UIWindow+DWLoggerShake.h"

NSNotificationName const DWLoggerDeviceShakeNotification = @"DWLoggerDeviceShakeNotification";

#define FilePath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"DWLogger"]

#define NSRangeNull NSMakeRange(MAXFLOAT, MAXFLOAT)

static DWLogManager * mgr = nil;
@interface DWLogManager ()

@property (nonatomic ,strong) NSMutableArray * logArr;

@property (nonatomic ,copy) NSString * filePath;

@property (nonatomic ,copy) NSString * logFileName;

@property (nonatomic ,strong) dispatch_queue_t writeFileQueue;

@property (nonatomic ,strong) dispatch_queue_t updateLogQueue;

@property (nonatomic ,assign) BOOL enableShakeControl;

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
        mgr.saveLocalLog = YES;
        mgr.logFilter = DWLoggerAll;
        mgr.maxLogLength = MaxLogLength;
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSSSSS"];
        [mgr configFormatter:formatter];
        [[NSNotificationCenter defaultCenter] addObserver:mgr selector:@selector(receiveShakeNotification:) name:DWLoggerDeviceShakeNotification object:nil];
    });
    return mgr;
#endif
}

+(void)addLog:(NSString *)log prefix:(NSString *)prefix filter:(DWLoggerFilter)filter {
    DWLogManager * logger = [DWLogManager shareLogManager];
    if (logger.logView) {
        DWLogModel * model = [DWLogModel new];
        NSString * logTemp = [log copy];
        NSInteger maxL = logger.maxLogLength;
        if (logTemp.length > maxL) {
            logTemp = [logTemp substringToIndex:maxL];
            NSString * ignoreString = [NSString stringWithFormat:@"The log is too long whose length is more than %ld,DWLogger has abstracted it.The abstract is :\n",(long)maxL];
            logTemp = [NSString stringWithFormat:@"%@%@...",ignoreString,logTemp];
        }
        NSMutableAttributedString * aStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",prefix,logTemp]];
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
            r = [aStr.string rangeOfString:logTemp];
            [aStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:r];
        }
        model.absoluteLog = log;
        model.logString = aStr;
        model.filter = filter;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            logger.updateLogQueue = dispatch_queue_create("com.updateLogQueue.DWLogManager", DISPATCH_QUEUE_SERIAL);
        });
        dispatch_sync(logger.updateLogQueue, ^{
            [[DWLogManager shareLogManager].logArr addObject:model];
        });
        if (([DWLogManager shareLogManager].logFilter & DWLoggerAll) && (filter != DWLoggerIgnore)) {
            [DWLogView updateLog:model filter:filter];
        }
    }
    if (logger.autoBackUp && logger.saveLocalLog) {
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

+(void)enableShakeToSwitchPot:(BOOL)enable {
    [DWLogManager shareLogManager].enableShakeControl = enable;
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
        [DWLogView clearCurrentLog];
    }
}

+(void)configDefaultLogger {
    [DWLogManager configLoggerWithFilter:DWLoggerAll needLogView:YES];
    [DWFloatPot sharePot].alpha = 0;
    [DWLogManager enableShakeToSwitchPot:YES];
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
    [DWCrashCollector collectCrashInDefaultWithSavePath:FilePath];
}

#pragma mark --- tool method ---
-(void)writeLog2File:(NSString *)log {
    log = [log stringByAppendingString:@"\n"];
    dispatch_async(self.writeFileQueue, ^{
        NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:self.logFilePath];
        [file seekToEndOfFile];
        [file writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
        [file closeFile];
    });
}

-(void)configLoggerView:(DWLogView *)logView {
    _logView = logView;
}

-(void)configFormatter:(NSDateFormatter *)formatter {
    _timeFormatter = formatter;
}

-(void)receiveShakeNotification:(NSNotification *)notice {
    if (self.enableShakeControl) {
        if ([DWFloatPot isShowing]) {
            [DWLogView hidePot];
        } else {
            [DWLogView showPot];
        }
    }
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

#pragma mark --- override ---
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

-(void)setSaveLocalLog:(BOOL)saveLocalLog {
    _saveLocalLog = saveLocalLog;
    [DWFloatPot enableSaveLocalLogUI:saveLocalLog];
}
@end
