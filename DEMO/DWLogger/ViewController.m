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
#import "UIView+DWViewUtils.h"
#import "UIDevice+DWDeviceUtils.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    
    DWLogInfo(@"1.%@", @"asd");
    DWLogError(@"2.errer %d",2);
    DWLogWarning(@"3.%d - %d",1,2);
    DWLogWarning(@"8765432");
    [DWLogManager printLoggerMainPath];
    
    DWLogInfo(@"%@",[UIDevice dw_DevelopSDKVersion]);
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSLog(@"%@",infoDictionary);
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
