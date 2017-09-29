//
//  DWLogView.h
//  DWLogger
//
//  Created by Wicky on 2017/9/27.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWTableViewHelper.h"

@interface DWLogView : UIWindow

@property (nonatomic ,assign ,readonly) BOOL isShowing;

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
+(void)updateLog;
@end

@interface DWFloatPot : UIWindow;

///单例方法
+(instancetype)sharePot;

@end

@interface DWLogModel : DWTableViewHelperModel

@property (nonatomic ,copy) NSAttributedString * logString;

@end
