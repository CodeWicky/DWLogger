//
//  DWCrashCollector.h
//  DWLogger
//
//  Created by Wicky on 2017/10/12.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWCrashCollector : NSObject<UIAlertViewDelegate>

+(void)configToCollectCrashWithSavePath:(NSString *)savePath handler:(void(^)(NSException * exception))handler;

+(void)CollectCrashInDefaultWithSavePath:(NSString *)savePath;

@end
