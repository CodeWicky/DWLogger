//
//  DWLogView.m
//  DWLogger
//
//  Created by Wicky on 2017/9/27.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "DWLogView.h"
#import "AppDelegate.h"
#import "DWLogger.h"
#import "DWCheckBox.h"
#import "DWOperationCancelFlag.h"

#define BtnLength 44
#define BtnSpacing 20
#define SpeedScale 400

@interface DWFloatPotViewController : UIViewController

@property (nonatomic ,assign) CGFloat width;

@property (nonatomic ,assign) CGFloat height;

@property (nonatomic ,strong) UIButton * switchBtn;

@property (nonatomic ,strong) UIButton * logSwitch;

@property (nonatomic ,strong) UIButton * interactionBtn;

@property (nonatomic ,strong) UIButton * clearLogBtn;

@property (nonatomic ,strong) UIButton * modeBtn;

@property (nonatomic ,assign) BOOL disableClick;

@property (nonatomic ,strong) UIPanGestureRecognizer * panGes;

@property (nonatomic ,strong) NSArray <UIView *>* itemsArr;

@property (nonatomic ,strong) DWCheckBoxView * checkView;

@property (nonatomic ,assign) BOOL checkIsShowing;

@end

@implementation DWFloatPotViewController

-(void)viewDidLoad {
    self.width = self.view.bounds.size.width;
    self.height = self.view.bounds.size.height;
    CGFloat width = self.width;
    CGFloat height = self.height;
    CGRect switchBtnR = btnRectWithOrigin(width - BtnLength,height - BtnLength - 30);
    CGRect tempFrm = btnRectWithOrigin(width - BtnLength, switchBtnR.origin.y);
    
    self.modeBtn = normalBtn(image(@"log"), image(@"close"), self, @selector(modeBtnAction:), tempFrm);
    self.clearLogBtn = normalBtn(image(@"clear"), nil, self, @selector(clearBtnAction:), tempFrm);
    [self.clearLogBtn setBackgroundImage:image(@"destroy") forState:(UIControlStateHighlighted)];
    self.interactionBtn = normalBtn(image(@"forbid"), image(@"clickable"), self, @selector(interfaceBtnAction:), tempFrm);
    self.logSwitch = normalBtn(image(@"invisible"), image(@"visible"), self, @selector(logSwitchBtnAction:), tempFrm);
    self.switchBtn = normalBtn(image(@"menu"), nil, self, @selector(switchBtnAction:),switchBtnR);
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panBtnAction:)];
    self.panGes = pan;
    [self.switchBtn addGestureRecognizer:pan];
    
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
-(void)panBtnAction:(UIPanGestureRecognizer *)sender
{
    CGPoint p = [sender locationInView:self.view];
    if (p.x > BtnLength / 2.0 && p.y > BtnLength / 2.0 && self.width - p.x > BtnLength / 2.0 && self.height - p.y > BtnLength / 2.0) {
        self.switchBtn.center = p;
        if (sender.state == UIGestureRecognizerStateEnded) {
            [self gotoSideAnimationFromPoint:p];
        }
    }
}

-(void)gotoSideAnimationFromPoint:(CGPoint)p {
    CGFloat oriX = p.x;
    CGFloat tempX = self.width;
    if (p.x < self.view.center.x) {
        p = CGPointMake(BtnLength / 2.0, p.y);
        tempX = -BtnLength;
    } else {
        p = CGPointMake(self.width - BtnLength / 2.0, p.y);
    }
    CGRect tempFrm = btnRectWithOrigin(tempX, p.y - BtnLength / 2.0);
    for (UIView * v in self.itemsArr) {
        v.frame = tempFrm;
    }
    CGFloat time = ABS(oriX - p.x) / SpeedScale;
    [UIView animateWithDuration:time animations:^{
        self.switchBtn.center = p;
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
    self.panGes.enabled = sender.selected;
    sender.selected = !sender.selected;
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
            [DWLogView enableUserInteraction];
        } else {
            [DWLogView disableUserInteraction];
        }
    }
}

-(void)clearBtnAction:(UIButton *)sender
{
    [DWLogManager clearCurrentLog];
    [DWLogView updateLog];
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

#pragma mark --- tool method ---
-(void)showItems {
    CGFloat x;
    CGRect frame;
    CGFloat time;
    CGFloat delta;
    CGFloat length;
    CGFloat factor;
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
}

-(void)showCheckView {
    if (self.checkIsShowing) {
        return;
    }
    self.modeBtn.selected = YES;
    self.checkIsShowing = YES;
    BOOL upwards = YES;
    CGFloat y = self.modeBtn.frame.origin.y - 10 - 80;
    if (self.modeBtn.center.y < self.view.center.y) {
        upwards = NO;
        y = self.modeBtn.frame.origin.y + self.modeBtn.frame.size.height + 10;
    }
    CGFloat x = self.modeBtn.center.x - self.checkView.bounds.size.width / 2.0;
    CGFloat tempY = self.modeBtn.frame.origin.y - 10;
    if (!upwards) {
        tempY = y;
    }
    self.checkView.frame = CGRectMake(x, tempY, 100, 0);
    [UIView animateWithDuration:0.4 animations:^{
        self.checkView.frame = CGRectMake(x, y, 100, 80);
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
        y = self.modeBtn.frame.origin.y + self.modeBtn.frame.size.height + 10;
        upwards = NO;
    }
    [UIView animateWithDuration:0.4 animations:^{
        self.checkView.frame = CGRectMake(x, y, 100, 0);
    }];
    NSArray * select = self.checkView.currentSelected;
    DWLoggerFilter filter = DWLoggerIgnore;
    if ([select containsObject:@0]) {
        filter |= DWLoggerInfo;
    }
    if ([select containsObject:@1]) {
        filter |= DWLoggerWarning;
    }
    if ([select containsObject:@2]) {
        filter |= DWLoggerError;
    }
    [DWLogManager shareLogManager].logFilter = filter;
}

#pragma mark --- setter/getter ---
-(NSArray *)itemsArr {
    if (!_itemsArr) {
        _itemsArr = @[self.logSwitch,self.interactionBtn,self.clearLogBtn,self.modeBtn];
    }
    return _itemsArr;
}

-(DWCheckBoxView *)checkView {
    if (!_checkView) {
        NSMutableArray * defaultSelect = @[].mutableCopy;
        DWLogManager * logger = [DWLogManager shareLogManager];
        if (logger.logFilter & DWLoggerInfo) {
            [defaultSelect addObject:@0];
        }
        if (logger.logFilter & DWLoggerWarning) {
            [defaultSelect addObject:@1];
        }
        if (logger.logFilter & DWLoggerError) {
            [defaultSelect addObject:@2];
        }
        _checkView = [[DWCheckBoxView alloc] initWithFrame:CGRectMake(0, 0, 100, 80) multiSelect:YES titles:@[@"Info",@"Warning",@"Error"] defaultSelect:defaultSelect];
        _checkView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
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



static DWFloatPot * pot = nil;
@implementation DWFloatPot

#pragma mark --- interface method ---
+(instancetype)sharePot {
#ifndef DevEvn
    return nil;
#else
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        pot = [[DWFloatPot alloc] initWithFrame:delegate.window.bounds];
        pot.windowLevel = UIWindowLevelNormal + 2;
        pot.backgroundColor = [UIColor clearColor];
        pot.hidden = NO;
        pot.rootViewController = [DWFloatPotViewController new];
    });
    return pot;
#endif
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

#pragma mark --- overwrite ---
-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView * view = [super hitTest:point withEvent:event];
    if ([view isEqual:self.rootViewController.view]) {
        DWFloatPotViewController * vc = (DWFloatPotViewController *)[DWFloatPot sharePot].rootViewController;
        [vc hideCheckView];
        return nil;
    }
    return view;
}
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

@end

@implementation DWlogCell

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
}

-(void)setModel:(DWLogModel *)model {
    [super setModel:model];
    self.logLb.attributedText = model.logString;
}

@end



@interface DWLogViewController : UIViewController

@property (nonatomic ,strong) UITableView * mainTab;

@property (nonatomic ,strong) DWTableViewHelper * helper;

@property (nonatomic ,strong) NSMutableArray * dataArr;

@end

@implementation DWLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.mainTab];
}

-(UITableView *)mainTab {
    if (!_mainTab) {
        _mainTab = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStylePlain)];
        self.helper = [[DWTableViewHelper alloc] initWithTabV:_mainTab dataSource:self.dataArr];
        self.helper.useAutoRowHeight = YES;
        _mainTab.backgroundColor = [UIColor clearColor];
        _mainTab.showsVerticalScrollIndicator = NO;
        _mainTab.showsHorizontalScrollIndicator = NO;
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

@end



static DWLogView * logger = nil;
@implementation DWLogView

#pragma mark --- interface method ---
+(instancetype)shareLogView {
#ifndef DevEvn
    return nil;
#else
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        logger = [[DWLogView alloc] initWithFrame:delegate.window.bounds];
        logger.windowLevel = UIWindowLevelNormal + 1;
        logger.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        logger.hidden = NO;
        logger.alpha = 0;
        logger.userInteractionEnabled = NO;
        logger.rootViewController = [DWLogViewController new];
    });
    return logger;
#endif
}

+(void)enableUserInteraction {
    [DWLogView shareLogView].userInteractionEnabled = YES;
    if ([DWLogView shareLogView].isShowing) {
        ((DWFloatPotViewController *)[DWFloatPot sharePot].rootViewController).interactionBtn.selected = YES;
    }
}

+(void)disableUserInteraction {
    [DWLogView shareLogView].userInteractionEnabled = NO;
    ((DWFloatPotViewController *)[DWFloatPot sharePot].rootViewController).interactionBtn.selected = NO;
}

+(void)showLogView {
    [DWLogView shareLogView].hidden = NO;
    [UIView animateWithDuration:0.4 animations:^{
        [DWLogView shareLogView].alpha = 1;
    }];
    ((DWFloatPotViewController *)[DWFloatPot sharePot].rootViewController).logSwitch.selected = YES;
    ((DWFloatPotViewController *)[DWFloatPot sharePot].rootViewController).interactionBtn.selected = [DWLogView shareLogView].interactionEnabled;
}

+(void)hideLogView {
    [UIView animateWithDuration:0.4 animations:^{
        [DWLogView shareLogView].alpha = 0;
    } completion:^(BOOL finished) {
        [DWLogView shareLogView].hidden = YES;
    }];
    ((DWFloatPotViewController *)[DWFloatPot sharePot].rootViewController).logSwitch.selected = NO;
    ((DWFloatPotViewController *)[DWFloatPot sharePot].rootViewController).interactionBtn.selected = NO;
}

+(void)configDefaultLogView {
    [DWLogView shareLogView];
    [DWLogView enableUserInteraction];
    [DWFloatPot sharePot];
}

+(NSMutableArray *)loggerContainer {
    return ((DWLogViewController *)[DWLogView shareLogView].rootViewController).dataArr;
}

+(void)updateLog {
    DWLogViewController * vc = (DWLogViewController *)[DWLogView shareLogView].rootViewController;
    UITableView * tab = vc.mainTab;
    NSUInteger count = vc.dataArr.count;
    [vc.helper reloadDataWithCompletion:^{
        if (count == 0) {
            return;
        }
        NSIndexPath * indexP = [NSIndexPath indexPathForRow:count - 1 inSection:0];
        [tab scrollToRowAtIndexPath:indexP atScrollPosition:(UITableViewScrollPositionBottom) animated:NO];
    }];
}

#pragma mark --- singleton ---
+(instancetype)allocWithZone:(struct _NSZone *)zone {
#ifndef DevEvn
    return nil;
#else
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logger = [super allocWithZone:zone];
    });
    return logger;
#endif
}

-(instancetype)copyWithZone:(struct _NSZone *)zone {
    return self;
}

-(instancetype)mutableCopyWithZone:(struct _NSZone *)zone {
    return self;
}

#pragma mark --- setter/getter ---
-(BOOL)isShowing {
    return ![DWLogView shareLogView].hidden && [DWLogView shareLogView].alpha;
}

-(BOOL)interactionEnabled {
    return self.userInteractionEnabled;
}
@end
