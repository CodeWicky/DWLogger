//
//  DWLogger.h
//  DWLogger
//
//  Created by Wicky on 2017/9/26.
//  Copyright © 2017年 Wicky. All rights reserved.
//

/**
 DWLogger
 日志扩展管理类
 
 提供Debug模式下的日志管理功能，Release模式下屏蔽日志输出及管理功能。
 提供不同日志输出等级，并提供手机端日志查看助手。
 提供日志备份及崩溃捕捉等功能
 
 DWLog() 此Log模式不受过滤器影响，任何情况下均高亮显示
 DWLogNormal() 此模式为普通日志模式，可以通过过滤器过滤掉此类日志以方便查看重要信息（默认情况下NSLog会被替换为此模式日志）
 DWLogInfo() 此模式为信息模式，输出重要信息，可通过过滤器控制显隐
 DWLogWarning() 此模式为警告模式，输出警告信息，可通过过滤器控制显隐
 DWLogError() 此模式为错误模式，输出错误信息，可通过过滤器控制显隐
 
 使用时在pch中引用DWLogger.h即可完成Log的全局替换。
 
 请在Appdelegate中程序启动后调用[DWLogManager configDefaultLogger]进行日志捕捉。若想在Debug模式下手机崩溃日志可调用[DWLogManager configToCollectCrash]进行手机。
 
 其他一些辅助工具属性请查看DWLogManager中属性注释并合理使用。
 
 version 1.0.0
 提供不同等级日志输出
 提供手机端日志查看助手
 提供日志备份及崩溃捕捉功能
 Release模式下屏蔽所有功能
 
 version 1.0.0.1
 添加NSLog替换为DWLog的日志替换宏
 DWLog中日志输出函数改为printf函数，防止NSLog宏的循环调用
 修复不选详细日志模式时模式前缀颜色失效问题
 
 version 1.0.0.2
 过滤器逻辑修改
 添加日志搜索模式相关逻辑
 添加iOS11适配
 修复tableView的header、footer高度适配
 适配iOS8
 
 version 1.0.0.3
 增加DWLogNormal()模式，并以此替换系统日志，方便过滤基本日志
 崩溃日志增加设备的基本信息
 搜索模式忽略大小写
 
 version 1.0.1
 修改崩溃日志保存策略，以防保存失败，同时添加崩溃截图
 添加删除崩溃日志API
 修改路径打印文案
 
 version 1.0.2
 完善崩溃捕捉，捕捉异常与信号类崩溃
 
 version 1.0.2.1
 冗余代码删除
 
 version 1.0.3
 崩溃捕捉类更新
 
 versino 1.0.4
 修复问题
 
 version 1.0.5
 日志最大显示长度属性添加
 修改搜索交互
 改善更新列表逻辑
 
 version 1.0.6
 添加交互模式下透明度展示
 改变头文件引用逻辑，优化pch中表现
 
 version 1.0.6.1
 修复并行下tableView更新崩溃问题
 
 version 1.0.7
 添加控制日志是否写本地开关
 添加Logger打点交互
 优化列表刷新逻辑（非展开模式不刷新列表，只更新数据源）
 修复过滤模式下添加被过滤掉的日志模式引起的刷新崩溃问题（DWLogView.m line:614）
 
 version 1.0.7.1
 修改更新逻辑，弃用插入模式，改为刷新模式（提升性能，简化逻辑）
 修改日志展开模式下日志刷新逻辑，非实时刷新，而是每0.5秒按需刷新一次，以此模拟缓冲池，以降低刷新频率
 修复搜索栏输入文字但不点击搜索再次添加日志时自动进入搜索模式的bug。当前仅点击搜索且搜索条件不为空是为搜索模式。
 
 version 1.0.7.2
 添加主线程宏，将一些需要在主线程中执行的任务安全提交到主线程
 
 version 1.0.7.3
 添加摇晃手机模式控制是否展示浮窗
 修改浮窗拖动范围
 
 version 1.0.7.4
 fixBug:修复手动设置不收集日志时内部按钮图标为改变的bug
 
 version 1.0.8
 fixBug:修复缓冲池在sx清空日志后引起崩溃的问题
 适配iPx等具备刘海的机型
 修改缓冲池刷新机制，若不在显示范围内不刷新
 
 version 1.0.8.1
 添加日志中双击即为复制本条日志至系统粘贴板功能
 
 version 1.0.8.2
 修复高亮日志后f无法取消的bug
 复制日志时添加颜色变化交互
 
 */

#ifndef DWLogger_h
#define DWLogger_h

#import "DWLogManager.h"
#import "DWLoggerMacro.h"


#endif /* DWLogger_h */
