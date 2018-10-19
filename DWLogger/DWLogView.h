//
//  DWLogView.h
//  DWLogger
//
//  Created by Wicky on 2017/9/27.
//  Copyright © 2017年 Wicky. All rights reserved.
//

/**
 日志视图
 
 展示日志
 */

#import <UIKit/UIKit.h>
#import <DWTableViewHelper/DWTableViewHelper.h>
#import "DWLogManager.h"

@class DWLogModel;
@interface DWLogView : UIWindow

///LogView是否正在展示
///A flag indicates whether logView is showing.
@property (nonatomic ,assign ,readonly) BOOL isShowing;

///LogView是否允许交互
///A flag indicates whether logView accept interaction.
@property (nonatomic ,assign ,readonly) BOOL interactionEnabled;

///单例方法
///Singleton.
+(instancetype)shareLogView;

///开启交互
///Enable logView to accept interaction.
+(void)enableUserInteraction;

///关闭交互
///Disable logview interaction.
+(void)disableUserInteraction;

///展示浮窗
///Show float pot.
+(void)showPot;

///隐藏浮窗
///Hide float pot.
+(void)hidePot;

///展示日志视图
///Show LogView.
+(void)showLogView;

///隐藏日志视图
///Hide LogView.
+(void)hideLogView;

///配置默认LogView
///Config LogView by default.
+(void)configDefaultLogView;

///返回日志容器（无需调用）
///Return array of all logs.（Actually you needn't call it）
+(NSMutableArray *)loggerContainer;

///清除当前日志
///Clear current logs on screen.
+(void)clearCurrentLog;

///更新日志（无需调用）
///Update log on screen.（Actually you needn't call it）
+(void)updateLog:(DWLogModel *)logModel filter:(DWLoggerFilter)filter;
@end

#pragma mark --- Tool Class ---
@interface DWLogModel : DWTableViewHelperModel

///组装完成的全部Log字符串
///Log string with details and attributes.
@property (nonatomic ,strong) NSAttributedString * logString;

///纯输出的日志
///Pure log.
@property (nonatomic ,copy) NSString * absoluteLog;

///当前日志对应类型
///Filter for current Log.
@property (nonatomic ,assign) DWLoggerFilter filter;

@end

@interface DWFloatPot : UIWindow;

///单例方法
///Singleton.
+(instancetype)sharePot;

///是否正在展示
///Indicate whether the pot is showing.
+(BOOL)isShowing;

///设置UI为是否允许保存本地日志
///Config UI to indicate whether enable save local log.
+(void)enableSaveLocalLogUI:(BOOL)enable;

@end
