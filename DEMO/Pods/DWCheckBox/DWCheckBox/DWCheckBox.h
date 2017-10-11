//
//  DWChechBox.h
//  DWCheckBox
//
//  Created by Wicky on 2017/2/12.
//  Copyright © 2017年 Wicky. All rights reserved.
//

/**
 DWCheckBox
 
 复选框视图
 
 以不同粒度api让你在不同程度定制复选框视图
 引入时请一同引入DWCheckBoxBundle.bundle
 
 */

#import <UIKit/UIKit.h>

#pragma mark --- DWCheckBoxCellProtocol ---
/**
 自定义checkBox样式cell需遵守协议，cell为UIView及其子类并遵守本协议
 且请在自定义cell需要改变状态的事件中回调selectedBlock
 如果不以DWCheckBoxView作为容器，在需要改变cell图片的事件中实现selectedBlock并调用-cellBeSelected:withImage:方法
 具体可参见DWCheckBoxDefaultCell、DWCheckBoxView内部实现
 */
@protocol DWCheckBoxCellProtocol <NSObject>

///当前cell是否被选中
@property (nonatomic ,assign) BOOL isSelected;

///cell选中状态回调
@property (nonatomic ,copy) void (^selectedBlock)(BOOL selected,__kindof UIView<DWCheckBoxCellProtocol> * view);

///设置cell被选中，及图片
-(void)cellBeSelected:(BOOL)selected withImage:(UIImage *)image;

@end



#pragma mark --- DWCheckBoxView ---
/**
 生成选框视图的默认视图
 
 提供三个不同粒度的api让你可以在几个程度上定制视图，为选框组件提供容器
 
 事实上DWCheckBoxView可以完成对选框视图的全部订制，你完全可以不另行定制容器类。
 */
@class DWCheckBoxManager;
@class DWCheckBoxLayout;
@interface DWCheckBoxView : UIView

///组件数组
@property (nonatomic ,strong,readonly) NSArray <UIView<DWCheckBoxCellProtocol>*>* cells;

///组件个数
@property (nonatomic ,assign) NSUInteger countOfBoxes;

///选择模式
@property (nonatomic ,assign) BOOL multiSelect;

///未选中视图
@property (nonatomic ,strong) UIImage * unSelectedImage;

///选中视图
@property (nonatomic ,strong) UIImage * selectedImage;

///返回当前选择
/**
 复选模式返回数组，单选模式返回选中idx
 */
@property (nonatomic ,strong,readonly) id currentSelected;


/**
 按标题返回默认样式组件数组

 @param titles 标题数组
 @return 组件数组
 */
+(NSArray <UIView<DWCheckBoxCellProtocol>*>*)cellsFromTitles:(NSArray <NSString *>*)titles;

/**
 按标题返回默认样式cell的视图

 @param frame 尺寸
 @param multiSelect 选择模式
 @param titles 标题数组
 @param defaultSelect 默认被选中cell
 @return 实例
 */
-(instancetype)initWithFrame:(CGRect)frame
                 multiSelect:(BOOL)multiSelect
                      titles:(NSArray <NSString *>*)titles
               defaultSelect:(NSArray <NSNumber *>*)defaultSelect;


/**
 返回选择视图

 @param frame 尺寸
 @param layout 布局
 @param multiSelect 选择模式
 @param titles 标题数组
 @param defaultSelect 默认选中
 @return 实例
 */
-(instancetype)initWithFrame:(CGRect)frame
                      layout:(DWCheckBoxLayout *)layout
                 multiSelect:(BOOL)multiSelect
                      titles:(NSArray <NSString *>*)titles
               defaultSelect:(NSArray <NSNumber *>*)defaultSelect;

/**
 返回选择视图

 @param frame 尺寸
 @param multiSelect 选择模式
 @param cells 组件数组
 @param defaultSelect 默认选择idx
 @return 实例
 */
-(instancetype)initWithFrame:(CGRect)frame
                 multiSelect:(BOOL)multiSelect
                       cells:(NSArray <id<DWCheckBoxCellProtocol>> *)cells
               defaultSelect:(NSArray <NSNumber *>*)defaultSelect;


/**
 返回选择视图

 @param frame 尺寸
 @param layout 布局
 @param multiSelect 选择模式
 @param cells 组件数组
 @param defaultSelect   默认勾选项
 @return 实例
 */
-(instancetype)initWithFrame:(CGRect)frame
                      layout:(DWCheckBoxLayout *)layout
                 multiSelect:(BOOL)multiSelect
                       cells:(NSArray <UIView<DWCheckBoxCellProtocol> *>*)cells
               defaultSelect:(NSArray <NSNumber *>*)defaultSelect;

/**
 返回选择视图
 
 @param frame 尺寸
 @param layout 布局
 @param manager 管理者
 @param multiSelect 选择模式
 @param cells 组件数组
 @return 实例
 */
-(instancetype)initWithFrame:(CGRect)frame
                      layout:(DWCheckBoxLayout *)layout
                     manager:(DWCheckBoxManager *)manager
                 multiSelect:(BOOL)multiSelect
                       cells:(NSArray <UIView<DWCheckBoxCellProtocol>*> *)cells;

///选中idx
-(void)selectAtIndex:(NSUInteger)idx;

///取消选中idx
-(void)deselectAtIndex:(NSUInteger)idx;

///全部取消
-(void)deselectAll;

///选中全部
-(void)selectAll;

@end



#pragma mark --- DWCheckBoxLayout ---
/**
 为DWCheckBoxView提供布局的抽象布局类，应使用此类的子类并自行实现-layoutCheckBoxView:cells:方法进行布局
 */
@interface DWCheckBoxLayout : NSObject

/**
 布局方法

 @param checkBoxView checkBox视图
 @param cells 组件数组
 */
-(void)layoutCheckBoxView:(UIView *)checkBoxView
                    cells:(NSArray <UIView<DWCheckBoxCellProtocol>*>*)cells;

@end



#pragma mark --- DWCheckBoxDefaultLayout ---
/**
 默认布局类，提供默认布局
 支持自动换行，长度自动匹配等
 */
@interface DWCheckBoxDefaultLayout : DWCheckBoxLayout

///组件之间间距
@property (nonatomic ,assign) CGFloat spacing;

@end

#pragma mark --- DWCheckBoxDefaultCell ---
/**
 默认组件
 */
@interface DWCheckBoxDefaultCell : UIButton<DWCheckBoxCellProtocol>


/**
 按标题返回默认组件

 @param title 标题
 @return 实例
 */
+(instancetype)cellWithTitle:(NSString *)title;

@end



#pragma mark --- DWCheckBoxManager ---
/**
 按指定模式自动实现选中与取消，DWCheckBoxView的状态管理者
 
 你可以仅仅借助本管理类自主深度定制选框视图
 */
@interface DWCheckBoxManager : NSObject

///复用框标识
@property (nonatomic ,copy) NSString * identifier;

///单选框还是复选框
@property (nonatomic ,assign) BOOL multiSelect;

///未选中视图
@property (nonatomic ,strong) UIImage * unSelectedImage;

///选中视图
@property (nonatomic ,strong) UIImage * selectedImage;

///组件个数
@property (nonatomic ,assign) NSUInteger countOfBoxes;

///返回当前选择
/**
 复选模式返回数组，单选模式返回选中idx
 */
@property (nonatomic ,strong) id currentSelected;

///选择改变的回调
/**
 单选模式返回当前选中idx，复选模式放回当前选中数组
 */
@property (nonatomic ,copy) void (^selectedChangeBlock)(DWCheckBoxManager * mgr,id currentSelect,NSString * identifier);

///实例化方法
-(instancetype)initWithCountOfBoxes:(NSUInteger)countOfBoxes
                       multiSelect:(BOOL)multiSelect
                     defaultSelect:(NSArray <NSNumber *>*)defaultSelect
               selectedChangeBlock:(void(^)(DWCheckBoxManager * mgr,id currentSelect,NSString * identifier))selechtChangeBlock;

///选中idx
-(void)selectAtIndex:(NSUInteger)idx;

///取消选中idx
-(void)deselectAtIndex:(NSUInteger)idx;

///全部取消
-(void)deselectAll;

///选中全部
-(void)selectAll;

@end
