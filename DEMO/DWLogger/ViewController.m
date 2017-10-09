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
    
//    [DWLogManager shareLogManager].particularLog = YES;
////    [DWLogManager shareLogManager].disableLogger = YES;
//    [DWLogManager shareLogManager].autoBackUp = YES;
//    [DWLogManager shareLogManager].logFilter = DWLoggerIgnore;
//    DWLogWithFilter(DWLoggerAll,@"hello %@",@"Jack");
    
//    DWLog(@"second Log %@ %d",@"as",1);
    
//    UIImageView * image = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
//    image.userInteractionEnabled = NO;
//    [self.view addSubview:image];
//
//    UIButton * button = [UIButton buttonWithType:(UIButtonTypeCustom)];
//    [button setFrame:image.bounds];
//    button.backgroundColor = [UIColor greenColor];
//    [image addSubview:button];
//    [button addTarget: self action:@selector(aBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
//    DWLog(@"equal = %d",[self.view.viewController isEqual:self]);
//    NSLog(@"asd %d",543);
//    DWLog(@"asd");
//    DWLogInfo(@"1.%@", @"asd");
//    DWLogError(@"2.errer %d",2);
//    DWLogWarning(@"3.%d - %d",1,2);
//    DWLogWarning(@"8765432");
//    DWLogInfo(@"%@",[UIApplication sharedApplication].windows);
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        DWLogWarning(@"- - -");
//    });
    [DWLogManager printLoggerMainPath];
    
    DWLogInfo(@"%@",[UIDevice dw_DevelopSDKVersion]);
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    DWLogInfo(@"%@",infoDictionary);
    // app名称
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    DWLogInfo(@"app_Name = %@",[UIDevice dw_MobileOperator]);
    
    // app版本
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    DWLogInfo(@"app_Version = %@",[UIDevice dw_ProjectVersion]);
    // app build版本
    DWLogInfo(@"app_build = %@",[UIDevice dw_ProjectBuildNo]);
    
    
    //手机序列号
    NSString* identifierNumber = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    NSLog(@"手机序列号: %@",[UIDevice dw_DeviceUUID]);
    //手机别名： 用户定义的名称
    NSString* userPhoneName = [[UIDevice currentDevice] name];
    NSLog(@"手机别名: %@", userPhoneName);
    //设备名称
    NSString* deviceName = [[UIDevice currentDevice] systemName];
    NSLog(@"设备名称: %@",deviceName );
    //手机系统版本
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    NSLog(@"手机系统版本: %@", phoneVersion);
    //手机型号
    NSString* phoneModel = [[UIDevice currentDevice] model];
    NSLog(@"手机型号: %@",[UIDevice dw_DeviceModel]);
    //地方型号  （国际化区域名称）
    NSString* localPhoneModel = [[UIDevice currentDevice] localizedModel];
    NSLog(@"国际化区域名称: %@",localPhoneModel );
    
    // 当前应用名称
    NSString *appCurName = [infoDictionary objectForKey:kCFBundleVersionKey];
    NSLog(@"当前应用名称：%@",appCurName);
    // 当前应用软件版本  比如：1.0.1
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSLog(@"当前应用软件版本:%@",appCurVersion);
    // 当前应用版本号码   int类型
    NSString *appCurVersionNum = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSLog(@"当前应用版本号码：%@",appCurVersionNum);
    

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
