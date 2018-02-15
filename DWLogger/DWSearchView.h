//
//  DWSearchView.h
//  DWLogger
//
//  Created by Wicky on 2018/2/13.
//  Copyright © 2018年 Wicky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWSearchView : UIView

///当前数值
@property (nonatomic ,assign ,readonly) NSInteger value;

///搜索框文本
@property (nonatomic ,copy) NSString * text;

///stepper改变数值回调
@property (nonatomic ,copy) void(^stepperCallback)(NSInteger value);

///搜索按钮点击回调
@property (nonatomic ,copy) NSInteger(^searchCallback)(NSString * text);

-(void)reset;

-(void)updateResultCount:(NSInteger)count;

@end
