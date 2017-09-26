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
+(void)addLog:(NSString *)log {
    DWLogManager * logger = [DWLogManager shareLogManager];
    [logger.logArr addObject:log];
    NSLog(@"%@",[DWLogManager shareLogManager].logArr);
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

-(void)writeLog2File:(NSString *)log {
    log = [log stringByAppendingString:@"\n"];
    dispatch_async(self.writeFileQueue, ^{
        NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:self.logFilePath];
        [file seekToEndOfFile];
        [file writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
        [file closeFile];
    });
}

-(void)configFormatter:(NSDateFormatter *)formatter {
    _timeFormatter = formatter;
}

#pragma mark --- singleton ---
+(instancetype)shareLogManager {
#ifndef DevEvn
    return nil;
#else
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [[DWLogManager alloc] init];
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSSSSS"];
        [mgr configFormatter:formatter];
    });
    return mgr;
#endif
}

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

#pragma mark --- setter/getter ---
-(NSMutableArray *)logArr
{
    if (!_logArr) {
        _logArr = [NSMutableArray array];
    }
    return _logArr;
}

-(NSString *)filePath {
    if (!_filePath) {
        _filePath = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        _filePath = [_filePath stringByAppendingPathComponent:@"log"];
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
