//
//  DWSearchView.m
//  DWLogger
//
//  Created by Wicky on 2018/2/13.
//  Copyright © 2018年 Wicky. All rights reserved.
//

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

#define Margin (5)

@interface DWCountTextField : UITextField

@property (nonatomic ,assign) NSInteger value;

@property (nonatomic ,strong) UILabel * countLabel;

@end

@implementation DWCountTextField

///计算对应value计数label应展示宽度
-(CGFloat)widthForValue:(NSInteger)value {
    if (self.text.length == 0 || self.value < 0) {
        return 0;
    }
    NSString * stringValue = [NSString stringWithFormat:@"%ld",(long)value];
    safeMainThreadSetValue(self.countLabel.text, stringValue);
    CGSize size = [self.countLabel sizeThatFits:CGSizeMake(MAXFLOAT, 30)];
    ///如果有clearButton时不加间隔，否则加间隔
    CGFloat delta = Margin;
    if (self.clearButtonMode == UITextFieldViewModeAlways) {
        delta = 0;
    } else if (self.clearButtonMode == UITextFieldViewModeWhileEditing && self.isEditing && self.text.length) {
        delta = 0;
    } else if (self.clearButtonMode == UITextFieldViewModeUnlessEditing && !self.isEditing && self.text.length) {
        delta = 0;
    }
    return ceil(size.width) + delta;
}

#pragma mark --- override ---
-(void)layoutSubviews {
    [super layoutSubviews];
    
    ///计算计数标签尺寸
    CGRect frame = CGRectZero;
    frame.size.height = self.frame.size.height;
    frame.size.width = [self widthForValue:self.value];
    if (self.isEditing) {
        frame.origin.x = CGRectGetMaxX([self editingRectForBounds:self.bounds]);
    } else {
        frame.origin.x = CGRectGetMaxX([self textRectForBounds:self.bounds]);
    }
    self.countLabel.frame = frame;
}

///返回正文区域尺寸，去掉计数label宽度
-(CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect rect = [super textRectForBounds:bounds];
    rect.size.width -= [self widthForValue:self.value];
    return rect;
}

-(CGRect)textRectForBounds:(CGRect)bounds {
    CGRect rect = [super textRectForBounds:bounds];
    rect.size.width -= [self widthForValue:self.value];
    return rect;
}

///获取焦点时默认清除value
-(BOOL)becomeFirstResponder {
    self.value = -1;
    return [super becomeFirstResponder];
}

#pragma mark --- setter/getter ---
-(UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [UILabel new];
        _countLabel.font = [UIFont systemFontOfSize:12];
        _countLabel.textColor = [UIColor lightGrayColor];
        [self addSubview:_countLabel];
    }
    return _countLabel;
}

///赋值时重绘
-(void)setValue:(NSInteger)value {
    _value = value;
    safeMainThreadCode([self setNeedsLayout]);
}

@end


@interface DWSearchView ()

@property (nonatomic ,strong) UIStepper * stepper;

@property (nonatomic ,strong) UIButton * commitBtn;

@property (nonatomic ,strong) DWCountTextField * txtF;

@property (nonatomic ,assign) BOOL needReframe;

@property (nonatomic ,assign ,readwrite) NSInteger value;

@end

@implementation DWSearchView

#pragma mark --- interface method ---
-(void)reset {
    self.value = -1;
    safeMainThreadBlock(^(){
        self.stepper.value = 0;
        self.stepper.maximumValue = 0;
        self.txtF.text = nil;
    });
    self.txtF.value = 0;
}

-(void)updateResultCount:(NSInteger)value {
    safeMainThreadBlock(^(){
        if (value > 1) {
            self.stepper.maximumValue = value - 1;
        } else {
            self.stepper.maximumValue = 0;
        }
        self.txtF.value = value;
    });
}

#pragma mark --- tool method ---
-(void)setupUI {
    self.backgroundColor = [UIColor colorWithRed:193.0 / 255 green:193.0 / 255 blue:196.0 / 255 alpha:1];
    ///Stepper
    _stepper = [[UIStepper alloc] initWithFrame:CGRectMake(0, 0, 94, 30)];
    [self addSubview:_stepper];
    _stepper.tintColor = [UIColor lightGrayColor];
    [_stepper setDecrementImage:image(@"previous") forState:(UIControlStateNormal)];
    [_stepper setIncrementImage:image(@"next") forState:(UIControlStateNormal)];
    _stepper.wraps = YES;
    _stepper.backgroundColor = [UIColor whiteColor];
    [_stepper addTarget:self action:@selector(valueChangedAction:) forControlEvents:UIControlEventValueChanged];
    _stepper.layer.cornerRadius = 4;
    _stepper.value = 50;
    
    ///Button
    _commitBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self addSubview:_commitBtn];
    [_commitBtn setTitle:@"搜索" forState:(UIControlStateNormal)];
    [_commitBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    [_commitBtn setFrame:CGRectMake(0, 0, 46, 30)];
    _commitBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_commitBtn addTarget:self action:@selector(commitBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
    _commitBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _commitBtn.layer.borderWidth = 1;
    _commitBtn.layer.cornerRadius = 4;
    _commitBtn.backgroundColor = [UIColor whiteColor];
    
    ///TextField
    _txtF = [[DWCountTextField alloc] init];
    _txtF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self addSubview:_txtF];
    _txtF.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _txtF.layer.borderWidth = 1;
    _txtF.layer.cornerRadius = 4;
    _txtF.backgroundColor = [UIColor whiteColor];
    
    ///Reframe
    self.needReframe = YES;
}

#pragma mark --- Action ---
-(void)valueChangedAction:(UIStepper *)sender {
    NSInteger value = (NSInteger)floor(sender.value);
    if (self.value != value) {
        self.value = value;
        if (self.stepperCallback) {
            self.stepperCallback(value);
        }
    }
}

-(void)commitBtnAction:(UIButton *)sender {
    if (self.searchCallback) {
        NSInteger resultCount = self.searchCallback(self.txtF.text);
        self.value = 0;
        self.stepper.value = 0;
        if (resultCount > 1) {
            self.stepper.maximumValue = resultCount - 1;
        } else {
            self.stepper.maximumValue = 0;
        }
        self.txtF.value = resultCount;
    }
}

#pragma mark --- tool method ---
-(void)limitRect:(CGRect *)frame {
    static int minWidth = Margin * 4 + 94 + 46 + 100;
    static int minHeight = Margin * 2 + 30;
    if (frame->size.width < minWidth) {
        frame->size.width = minWidth;
    }
    if (frame->size.height < minHeight) {
        frame->size.height = minHeight;
    }
}

#pragma mark --- override ---
-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

-(void)setFrame:(CGRect)frame {
    [self limitRect:&frame];
    if (CGRectEqualToRect(frame, self.frame)) {
        return;
    }
    [super setFrame:frame];
    self.needReframe = YES;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    if (!self.needReframe) {
        return;
    }
    CGRect frame = self.frame;
    CGPoint center = CGPointZero;
    center.y = floor(frame.size.height / 2);
    center.x = floor(frame.size.width - Margin - _stepper.frame.size.width / 2);
    _stepper.center = center;
    
    center.x = floor(frame.size.width - Margin * 2 - _stepper.frame.size.width - _commitBtn.frame.size.width / 2);
    _commitBtn.center = center;
    
    _txtF.frame = CGRectMake(0, 0, frame.size.width - Margin * 4 - _stepper.frame.size.width - _commitBtn.frame.size.width, 30);
    center.x = floor(Margin + _txtF.frame.size.width / 2);
    _txtF.center = center;
    
    self.needReframe = NO;
}

-(BOOL)isFirstResponder {
    return self.txtF.isFirstResponder;
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView * view = [super hitTest:point withEvent:event];
    if (!view) {
        [self endEditing:YES];
    } else if (![view isKindOfClass:[UIButton class]] || ![view.superview isEqual:self.txtF]) {
        [self endEditing:YES];
    }
    return view;
}

#pragma mark --- tool func ---
static inline UIImage * image(NSString * imageName) {
    UIImage * img = [UIImage imageNamed:[NSString stringWithFormat:@"DWLoggerBundle.bundle/%@",imageName]];
    return img;
}

#pragma mark --- setter/getter ---
-(NSString *)text {
    return self.txtF.text;
}

@end
