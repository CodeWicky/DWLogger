//
//  DWLogView.h
//  DWLogger
//
//  Created by Wicky on 2017/9/27.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWTableViewHelper.h"
#import "DWLogManager.h"

@interface DWLogModel : DWTableViewHelperModel

///组装完成的全部Log字符串
@property (nonatomic ,strong) NSAttributedString * logString;

///纯输出的日志
@property (nonatomic ,copy) NSString * absoluteLog;

///当前日志对应类型
@property (nonatomic ,assign) DWLoggerFilter filter;

@end

@interface DWLogView : UIWindow

///LogView是否正在展示
@property (nonatomic ,assign ,readonly) BOOL isShowing;

///LogView是否允许交互
@property (nonatomic ,assign ,readonly) BOOL interactionEnabled;

///单例方法
+(instancetype)shareLogView;

///开启交互
+(void)enableUserInteraction;

///关闭交互
+(void)disableUserInteraction;

///展示日志视图
+(void)showLogView;

///隐藏日志视图
+(void)hideLogView;

///配置默认LogView
+(void)configDefaultLogView;

///返回日志容器
+(NSMutableArray *)loggerContainer;

///更新日志
+(void)updateLog:(DWLogModel *)logModel filter:(DWLoggerFilter)filter;
@end

@interface DWFloatPot : UIWindow;

///单例方法
+(instancetype)sharePot;

@end
