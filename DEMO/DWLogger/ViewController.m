//
//  ViewController.m
//  DWLogger
//
//  Created by Wicky on 2017/9/26.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "ViewController.h"
#import "DWLogger.h"
#import "DWLogView.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor yellowColor];
    
    UIView * red = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    [self.view addSubview:red];
    red.backgroundColor = [UIColor redColor];
    
    DWLog(@"全局");
    DWLogNormal(@"normal");
    DWLogInfo(@"信息");
    DWLogWarning(@"警告");
    DWLogError(@"错误");
    NSLog(@"系统");
    
    DWLog(@"全局");
    DWLogNormal(@"normal");
    DWLogInfo(@"信息");
    DWLogWarning(@"警告");
    DWLogError(@"错误");
    NSLog(@"系统");
//
//    DWLog(@"全局");
//    DWLogNormal(@"normal");
//    DWLogInfo(@"信息");
//    DWLogWarning(@"警告");
//    DWLogError(@"错误");
//    NSLog(@"系统");
    
    
    
//
//    DWLog(@"全局");
//    DWLogNormal(@"normal");
//    DWLogInfo(@"信息");
//    DWLogWarning(@"警告");
//    DWLogError(@"错误");
//    NSLog(@"系统");
//    
//    DWLog(@"全局");
//    DWLogNormal(@"normal");
//    DWLogInfo(@"信息");
//    DWLogWarning(@"警告");
//    DWLogError(@"错误");
//    NSLog(@"系统");
    
    NSLog(@"%@",@[@"我",@"们",@"都是",@"好孩子"]);
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    abort();//此句可导致信号崩溃
//    [@[] objectAtIndex:1];//此句可导致异常崩溃
    
//    DWLog(@"111");
    
    static int i = 0;
    i++;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        DWLogNormal(@"as%d",i);
    });
    
//    for (int i = 0; i < 10000; i++) {
//        NSLog(@"%d",i);
//    }
    
//    DWLog(@"全局");
//    DWLogNormal(@"normal");
//    DWLogInfo(@"信息");
//    DWLogWarning(@"警告");
//    DWLogError(@"错误");
//    NSLog(@"系统");
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
