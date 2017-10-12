//
//  ViewController.m
//  DWLogger
//
//  Created by Wicky on 2017/9/26.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "ViewController.h"
#import "DWLogger.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView * red = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    [self.view addSubview:red];
    red.backgroundColor = [UIColor redColor];
    
    DWLog(@"全局");
    DWLogNormal(@"普通");
    DWLogInfo(@"信息");
    DWLogWarning(@"警告");
    DWLogError(@"错误");
    NSLog(@"系统");
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    abort();//此句可导致信号崩溃
    [@[] objectAtIndex:1];//此句可导致异常崩溃
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
