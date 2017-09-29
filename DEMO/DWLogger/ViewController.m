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
#import "AppDelegate.h"
#import "DWCheckBox.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    
    DWLog(@"%@",[DWLogManager shareLogManager].logFilePath);
    NSArray * arr = @[];
    NSObject * o = arr[1];
    
//    [DWLogManager shareLogManager].particularLog = YES;
////    [DWLogManager shareLogManager].disableLogger = YES;
//    [DWLogManager shareLogManager].autoBackUp = YES;
//    [DWLogManager shareLogManager].logFilter = DWLoggerIgnore;
//    DWLogWithFilter(DWLoggerAll,@"hello %@",@"Jack");
    
//    DWLog(@"second Log %@ %d",@"as",1);
//    DWCheckBoxView * checkBox = [[DWCheckBoxView alloc] initWithFrame:CGRectMake(0, 0, 100, 80) multiSelect:YES titles:@[@"Info",@"Warning",@"Error"] defaultSelect:nil];
//    [self.view addSubview:checkBox];
//    checkBox.backgroundColor = [UIColor yellowColor];
    
//    UIImageView * image = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
//    image.userInteractionEnabled = NO;
//    [self.view addSubview:image];
//
//    UIButton * button = [UIButton buttonWithType:(UIButtonTypeCustom)];
//    [button setFrame:image.bounds];
//    button.backgroundColor = [UIColor greenColor];
//    [image addSubview:button];
//    [button addTarget: self action:@selector(aBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
    
    
    
    DWLog(@"asd %d",543);
    DWLog(@"asd");
    DWLogInfo(@"1.%@", @"asd");
    DWLogError(@"2.errer %d",2);
    DWLogWarning(@"3.%d - %d",1,2);
    DWLogInfo(@"%@",[UIApplication sharedApplication].windows);
    [DWLogManager printCallStackSymbols];
}

-(void)aBtnAction:(UIButton *)sender
{
    DWLog(@"click");
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {    
    DWLogInfo(@"1.%@", @"asd");
    DWLogWarning(@"3.%d - %d",1,2);
    DWLogError(@"2.errer %d",2);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
