//
//  DWLogView.m
//  DWLogger
//
//  Created by Wicky on 2017/9/27.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "DWLogView.h"
#import <DWCheckBox/DWCheckBox.h>
#import "DWLogger.h"
#import "NSArray+DWArrayUtils.h"
#import "DWSearchView.h"

///主线程取值
#define safeMainThreadGetValue(a) \
({\
__block typeof(a)value;\
safeMainThreadCode(value = a);\
value;\
});

///主线程赋值（把b值赋给a）
#define safeMainThreadSetValue(a,b) safeMainThreadCode(a = b)

///主线程执行一句代码（无需分号）
#define safeMainThreadCode(a) \
do {\
if ([NSThread isMainThread]) {\
a;\
} else {\
dispatch_sync(dispatch_get_main_queue(), ^{\
a;\
});\
}\
} while (0)

///主线程执行Block（a应该是一个dispatch_block_t）
#define safeMainThreadBlock(a) \
do {\
if ([NSThread isMainThread]) {\
a();\
} else {\
dispatch_sync(dispatch_get_main_queue(), a);\
}\
} while (0)

#define BtnLength (44)
#define BtnSpacing (20)
#define SpeedScale (400)
#define CheckViewHeight (102)

@interface DWFloatPotViewController : UIViewController<UIGestureRecognizerDelegate>

@property (nonatomic ,assign) CGFloat width;

@property (nonatomic ,assign) CGFloat height;

@property (nonatomic ,strong) UIView * containerView;

@property (nonatomic ,strong) UIButton * switchBtn;

@property (nonatomic ,strong) UIButton * saveBtn;

@property (nonatomic ,strong) UIButton * logSwitch;

@property (nonatomic ,strong) UIButton * interactionBtn;

@property (nonatomic ,strong) UIButton * clearLogBtn;

@property (nonatomic ,strong) UIButton * modeBtn;

@property (nonatomic ,assign) BOOL disableClick;

@property (nonatomic ,strong) UIPanGestureRecognizer * panGes;

@property (nonatomic ,strong) UILongPressGestureRecognizer * longGes;

@property (nonatomic ,strong) NSArray <UIView *>* itemsArr;

@property (nonatomic ,strong) DWCheckBoxView * checkView;

@property (nonatomic ,assign) BOOL checkIsShowing;

-(void)hideCheckView;

@end



@interface DWLogViewController : UIViewController

@property (nonatomic ,strong) UITableView * mainTab;

@property (nonatomic ,strong) DWTableViewHelper * helper;

@property (nonatomic ,strong) NSMutableArray * dataArr;

@property (nonatomic ,strong) NSMutableArray * filterLogArray;

@property (nonatomic ,assign) BOOL filterLogArrayNeedChange;

@property (nonatomic ,strong) DWSearchView * searchView;

@property (nonatomic ,strong) UIView * searchContainer;

@property (nonatomic ,strong) NSMutableArray * searchIndexArray;

@property (nonatomic ,assign) BOOL searchMode;

@property (nonatomic ,assign) NSInteger highlightIndex;

@property (nonatomic ,strong) DWLogModel * highligthModel;

@property (nonatomic ,assign) BOOL needModeChangeReloadTab;

@property (nonatomic ,assign) BOOL needDataSourceChangeReloadTab;

@property (nonatomic ,assign) BOOL needLogPoolReloadTab;

@property (nonatomic ,assign) NSUInteger loadedCount;

@end



static DWFloatPot * pot = nil;
@implementation DWFloatPot

#pragma mark --- interface method ---
+(instancetype)sharePot {
#ifndef DevEvn
    return nil;
#else
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        safeMainThreadBlock(^(){
            pot = [[DWFloatPot alloc] initWithFrame:[UIScreen mainScreen].bounds];
            pot.windowLevel = UIWindowLevelAlert + 2;
            pot.backgroundColor = [UIColor clearColor];
            pot.hidden = NO;
            pot.rootViewController = [DWFloatPotViewController new];
        });
    });
    return pot;
#endif
}

+(void)showPot {
#ifdef DevEvn
    safeMainThreadBlock(^(){
        [DWFloatPot sharePot].hidden = NO;
        [UIView animateWithDuration:0.4 animations:^{
            [DWFloatPot sharePot].alpha = 1;
        }];
    });
#endif
}

+(void)hidePot {
#ifdef DevEvn
    safeMainThreadBlock(^(){
        [UIView animateWithDuration:0.4 animations:^{
            [DWFloatPot sharePot].alpha = 0;
        } completion:^(BOOL finished) {
            [DWFloatPot sharePot].hidden = YES;
        }];
    });
#endif
}

+(void)enableSaveLocalLogUI:(BOOL)enable {
#ifdef DevEvn
    safeMainThreadBlock(^(){
        ((DWFloatPotViewController *)pot.rootViewController).saveBtn.selected = !enable;
    });
#endif
}

+(BOOL)isShowing {
    BOOL hidden = safeMainThreadGetValue([DWFloatPot sharePot].hidden);
    CGFloat alpha = safeMainThreadGetValue([DWFloatPot sharePot].alpha);
    return !hidden && alpha;
}

#pragma mark --- singleton ---
+(instancetype)allocWithZone:(struct _NSZone *)zone {
#ifndef DevEvn
    return nil;
#else
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pot = [super allocWithZone:zone];
    });
    return pot;
#endif
}

-(instancetype)copyWithZone:(struct _NSZone *)zone {
    return self;
}

-(instancetype)mutableCopyWithZone:(struct _NSZone *)zone {
    return self;
}

#pragma mark --- override ---
-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView * view = [super hitTest:point withEvent:event];
    if ([view isEqual:self.rootViewController.view]) {///当前响应者为FloatView的rootViewController的根视图
        DWFloatPotViewController * vc = (DWFloatPotViewController *)[DWFloatPot sharePot].rootViewController;
        if (vc.checkIsShowing) {///如果有展示checkView的话收起checkView，此时应该是FloatView所属window响应
            [vc hideCheckView];
            return view;
        }
        return nil;///否则没有点击到FloatPot的按钮，应该LogView响应
    }
    return view;///返回不为根视图，则有可能为nil或者FloatView的button。
}
@end

@interface DWLogModel ()

@property (nonatomic ,assign) BOOL highlighted;

@end

@implementation DWLogModel

-(instancetype)init {
    if (self = [super init]) {
        self.cellClassStr = @"DWlogCell";
    }
    return self;
}

@end



@interface DWlogCell : DWTableViewHelperCell

@property (nonatomic ,strong) UILabel * logLb;

@property (nonatomic ,assign) BOOL highlight;

-(void)setBackgroundHighlight:(BOOL)highlight;

@end

@implementation DWlogCell

#pragma mark --- interface method ---
/**
 是否展示高亮状态

 @param highlight 高亮状态
 */
-(void)setBackgroundHighlight:(BOOL)highlight {
    if (highlight) {
        if (!self.highlight) {
            safeMainThreadBlock(^(){
                self.contentView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:0 alpha:0.7];
                [UIView animateWithDuration:0.4 animations:^{
                    self.contentView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:0 alpha:0.3];
                }];
            });
            
        }
    } else {
        safeMainThreadCode(self.contentView.backgroundColor = [UIColor clearColor]);
    }
    self.highlight = highlight;
}


#pragma mark --- tool method ---
-(void)setupUI {
    [super setupUI];
    self.logLb = [[UILabel alloc] init];
    self.logLb.numberOfLines = 0;
    [self.contentView addSubview:self.logLb];
    self.logLb.textColor = [UIColor lightTextColor];
    self.backgroundColor = [UIColor clearColor];
    self.logLb.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.logLb attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:15];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.logLb attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-15];
    NSLayoutConstraint *upConstraint = [NSLayoutConstraint constraintWithItem:self.logLb attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *downConstraint = [NSLayoutConstraint constraintWithItem:self.logLb attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-15];
    [self.contentView addConstraint:leftConstraint];
    [self.contentView addConstraint:rightConstraint];
    [self.contentView addConstraint:upConstraint];
    [self.contentView addConstraint:downConstraint];
    
    self.logLb.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tap.numberOfTapsRequired = 2;
    [self.logLb addGestureRecognizer:tap];
}

-(void)tapAction:(UITapGestureRecognizer *)sender {
    ///背景色动画
    CABasicAnimation * bgC = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    bgC.fromValue = (id)self.contentView.backgroundColor.CGColor;
    bgC.toValue = (id)[UIColor whiteColor].CGColor;
    bgC.duration = 0.2;
    bgC.timingFunction = [CAMediaTimingFunction functionWithName:kCAAnimationLinear];
    bgC.fillMode = kCAFillModeForwards;
    bgC.removedOnCompletion = YES;
    bgC.autoreverses = YES;
    [self.contentView.layer addAnimation:bgC forKey:@"ani"];
    
    [UIPasteboard generalPasteboard].string = ((DWLogModel *)self.model).absoluteLog;
}

#pragma mark --- override ---
-(void)setModel:(DWLogModel *)model {
    [super setModel:model];
    self.logLb.attributedText = model.logString;
    if (!self.just4Cal) {
        [self setBackgroundHighlight:model.highlighted];
    }
}

@end



@implementation DWLogViewController

#pragma mark --- life ---
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.searchContainer];
    CGFloat statusH = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGPoint ori = CGPointMake(0, statusH > 20 ? statusH : 0);
    CGRect frm = self.searchView.frame;
    frm.origin = ori;
    self.searchView.frame = frm;
    [self.searchContainer addSubview:self.searchView];
    [self.view addSubview:self.mainTab];
    if ([UIScrollView instancesRespondToSelector:NSSelectorFromString(@"setContentInsetAdjustmentBehavior:")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.mainTab performSelector:NSSelectorFromString(@"setContentInsetAdjustmentBehavior:") withObject:@(2)];
#pragma clang diagnostic pop
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    NSThread * logPoolThread = [[NSThread alloc] initWithTarget:self selector:@selector(configLogPoolTimer) object:nil];
    [logPoolThread start];
}

#pragma mark --- tool method ---

/**
 返回符合条件的结果数组

 @param condition 搜索条件
 @return 结果数组
 */
-(NSMutableArray *)searchIndexArrayFromCondition:(NSString *)condition {
    if (!condition.length) {
        return nil;
    }
    
    ///直接对比当前展示数据源是否符合条件，若符合，记录idx
    NSMutableArray * temp = @[].mutableCopy;
    [self.helper.dataSource enumerateObjectsUsingBlock:^(DWLogModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.absoluteLog.uppercaseString containsString:condition.uppercaseString]) {
            [temp addObject:@(idx)];
        }
    }];
    if (!temp.count) {
        return nil;
    }
    return temp;
}

/**
 按条件搜索日志

 @param condition 搜索条件
 */
-(void)searchCondition:(NSString *)condition {
    
    NSMutableArray * result = [self searchIndexArrayFromCondition:condition];
    self.searchIndexArray = result;
    
    if (!result) {///如果没有搜索结果时应清楚之前的搜索结果，注意不应重置searchView。
        [self clearSearchResultWithResetSearchView:NO];
    } else {///否则高亮搜索结果的第一项
        [self changeSearchIndex:0];
    }
}

/**
 改变当前高亮搜索项

 @param index 当前搜索控件处于的结果角标数
 */
-(void)changeSearchIndex:(NSUInteger)index {
    ///改变当前高亮状态
    /*
     需要考虑高亮状态的改变
     1.在searchIndexArray数组中寻找对应角标位置的列表idxP
     2.取消之前的高亮状态
     3.高亮当前应展示的搜索条目
     4.将当前应展示条目滚动至屏幕中央
     */
    
    if (index < self.searchIndexArray.count) {
        NSUInteger idx = [self.searchIndexArray[index] unsignedIntegerValue];
        if (idx < self.helper.dataSource.count) {
            BOOL needChange = self.highlightIndex != idx;
            if (needChange) {
                NSIndexPath * idxP = nil;
                ///如果之前存在高亮状态，则取消高亮状态
                if (self.highlightIndex >= 0 && self.highlightIndex < self.helper.dataSource.count) {
                    idxP = [NSIndexPath indexPathForRow:self.highlightIndex inSection:0];
                    [self changeCellHighlight:NO atIndexPath:idxP];
                }
                
                idxP = [NSIndexPath indexPathForRow:idx inSection:0];
                ///高亮当前搜索项目
                [self changeCellHighlight:YES atIndexPath:idxP];
                ///滚动至当前位置
                safeMainThreadCode([self.mainTab scrollToRowAtIndexPath:idxP atScrollPosition:UITableViewScrollPositionMiddle animated:YES]);
                ///记录当前位置
                self.highlightIndex = idx;
                self.highligthModel = [self.helper modelFromIndexPath:idxP];
            }
        }
    }
}

///清楚搜索结果，保持搜索控件不变
-(void)clearSearchResultWithResetSearchView:(BOOL)reset {
    
    /*
     清楚搜索结果，及相关标志状态
     1.取消高亮状态
     2.重置当前搜索位置
     3.重置结果角标数组
     4.重置搜索控件
     */
    if (self.highlightIndex < self.helper.dataSource.count) {
        DWlogCell * cell = [self.mainTab cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.highlightIndex inSection:0]];
        self.highligthModel.highlighted = NO;
        [cell setBackgroundHighlight:NO];
    }
    self.highlightIndex = -1;
    self.highligthModel = nil;
    self.searchIndexArray = nil;
    if (reset) {
        [self.searchView reset];
    }
}

///改变cell高亮状态
-(void)changeCellHighlight:(BOOL)highlight atIndexPath:(NSIndexPath *)idxP {
    
    /*
     考虑两种情况：
     1.目标cell当前正在显示，则直接改变cell高亮状态即可。
     2.目标cell不在显示区域，则改变model中标志位，再由展示时-setModel:触发高亮动画。
     */
    
    DWLogModel * m = (DWLogModel *)[self.helper modelFromIndexPath:idxP];
    m.highlighted = highlight;
    DWlogCell * cell = [self.mainTab cellForRowAtIndexPath:idxP];
    if (cell) {
        [cell setBackgroundHighlight:highlight];
    }
}

-(void)reloadTabIfNeeded {
    if (self.needModeChangeReloadTab) {
        [self reloadTabWithChangeMode:YES completion:^{
            self.needModeChangeReloadTab = NO;
            self.needDataSourceChangeReloadTab = NO;
        }];
    } else if (self.needDataSourceChangeReloadTab) {
        [self reloadTabWithChangeMode:NO completion:^{
            self.needDataSourceChangeReloadTab = NO;
        }];
    }
}

-(void)reloadTabWithChangeMode:(BOOL)changeMod completion:(dispatch_block_t)completion {
    /*
     刷新列表时应该考虑是否为过滤切换模式，如果不是在考虑是否为搜索模式，不同状态下有不同的交互模式
     1.过滤切换模式
     此模式下由于数据源已经切换完成，故此时刷新列表并滚动至列表末尾即可
     2.非搜索模式或无搜索结果
     此状态下无高亮显示的当前结果，故此时刷新列表并滚动至列表末尾即可
     3.为搜索模式且搜索结果仅有一个
     此时说明从无高亮状态进入有高亮状态，且高亮状态为列表末尾，故刷新列表后滚动至列表末尾并高亮
     4.为搜索模式且当前存在高亮状态
     此状态说明更新的条目为查找项，但当前展示即为更新前的高亮项目，此时刷新列表后不做列表滚动，保持当前高亮状态的查看
     */
    
    NSMutableArray * result = nil;
    ///搜索状态
    if (!changeMod && self.searchMode) {
        ///获取符合条件数组
        result = [self searchIndexArrayFromCondition:self.searchView.text];
        self.searchIndexArray = result;
        
        
        ///更新搜索控件结果数
        [self.searchView updateResultCount:result.count];
    }
    NSUInteger count = self.helper.dataSource.count;
    [self.helper reloadDataWithCompletion:^{
        ///根据搜索结果数区分三种状态
        if (result.count == 0) {///非搜索模式或无搜索结果
            ///如果当前有数据则滚动至列表底部，否则不滚动
            if (count > 0) {
                safeMainThreadCode([self.mainTab scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES]);
            }
        } else if (result.count == 1) {///为搜索模式且搜索结果仅有一个
            [self changeSearchIndex:0];
        } else {///为搜索模式且当前存在高亮状态
            ///Do nothing.
        }
        !completion?:completion();
    }];
}

#pragma mark --- logPoolMethod ---
-(void)configLogPoolTimer {
    @autoreleasepool {
        [[NSThread currentThread] setName:@"DWLogger"];
        NSRunLoop * r = [NSRunLoop currentRunLoop];
        NSTimer * timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(logPoolTimerAction:) userInfo:nil repeats:YES];
        [r addTimer:timer forMode:NSRunLoopCommonModes];
        [r run];
    }
}

-(void)logPoolTimerAction:(NSTimer *)timer {
    if ((self.needLogPoolReloadTab || self.loadedCount != self.helper.dataSource.count) && [DWLogView shareLogView].isShowing) {
        self.needLogPoolReloadTab = NO;
        self.loadedCount = self.helper.dataSource.count;
        [self reloadTabWithChangeMode:NO completion:nil];
    }
}

#pragma mark --- override ---
-(instancetype)init {
    if (self = [super init]) {
        self.highlightIndex = -1;
    }
    return self;
}

#pragma mark --- setter/getter ---
-(UITableView *)mainTab {
    if (!_mainTab) {
        CGFloat oriY = self.searchContainer.frame.size.height;
        _mainTab = [[UITableView alloc] initWithFrame:CGRectMake(0, oriY, self.view.bounds.size.width, self.view.bounds.size.height - oriY) style:UITableViewStylePlain];
        self.helper = [[DWTableViewHelper alloc] initWithTabV:_mainTab dataSource:self.dataArr];
        self.helper.useAutoRowHeight = YES;
        _mainTab.estimatedRowHeight = 0;
        _mainTab.scrollsToTop = NO;
        _mainTab.backgroundColor = [UIColor clearColor];
        _mainTab.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        _mainTab.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _mainTab;
}

-(NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

-(DWSearchView *)searchView {
    if (!_searchView) {
        _searchView = [[DWSearchView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0)];
        __weak typeof(self)weakSelf = self;
        _searchView.searchCallback = ^NSInteger(NSString *text) {
            weakSelf.searchMode = (text.length != 0);
            [weakSelf searchCondition:text];
            return weakSelf.searchIndexArray.count;
        };
        _searchView.stepperCallback = ^(NSInteger value) {
            [weakSelf changeSearchIndex:value];
        };
    }
    return _searchView;
}

-(UIView *)searchContainer {
    if (!_searchContainer) {
        CGFloat statusH = [UIApplication sharedApplication].statusBarFrame.size.height;
        _searchContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.searchView.bounds.size.width, self.searchView.bounds.size.height + (statusH > 20 ? statusH : 0))];
        _searchContainer.backgroundColor = self.searchView.backgroundColor;
    }
    return _searchContainer;
}

@end



static DWLogView * loggerView = nil;
@implementation DWLogView

#pragma mark --- interface method ---

+(void)enableUserInteraction {
    safeMainThreadBlock(^(){
        [DWLogView shareLogView].userInteractionEnabled = YES;
        if ([DWLogView shareLogView].isShowing) {
            ((DWFloatPotViewController *)[DWFloatPot sharePot].rootViewController).interactionBtn.selected = YES;
        }
    });
}

+(void)disableUserInteraction {
    safeMainThreadBlock(^(){
        [DWLogView shareLogView].userInteractionEnabled = NO;
        ((DWFloatPotViewController *)[DWFloatPot sharePot].rootViewController).interactionBtn.selected = NO;
    });
}

+(void)showPot {
    [DWFloatPot showPot];
}

+(void)hidePot {
    [DWFloatPot hidePot];
}

+(void)showLogView {
    safeMainThreadBlock(^(){
        [DWLogView shareLogView].hidden = NO;
        [UIView animateWithDuration:0.4 animations:^{
            [DWLogView shareLogView].alpha = 1;
        }];
        ((DWFloatPotViewController *)[DWFloatPot sharePot].rootViewController).logSwitch.selected = YES;
        ((DWFloatPotViewController *)[DWFloatPot sharePot].rootViewController).interactionBtn.selected = [DWLogView shareLogView].interactionEnabled;
        [((DWLogViewController *)[DWLogView shareLogView].rootViewController) reloadTabIfNeeded];
    });
}

+(void)hideLogView {
    safeMainThreadBlock(^(){
        [UIView animateWithDuration:0.4 animations:^{
            [DWLogView shareLogView].alpha = 0;
        } completion:^(BOOL finished) {
            [DWLogView shareLogView].hidden = YES;
        }];
        ((DWFloatPotViewController *)[DWFloatPot sharePot].rootViewController).logSwitch.selected = NO;
        ((DWFloatPotViewController *)[DWFloatPot sharePot].rootViewController).interactionBtn.selected = NO;
    });
}

+(void)configDefaultLogView {
    [DWLogView shareLogView];
    [DWLogView enableUserInteraction];
    [DWFloatPot sharePot];
}

+(NSMutableArray *)loggerContainer {
    DWLogViewController * vc = (DWLogViewController *)safeMainThreadGetValue([DWLogView shareLogView].rootViewController);
    return  vc.dataArr;
}

+(void)clearCurrentLog {
    ///清楚日志并清除相关标志位
    /*
     1.清除屏幕日志
     2.清除搜索结果
     3.清除过滤数据源
     4.刷新列表
     */
    DWLogViewController * vc = (DWLogViewController *)safeMainThreadGetValue([DWLogView shareLogView].rootViewController);
    [vc.dataArr removeAllObjects];
    vc.loadedCount = 0;
    [vc clearSearchResultWithResetSearchView:YES];
    [vc.filterLogArray removeAllObjects];
    [vc.helper reloadDataWithCompletion:nil];
}

+(void)updateLog:(DWLogModel *)logModel filter:(DWLoggerFilter)filter {
    ///更新日志操作
    /*
     更新日志需要考虑两个点，一种是过滤模式，一种是搜索模式。
     过滤模式改变时应该改变数据源，同时应清除搜索条件。
     搜索模式下更新时应注意高亮显示的刷新交互。
     */
    
    DWLogViewController * vc = safeMainThreadGetValue((DWLogViewController *)[DWLogView shareLogView].rootViewController);
    
    ///过滤模式改变则数据源应发生相应变化，此时应清除搜索条件并刷新列表（由于此时数据源发生变化故无需考虑数据源中增添元素的问题）
    if (vc.filterLogArrayNeedChange) {
        [vc clearSearchResultWithResetSearchView:YES];
        if (filter == DWLoggerIgnore) {
            NSMutableArray * tempArr = [self filterAllArr:vc.dataArr];
            vc.filterLogArray = tempArr;
            vc.helper.dataSource = tempArr;
        } else if (filter == DWLoggerAll) {
            vc.helper.dataSource = vc.dataArr;
            vc.filterLogArray = nil;
        } else {
            NSMutableArray * tempArr = [self filterDataArr:vc.dataArr filter:filter];
            vc.filterLogArray = tempArr;
            vc.helper.dataSource = tempArr;
        }
        
        ///视图未展示，此时不刷新列表，记录需要刷新列表需求
        if (![DWLogView shareLogView].isShowing) {
            vc.needModeChangeReloadTab = YES;
            vc.filterLogArrayNeedChange = NO;
            return;
        }
        
        [vc reloadTabWithChangeMode:YES completion:nil];
        vc.filterLogArrayNeedChange = NO;
        return;
    }
    
    
    ///非全部展示时以filterLogArray为数据源，此时符合条件才添加元素至数据源
    BOOL needInsert = YES;
    if (vc.filterLogArray) {
        if (logModel && filter & [DWLogManager shareLogManager].logFilter) {
            [vc.filterLogArray addObject:logModel];
        } else {
            needInsert = NO;
        }
    }
    
    ///数据源发生变化，插入列表并按需滚动
    if (needInsert) {
        ///记录需要插入状态并将idxP存入插入数组
        if (![DWLogView shareLogView].isShowing) {
            vc.needDataSourceChangeReloadTab = YES;
            return;
        }
        
        ///用标志位标识列表需要刷新，timer每0.5秒按需刷新一次列表来模拟缓冲池，是为了防止后一个刷新请求被前一个刷新请求抵消掉刷新时还会判断数据源个数是否与当前相同
        vc.needLogPoolReloadTab = YES;
    }
}

+(NSMutableArray *)filterDataArr:(NSArray <DWLogModel *>*)dataArr filter:(DWLoggerFilter)filter {
    return [[dataArr dw_FilteredArrayUsingFilter:^BOOL(DWLogModel * obj, NSUInteger idx, NSUInteger count, BOOL *stop) {
        return obj.filter & filter;
    }] mutableCopy];
}

+(NSMutableArray *)filterAllArr:(NSArray <DWLogModel *>*)allArr {
    return [[allArr dw_FilteredArrayUsingFilter:^BOOL(DWLogModel * obj, NSUInteger idx, NSUInteger count, BOOL *stop) {
        return obj.filter == DWLoggerAll;
    }] mutableCopy];
}

#pragma mark --- singleton ---
+(instancetype)shareLogView {
#ifndef DevEvn
    return nil;
#else
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        safeMainThreadBlock(^(){
            loggerView = [[DWLogView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            loggerView.windowLevel = UIWindowLevelAlert + 1;
            loggerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
            loggerView.hidden = NO;
            loggerView.alpha = 0;
            loggerView.userInteractionEnabled = NO;
            loggerView.rootViewController = [DWLogViewController new];
        });
    });
    return loggerView;
#endif
}

+(instancetype)allocWithZone:(struct _NSZone *)zone {
#ifndef DevEvn
    return nil;
#else
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loggerView = [super allocWithZone:zone];
    });
    return loggerView;
#endif
}

-(instancetype)copyWithZone:(struct _NSZone *)zone {
    return self;
}

-(instancetype)mutableCopyWithZone:(struct _NSZone *)zone {
    return self;
}

#pragma mark --- override ---
-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView * view = [super hitTest:point withEvent:event];
    DWLogViewController * logVC = (DWLogViewController *)self.rootViewController;
    if (view) {///当点击搜索框的textField之外时，应注意去除响应者并如果此时如果为非搜索状态应清楚搜索结果
        if ([view isEqual:self]) {///若果是window本身则无可响应者，即点击在窗口上，应释放第一响应者。
            [logVC.searchView endEditing:YES];
            if (!logVC.searchView.text.length) {
                logVC.searchMode = NO;
                if (logVC.searchIndexArray.count) {
                    [logVC clearSearchResultWithResetSearchView:YES];
                }
            }
            
        } else {///否则找到当前响应视图的是否在tableView上，如果在则释放搜索栏的响应者
            UIView * temp = view;
            while (temp.superview && temp.superview != logVC.view) {
                temp = temp.superview;
            }
            if ([temp isEqual:logVC.mainTab]) {
                [logVC.searchView endEditing:YES];
                if (!logVC.searchView.text.length) {
                    logVC.searchMode = NO;
                    if (logVC.searchIndexArray.count) {
                        [logVC clearSearchResultWithResetSearchView:YES];
                    }
                }
            }
        }
    }
    return view;
}

#pragma mark --- setter/getter ---
-(BOOL)isShowing {
    BOOL hidden = safeMainThreadGetValue([DWLogView shareLogView].hidden);
    CGFloat alpha = safeMainThreadGetValue([DWLogView shareLogView].alpha);
    return !hidden && alpha;
}

-(BOOL)interactionEnabled {
    return safeMainThreadGetValue(self.userInteractionEnabled);
}
@end



@implementation DWFloatPotViewController

-(void)viewDidLoad {
    self.width = self.view.bounds.size.width;
    self.height = self.view.bounds.size.height;
    CGFloat width = self.width;
    CGFloat height = self.height;
    CGRect switchBtnR = btnRectWithOrigin(width - BtnLength,height - BtnLength - 30);
    CGRect tempFrm = btnRectWithOrigin(width - BtnLength, switchBtnR.origin.y);
    
    self.containerView = [[UIView alloc] initWithFrame:switchBtnR];
    self.containerView.backgroundColor = [UIColor blackColor];
    self.containerView.layer.cornerRadius = BtnLength / 2.0;
    [self.view addSubview:self.containerView];
    
    self.modeBtn = normalBtn(image(@"log"), image(@"close"), self, @selector(modeBtnAction:), tempFrm);
    self.clearLogBtn = normalBtn(image(@"clear"), nil, self, @selector(clearBtnAction:), tempFrm);
    [self.clearLogBtn setBackgroundImage:image(@"destroy") forState:(UIControlStateHighlighted)];
    self.interactionBtn = normalBtn(image(@"forbid"), image(@"clickable"), self, @selector(interfaceBtnAction:), tempFrm);
    self.logSwitch = normalBtn(image(@"invisible"), image(@"visible"), self, @selector(logSwitchBtnAction:), tempFrm);
    self.saveBtn = normalBtn(image(@"local"), image(@"stop"), self, @selector(saveBtnAction:), tempFrm);
    self.switchBtn = normalBtn(image(@"menu"), nil, self, @selector(switchBtnAction:),switchBtnR);
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panBtnAction:)];
    pan.delegate = self;
    self.panGes = pan;
    [self.switchBtn addGestureRecognizer:pan];
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    longPress.delegate = self;
    self.longGes = longPress;
    [self.switchBtn addGestureRecognizer:longPress];
    
    if ([DWLogView shareLogView].isShowing) {
        self.logSwitch.selected = YES;
    }
    if ([DWLogView shareLogView].interactionEnabled) {
        self.interactionBtn.selected = YES;
    }
    for (UIView * v in self.itemsArr) {
        v.alpha = 0;
    }
}

#pragma mark --- btnAction ---
-(void)longPressAction:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    ///添加记号操作
    static int counter = 0;
    ///打印记号
    DWLog(@"DWLogger Marker %d",counter);
    counter++;
    
    ///背景色动画
    CABasicAnimation * bgC = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    bgC.fromValue = (id)[UIColor clearColor].CGColor;
    bgC.toValue = (id)[UIColor whiteColor].CGColor;
    bgC.duration = 0.2;
    bgC.timingFunction = [CAMediaTimingFunction functionWithName:kCAAnimationLinear];
    bgC.fillMode = kCAFillModeForwards;
    bgC.removedOnCompletion = YES;
    bgC.autoreverses = YES;
    [self.view.layer addAnimation:bgC forKey:@"ani"];
}

-(void)panBtnAction:(UIPanGestureRecognizer *)sender
{
    CGPoint p = [sender locationInView:self.view];
    
    ///矫正点至边框内
    if (p.x < BtnLength / 2.0) {
        p.x = BtnLength / 2.0;
    } else if (p.x > self.width - BtnLength / 2.0) {
        p.x = self.width - BtnLength / 2.0;
    }
    
    if (p.y < BtnLength / 2.0) {
        p.y = BtnLength / 2.0;
    } else if (p.y > self.height - BtnLength / 2.0) {
        p.y = self.height - BtnLength / 2.0;
    }
    
    self.switchBtn.center = p;
    self.containerView.center = p;
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self gotoSideAnimationFromPoint:p];
    }
}

-(void)gotoSideAnimationFromPoint:(CGPoint)p {
    CGFloat oriX = p.x;
    CGFloat tempX = 0;
    if (p.x < self.view.center.x) {
        p = CGPointMake(BtnLength / 2.0, p.y);
        tempX = 0;
    } else {
        p = CGPointMake(self.width - BtnLength / 2.0, p.y);
        tempX = self.width - BtnLength;
    }
    CGRect tempFrm = btnRectWithOrigin(tempX, p.y - BtnLength / 2.0);
    for (UIView * v in self.itemsArr) {
        v.frame = tempFrm;
    }
    CGFloat time = ABS(oriX - p.x) / SpeedScale;
    self.containerView.frame = self.switchBtn.frame;
    [UIView animateWithDuration:time animations:^{
        self.switchBtn.center = p;
        self.containerView.center = p;
    }];
}

-(void)switchBtnAction:(UIButton *)sender {
    if (sender.selected) {
        [UIView animateWithDuration:0.4 animations:^{
            sender.transform = CGAffineTransformIdentity;
        }];
        [self hideItems];
    } else {
        [UIView animateWithDuration:0.4 animations:^{
            sender.transform = CGAffineTransformMakeRotation(M_PI_4);
        }];
        [self showItems];
    }
    sender.selected = !sender.selected;
}

-(void)saveBtnAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [DWLogManager shareLogManager].saveLocalLog = NO;
    } else {
        [DWLogManager shareLogManager].saveLocalLog = YES;
    }
}

-(void)logSwitchBtnAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [DWLogView showLogView];
    } else {
        [DWLogView hideLogView];
    }
}

-(void)interfaceBtnAction:(UIButton *)sender
{
    if ([DWLogView shareLogView].isShowing) {
        sender.selected = !sender.selected;
        if (sender.selected) {
            [UIView animateWithDuration:0.25 animations:^{
                [DWLogView shareLogView].backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
            }];
            
            [DWLogView enableUserInteraction];
        } else {
            [UIView animateWithDuration:0.25 animations:^{
                [DWLogView shareLogView].backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
            }];
            [DWLogView disableUserInteraction];
        }
    }
}

-(void)clearBtnAction:(UIButton *)sender
{
    [DWLogView clearCurrentLog];
}

-(void)modeBtnAction:(UIButton *)sender
{
    if (!self.checkView.superview) {
        [self.view addSubview:self.checkView];
    }
    if (!sender.selected) {
        [self showCheckView];
    } else {
        [self hideCheckView];
    }
}

#pragma mark --- gesture delegate ---
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isEqual:self.panGes]) {
        return !self.switchBtn.selected;
    } else if ([gestureRecognizer isEqual:self.longGes]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark --- tool method ---
-(void)showItems {
    CGFloat x;
    CGRect frame = CGRectNull;
    CGFloat time = 0;
    CGFloat delta = 0;
    CGFloat length = 0;
    CGFloat factor = 0;
    if ([DWLogView shareLogView].isShowing) {
        self.interactionBtn.selected = [DWLogView shareLogView].interactionEnabled;
    } else {
        self.interactionBtn.selected = NO;
    }
    if (self.switchBtn.center.x > self.view.center.x) {
        x = self.width - BtnLength;
        delta = - (BtnLength + BtnSpacing);
        length = self.width;
        factor = -1;
    } else {
        x = 0;
        delta = (BtnLength + BtnSpacing);
        length = BtnLength;
        factor = 1;
    }
    for (UIView * v in self.itemsArr) {
        x += delta;
        frame = btnRectWithOrigin(x, self.switchBtn.center.y - BtnLength / 2.0);
        time = (length + x * factor) / SpeedScale;
        [UIView animateWithDuration:time delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            v.frame = frame;
            v.alpha = 1;
        } completion:nil];
    }
    CGFloat x1 = 0;
    CGFloat x2 = 0;
    if (self.switchBtn.center.x > self.view.center.x) {
        x1 = CGRectGetMaxX(self.containerView.frame);
        x2 = frame.origin.x;
    } else {
        x1 = CGRectGetMaxX(frame);
        x2 = CGRectGetMinX(self.containerView.frame);
    }
    [UIView animateWithDuration:time delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.containerView.frame = CGRectMake(x2, self.switchBtn.center.y - BtnLength / 2.0, ABS(x1 - x2), BtnLength);
    } completion:nil];
}

-(void)hideItems {
    CGRect frame;
    CGFloat x = 0;
    CGFloat time;
    CGFloat length;
    CGFloat factor;
    if (self.switchBtn.center.x > self.view.center.x) {
        length = self.width - BtnLength;
        factor = -1;
    } else {
        length = 0;
        factor = 1;
    }
    CGFloat totalTime = (self.itemsArr.lastObject.frame.origin.x * factor + length) / SpeedScale;
    frame = btnRectWithOrigin(length * factor * (-1), self.switchBtn.center.y - BtnLength / 2.0);
    [self hideCheckView];
    for (UIView * v in self.itemsArr) {
        x = v.frame.origin.x;
        time = (length + x * factor) / SpeedScale;
        [UIView animateWithDuration:time delay:totalTime - time options:UIViewAnimationOptionCurveLinear animations:^{
            v.frame = frame;
            v.alpha = 0;
        } completion:nil];
    }
    
    x = self.switchBtn.center.x - BtnLength / 2.0;
    [UIView animateWithDuration:totalTime delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.containerView.frame = CGRectMake(x, self.containerView.frame.origin.y, BtnLength, BtnLength);
    } completion:nil];
}

-(void)showCheckView {
    if (self.checkIsShowing) {
        return;
    }
    self.modeBtn.selected = YES;
    self.checkIsShowing = YES;
    BOOL upwards = YES;
    CGFloat y = self.modeBtn.frame.origin.y - 10 - CheckViewHeight;
    if (self.modeBtn.center.y < self.view.center.y) {
        upwards = NO;
        y = CGRectGetMaxY(self.modeBtn.frame) + 10;
    }
    CGFloat x = self.modeBtn.center.x - self.checkView.bounds.size.width / 2.0;
    CGFloat tempY = self.modeBtn.frame.origin.y - 10;
    if (!upwards) {
        tempY = y;
    }
    self.checkView.frame = CGRectMake(x, tempY, 100, 0);
    [UIView animateWithDuration:0.4 animations:^{
        self.checkView.frame = CGRectMake(x, y, 100, CheckViewHeight);
    }];
}

-(void)hideCheckView {
    if (!self.checkIsShowing) {
        return;
    }
    self.modeBtn.selected = NO;
    self.checkIsShowing = NO;
    CGFloat y = self.modeBtn.frame.origin.y - 10;
    CGFloat x = self.modeBtn.center.x - self.checkView.bounds.size.width / 2.0;
    BOOL upwards = YES;
    if (self.modeBtn.center.y < self.view.center.y) {
        y = CGRectGetMaxY(self.modeBtn.frame) + 10;
        upwards = NO;
    }
    [UIView animateWithDuration:0.4 animations:^{
        self.checkView.frame = CGRectMake(x, y, 100, 0);
    }];
    NSArray * select = self.checkView.currentSelected;
    DWLoggerFilter filter = DWLoggerIgnore;
    if ([select containsObject:@0]) {
        filter |= DWLoggerNormal;
    }
    if ([select containsObject:@1]) {
        filter |= DWLoggerInfo;
    }
    if ([select containsObject:@2]) {
        filter |= DWLoggerWarning;
    }
    if ([select containsObject:@3]) {
        filter |= DWLoggerError;
    }
    DWLogManager * logger = [DWLogManager shareLogManager];
    if (filter != logger.logFilter) {
        logger.logFilter = filter;
        DWLogViewController * logVC = (DWLogViewController *)[DWLogView shareLogView].rootViewController;
        logVC.filterLogArrayNeedChange = YES;
        [DWLogView updateLog:nil filter:filter];
    }
}

#pragma mark --- setter/getter ---
-(NSArray *)itemsArr {
    if (!_itemsArr) {
        _itemsArr = @[self.logSwitch,self.saveBtn,self.interactionBtn,self.clearLogBtn,self.modeBtn];
    }
    return _itemsArr;
}

-(DWCheckBoxView *)checkView {
    if (!_checkView) {
        NSMutableArray * defaultSelect = @[].mutableCopy;
        DWLogManager * logger = [DWLogManager shareLogManager];
        if (logger.logFilter & DWLoggerNormal) {
            [defaultSelect addObject:@0];
        }
        if (logger.logFilter & DWLoggerInfo) {
            [defaultSelect addObject:@1];
        }
        if (logger.logFilter & DWLoggerWarning) {
            [defaultSelect addObject:@2];
        }
        if (logger.logFilter & DWLoggerError) {
            [defaultSelect addObject:@3];
        }
        _checkView = [[DWCheckBoxView alloc] initWithFrame:CGRectMake(0, 0, 100, CheckViewHeight) multiSelect:YES titles:@[@"Normal",@"Info",@"Warning",@"Error"] defaultSelect:defaultSelect];
        _checkView.backgroundColor = [UIColor whiteColor];
        _checkView.layer.borderColor = [UIColor blackColor].CGColor;
        _checkView.layer.borderWidth = 1;
        _checkView.layer.cornerRadius = 10;
        _checkView.clipsToBounds = YES;
    }
    return _checkView;
}

#pragma mark --- convenience method ---
static inline UIButton * normalBtn(UIImage * normalImg,UIImage * selectImg,UIViewController * target,SEL selector,CGRect frame) {
    UIButton * button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [button setBackgroundImage:normalImg forState:(UIControlStateNormal)];
    if (selectImg) {
        [button setBackgroundImage:selectImg forState:(UIControlStateSelected)];
    }
    [button addTarget:target action:selector forControlEvents:(UIControlEventTouchUpInside)];
    [button setFrame:frame];
    [target.view addSubview:button];
    return button;
}

static inline UIImage * image(NSString * imageName) {
    UIImage * img = [UIImage imageNamed:[NSString stringWithFormat:@"DWLoggerBundle.bundle/%@",imageName]];
    return img;
}

static inline CGRect btnRectWithOrigin(CGFloat x,CGFloat y) {
    return (CGRect){CGPointMake(x, y),CGSizeMake(BtnLength, BtnLength)};
}

@end
