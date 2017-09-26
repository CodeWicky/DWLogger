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
    self.view.backgroundColor = [UIColor redColor];
    NSLog(@"%@",[DWLogManager shareLogManager].logFilePath);
    [DWLogManager shareLogManager].particularLog = YES;
//    [DWLogManager shareLogManager].disableLogger = YES;
    [DWLogManager shareLogManager].autoBackUp = YES;
    DWLog(@"hello %@",@"Jack");
    DWLog(@"second Log");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
