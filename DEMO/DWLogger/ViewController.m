//
//  ViewController.m
//  DWLogger
//
//  Created by Wicky on 2017/9/26.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "ViewController.h"
#import "DWLogger.h"
#import "UIDevice+DWDeviceUtils.h"
#import <CoreText/CoreText.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView * red = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    [self.view addSubview:red];
    red.backgroundColor = [UIColor redColor];
    
    DWLogInfo(@"1.%@", @"asd");
    DWLogError(@"2.errer %d",2);
    DWLogWarning(@"3.%d - %d",1,2);
    DWLogWarning(@"8765432");
    [DWLogManager printLoggerMainPath];
    
    DWLogInfo(@"%@",[UIDevice dw_DevelopSDKVersion]);
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSLog(@"%@",infoDictionary);
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    static BOOL flag = NO;
    if (!flag) {
        [DWLogManager removeAllCrashBackUp];
        flag = YES;
        return;
    }

    
    
//    abort();
    [@[] objectAtIndex:1];
//    void *pc = malloc(1024);
//    free(pc);
//    free(pc);
//
//    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)CFBridgingRetain([[NSAttributedString alloc] initWithString:@"a"]));
//    CFRelease(frameSetter);
//    CFRelease(frameSetter);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
