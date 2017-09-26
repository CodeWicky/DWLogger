//
//  DWLogManager.h
//  DWLogger
//
//  Created by Wicky on 2017/9/26.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWLogManager : NSObject

///是否允许Logger收集日志，若不予许收集日志则相关功能均失效（默认为NO）
@property (nonatomic ,assign) BOOL disableLogger;

///是否要转化为详细日志（默认为NO）
@property (nonatomic ,assign) BOOL particularLog;

///是否自动备份日志至沙盒（默认为NO）
@property (nonatomic ,assign) BOOL autoBackUp;

///自动备份日志沙盒地址
@property (nonatomic ,copy ,readonly) NSString * logFilePath;

/**
 日志时间格式化（勿改）
 */
@property (nonatomic ,strong ,readonly) NSDateFormatter * timeFormatter;

///单例方法
+(instancetype)shareLogManager;

///添加日志
+(void)addLog:(NSString *)log;

@end
