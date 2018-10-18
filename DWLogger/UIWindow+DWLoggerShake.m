//
//  UIWindow+DWLoggerShake.m
//  DWLogger
//
//  Created by Wicky on 2018/10/18.
//  Copyright © 2018年 Wicky. All rights reserved.
//

#import "UIWindow+DWLoggerShake.h"
#import "DWLogManager.h"

@implementation UIWindow (DWLoggerShake)
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DWLoggerDeviceShakeNotification object:event];
    }
}
@end
