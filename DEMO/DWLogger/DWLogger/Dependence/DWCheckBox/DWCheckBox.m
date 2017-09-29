//
//  DWChechBox.m
//  DWCheckBox
//
//  Created by Wicky on 2017/2/12.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "DWCheckBox.h"

#define __Select__Block__ \
if (self.selectedChangeBlock) {\
__weak typeof(self)weakSelf = self;\
self.selectedChangeBlock(weakSelf,[weakSelf currentSelected],self.identifier);\
}\

#define __set__property(value) \
_##value = value;\
self.manager.value = value;\


#pragma mark --- DWCheckBoxView ---
@interface DWCheckBoxView ()

///管理者
@property (nonatomic ,strong) DWCheckBoxManager * manager;

@property (nonatomic ,strong) DWCheckBoxLayout * layout;

@end

@implementation DWCheckBoxView
@synthesize selectedImage = _selectedImage;
@synthesize unSelectedImage = _unSelectedImage;
+(NSArray<UIView<DWCheckBoxCellProtocol> *> *)cellsFromTitles:(NSArray<NSString *> *)titles
{
    NSMutableArray * arr = [NSMutableArray array];
    [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DWCheckBoxDefaultCell * cell = [DWCheckBoxDefaultCell cellWithTitle:obj];
        [arr addObject:cell];
    }];
    return arr;
}

-(instancetype)initWithFrame:(CGRect)frame layout:(DWCheckBoxLayout *)layout manager:(DWCheckBoxManager *)manager multiSelect:(BOOL)multiSelect cells:(NSArray<UIView<DWCheckBoxCellProtocol>*> *)cells
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initValueWithMultiSelect:multiSelect cells:cells manager:manager layout:layout];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame multiSelect:(BOOL)multiSelect cells:(NSArray<UIView<DWCheckBoxCellProtocol>*> *)cells defaultSelect:(NSArray<NSNumber *> *)defaultSelect
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initValueWithMultiSelect:multiSelect cells:cells manager:[self getDefaultManagerWithCells:cells multiSelect:multiSelect defaultSelect:defaultSelect] layout:[DWCheckBoxDefaultLayout new]];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame layout:(DWCheckBoxLayout *)layout multiSelect:(BOOL)multiSelect cells:(NSArray<UIView<DWCheckBoxCellProtocol> *> *)cells defaultSelect:(NSArray<NSNumber *> *)defaultSelect
{
    return [self initWithFrame:frame layout:layout manager:[self getDefaultManagerWithCells:cells multiSelect:multiSelect defaultSelect:defaultSelect] multiSelect:multiSelect cells:cells];
}

-(instancetype)initWithFrame:(CGRect)frame multiSelect:(BOOL)multiSelect titles:(NSArray<NSString *> *)titles defaultSelect:(NSArray<NSNumber *> *)defaultSelect
{
    return [self initWithFrame:frame multiSelect:multiSelect cells:[DWCheckBoxView cellsFromTitles:titles] defaultSelect:defaultSelect];
}

-(instancetype)initWithFrame:(CGRect)frame layout:(DWCheckBoxLayout *)layout multiSelect:(BOOL)multiSelect titles:(NSArray<NSString *> *)titles defaultSelect:(NSArray<NSNumber *> *)defaultSelect
{
    NSArray * cells = [DWCheckBoxView cellsFromTitles:titles];
    return [self initWithFrame:frame layout:layout multiSelect:multiSelect cells:cells defaultSelect:defaultSelect];
}

-(void)selectAtIndex:(NSUInteger)idx
{
    [self.manager selectAtIndex:idx];
}

-(void)selectAll
{
    [self.manager selectAll];
}

-(void)deselectAtIndex:(NSUInteger)idx
{
    [self.manager deselectAtIndex:idx];
}

-(void)deselectAll
{
    [self.manager deselectAll];
}

#pragma mark --- Tool Method ---
-(DWCheckBoxManager *)getDefaultManagerWithCells:(NSArray <UIView<DWCheckBoxCellProtocol>*>*)cells
                                     multiSelect:(BOOL)multiSelect
                                   defaultSelect:(NSArray <NSNumber *>*)defaultSelect
{
    __weak typeof(self)weakSelf = self;
    DWCheckBoxManager * manager = [[DWCheckBoxManager alloc] initWithCountOfBoxes:cells.count multiSelect:multiSelect defaultSelect:defaultSelect selectedChangeBlock:^(DWCheckBoxManager * mgr,id currentSelect, NSString *identifier) {
        NSArray * arr = nil;
        if (currentSelect) {
            if (!weakSelf.multiSelect) {
                arr = @[currentSelect];
            }
            else
            {
                arr = currentSelect;
            }
        }
        [self handleCells:cells withArr:arr manager:mgr];
    }];
    return manager;
}

-(void)initValueWithMultiSelect:(BOOL)multiSelect
                          cells:(NSArray <UIView<DWCheckBoxCellProtocol>*>*)cells
                        manager:(DWCheckBoxManager *)manager
                         layout:(DWCheckBoxLayout *)layout
{
    _manager = manager;
    _layout = layout;
    _countOfBoxes = cells.count;
    _multiSelect = multiSelect;
    _cells = cells;
    [self handleCellsWithAction];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self.layout layoutCheckBoxView:self cells:self.cells];
    NSArray * arr = nil;
    arr = (!self.manager.currentSelected)?nil:_multiSelect?self.manager.currentSelected:@[self.manager.currentSelected];
    [self handleCells:self.cells withArr:arr manager:self.manager];
}

-(void)handleCells:(NSArray<UIView<DWCheckBoxCellProtocol>*> *)cells
           withArr:(NSArray *)arr
           manager:(DWCheckBoxManager *)mgr
{
    [cells enumerateObjectsUsingBlock:^(UIView<DWCheckBoxCellProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([arr containsObject:@(idx)]) {
            [obj cellBeSelected:YES withImage:mgr.selectedImage];
        }
        else
        {
            [obj cellBeSelected:NO withImage:mgr.unSelectedImage];
        }
    }];
}

-(void)handleCellsWithAction
{
    __weak typeof(self)weakSelf = self;
    [self.cells enumerateObjectsUsingBlock:^(UIView<DWCheckBoxCellProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.selectedBlock = ^(BOOL isSelect,UIView<DWCheckBoxCellProtocol> * view){
            NSUInteger idx = [weakSelf.cells indexOfObject:view];
            if (isSelect) {
                [weakSelf.manager deselectAtIndex:idx];
            }
            else
            {
                [weakSelf.manager selectAtIndex:idx];
            }
        };
    }];
}

#pragma mark --- setter/getter ---
-(void)setCountOfBoxes:(NSUInteger)countOfBoxes {
    __set__property(countOfBoxes)
}

-(void)setMultiSelect:(BOOL)multiSelect
{
    __set__property(multiSelect)
}

-(void)setSelectedImage:(UIImage *)selectedImage
{
    __set__property(selectedImage)
}

-(void)setUnSelectedImage:(UIImage *)unSelectedImage
{
    __set__property(unSelectedImage)
}

-(id)currentSelected
{
    return self.manager.currentSelected;
}

-(UIImage *)selectedImage
{
    if (!_selectedImage) {
        return self.manager.selectedImage;
    }
    return _selectedImage;
}

-(UIImage *)unSelectedImage
{
    if (!_unSelectedImage) {
        return self.manager.unSelectedImage;
    }
    return _unSelectedImage;
}

@end



#pragma mark --- DWCheckBoxLayout ---
@implementation DWCheckBoxLayout

-(void)layoutCheckBoxView:(UIView *)checkBoxView cells:(NSArray<id<DWCheckBoxCellProtocol>> *)cells
{
    NSLog(@"you should use subClass of DWCheckLayout and implement this method by yourself");
}

@end



#pragma mark --- DWCheckBoxDefaultLayout ---
@implementation DWCheckBoxDefaultLayout
-(void)layoutCheckBoxView:(UIView *)checkBoxView cells:(NSArray<UIView<DWCheckBoxCellProtocol>*> *)cells
{
    CGRect frame = checkBoxView.frame;
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    __block CGFloat originX = 0;
    __block CGFloat originY = 0;
    [cells enumerateObjectsUsingBlock:^(UIView<DWCheckBoxCellProtocol> * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ((originX + obj.bounds.size.width + 5) > width) {
            if (originX == 0) {
                CGRect objF = obj.frame;
                CGSize objS = objF.size;
                objS.width = width;
                objF.size = objS;
                obj.frame = objF;
            } else if ((originY + self.spacing + obj.frame.size.height) < height) {
                originX = 0;
                originY += self.spacing + obj.frame.size.height;
                
            }
            else
            {
                *stop = YES;
            }
        }
        if (!*stop) {
            CGPoint origin = CGPointMake(originX, originY);
            CGRect frame = obj.frame;
            frame.origin = origin;
            obj.frame = frame;
            [checkBoxView addSubview:obj];
            originX += obj.bounds.size.width + self.spacing;
        }
    }];
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.spacing = -1;
    }
    return self;
}

-(CGFloat)spacing
{
    if (_spacing == -1) {
        return 5;
    }
    return _spacing;
}

@end



#pragma mark --- DWCheckBoxDefaultCell ---
@implementation DWCheckBoxDefaultCell
@synthesize isSelected,selectedBlock;
+(instancetype)cellWithTitle:(NSString *)title
{
    DWCheckBoxDefaultCell * btn = [self buttonWithType:(UIButtonTypeCustom)];
    if (btn) {
        [btn setTitle:title forState:(UIControlStateNormal)];
    }
    return btn;
}
+(instancetype)buttonWithType:(UIButtonType)buttonType
{
    DWCheckBoxDefaultCell * btn = [super buttonWithType:buttonType];
    if (btn) {
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [btn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
        [btn addTarget:btn action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return btn;
}
-(void)buttonAction:(id)sender
{
    if (self.selectedBlock) {
        __weak typeof(self)weakSelf = self;
        self.selectedBlock(self.isSelected,weakSelf);
    }
}
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGFloat height = frame.size.height;
    height = height > 44?44:height;
    self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, frame.size.width - height);
    self.titleEdgeInsets = UIEdgeInsetsMake(0, height - 39, 0, 0);
}
-(void)cellBeSelected:(BOOL)selected withImage:(UIImage *)image
{
    self.isSelected = selected;
    [self setImage:image forState:(UIControlStateNormal)];
}

-(void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [super setTitle:title forState:state];
    [self sizeToFit];
}

-(void)sizeToFit
{
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    label.text = self.titleLabel.text;
    label.font = self.titleLabel.font;
    [label sizeToFit];
    CGRect frame = self.frame;
    CGSize size = CGSizeZero;
    size.height = label.frame.size.height;
    size.width = size.height + 5 + label.bounds.size.width;
    frame.size = size;
    self.frame = frame;
}
@end



#pragma mark --- DWCheckBoxManager ---
@interface DWCheckBoxManager ()

@property (nonatomic ,strong) NSMutableArray <NSNumber *>* selectedArr;

@property (nonatomic ,assign) NSUInteger lastSelected;

@end

@implementation DWCheckBoxManager

-(instancetype)initWithCountOfBoxes:(NSUInteger)countOfBoxes multiSelect:(BOOL)multiSelect defaultSelect:(NSArray <NSNumber *>*)defaultSelect selectedChangeBlock:(void (^)(DWCheckBoxManager *,id,NSString *))selechtChangeBlock
{
    self = [super init];
    if (self) {
        _countOfBoxes = countOfBoxes;
        _multiSelect = multiSelect;
        if (defaultSelect.count) {
            [defaultSelect enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self selectAtIndex:obj.unsignedIntegerValue];
            }];
        }
        if (selechtChangeBlock) {
            self.selectedChangeBlock = selechtChangeBlock;
        }
    }
    return self;
}

-(void)selectAtIndex:(NSUInteger)idx
{
    if (idx < self.countOfBoxes) {
        if (self.multiSelect) {///多选操作
            if ((![self.selectedArr containsObject:@(idx)]) && (self.selectedArr.count < self.countOfBoxes)) {
                [self.selectedArr addObject:@(idx)];
                __Select__Block__
            }
        } else {///单选操作
            if (self.selectedArr.count) {
                [self.selectedArr removeAllObjects];
            }
            [self.selectedArr addObject:@(idx)];
            __Select__Block__
        }
    }
}

-(void)deselectAtIndex:(NSUInteger)idx
{
    if (idx < self.countOfBoxes) {
        if ([self.selectedArr containsObject:@(idx)]) {
            [self.selectedArr removeObject:@(idx)];
            __Select__Block__
        }
    }
}

-(void)deselectAll
{
    [self.selectedArr removeAllObjects];
    __Select__Block__
}

-(void)selectAll
{
    if (self.multiSelect) {
        if (self.selectedArr.count != self.countOfBoxes) {
            [self.selectedArr removeAllObjects];
            for (int i = 0; i < self.countOfBoxes; i++) {
                [self.selectedArr addObject:@(i)];
            }
            __Select__Block__
        }
        
    } else {
        if (!self.selectedArr.count) {
            [self.selectedArr addObject:@(1)];
            __Select__Block__
        }
    }
}

-(id)currentSelected
{
    if (self.multiSelect) {
        return [self.selectedArr sortedArrayUsingSelector:@selector(compare:)];
    } else {
        if (self.selectedArr.count) {
            return self.selectedArr.firstObject;
        }
        return nil;
    }
}

-(NSMutableArray<NSNumber *> *)selectedArr
{
    if (!_selectedArr) {
        _selectedArr = [NSMutableArray array];
    }
    return _selectedArr;
}

-(void)setMultiSelect:(BOOL)multiSelect
{
    _multiSelect = multiSelect;
    if (!multiSelect && self.selectedArr.count > 1) {
        NSNumber * lastSelected = self.selectedArr.lastObject;
        [self.selectedArr removeAllObjects];
        [self.selectedArr addObject:lastSelected];
    }
    __Select__Block__
}

-(void)setCountOfBoxes:(NSUInteger)countOfBoxes
{
    _countOfBoxes = countOfBoxes;
    if (countOfBoxes < self.selectedArr.count) {
        NSMutableArray * arr = [NSMutableArray array];
        for (int i = 0; i < countOfBoxes; i++) {
            [arr addObject:self.selectedArr[i]];
        }
        self.selectedArr = arr;
        __Select__Block__
    }
}

-(NSString *)identifier
{
    if (!_identifier) {
        return @"defaultCheckBox";
    }
    return _identifier;
}

-(UIImage *)selectedImage
{
    if (!_selectedImage) {
        return [UIImage imageNamed:[NSString stringWithFormat:@"DWCheckBoxBundle.bundle/%@",self.multiSelect?@"checkBoxSelected":@"radioSelected"]];
    }
    return _selectedImage;
}

-(UIImage *)unSelectedImage
{
    if (!_unSelectedImage) {
        return [UIImage imageNamed:[NSString stringWithFormat:@"DWCheckBoxBundle.bundle/%@",self.multiSelect?@"checkBoxUnselected":@"radioUnselected"]];
    }
    return _unSelectedImage;
}

@end
