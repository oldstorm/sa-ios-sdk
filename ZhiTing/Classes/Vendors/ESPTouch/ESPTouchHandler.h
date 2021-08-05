//
//  ESPTouchHandler.h
//  EsptouchTest
//
//  Created by iMac on 2021/6/15.
//
#import <UIKit/UIKit.h>
#import "ESPTouchTask.h"
#import "ESPTouchResult.h"
#import "ESP_NetUtil.h"
#import "ESPTouchDelegate.h"
#import "ESPAES.h"



@interface EspTouchDelegateImplement : NSObject<ESPTouchDelegate>

@end



@implementation EspTouchDelegateImplement

/// 置网结果回调
/// @param result 结果
-(void) onEsptouchResultAddedWithResult: (ESPTouchResult *) result
{
    NSLog(@"EspTouchDelegateImpl onEsptouchResultAddedWithResult bssid: %@", result.bssid);
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
    NSString *message = [NSString stringWithFormat:@"%@ %@" , result.bssid, NSLocalizedString(@"EspTouch-result-one", nil)];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"deviceConfigResult" object:message];
}

@end



@interface ESPTouchHandler: NSObject
@property (nonatomic, strong) NSCondition* _condition;
@property (nonatomic, weak) EspTouchDelegateImplement *_esptouchDelegate;
@property (atomic, strong) ESPTouchTask *_esptouchTask;

/// 执行SmartConfig置网方法
/// @param ssid       WiFi名称
/// @param bssid     MAC地址
/// @param pwd          WiFi密码
/// @param taskCount   任务数量
/// @param broadcast    是否广播
/// @param delegate      结果回调代理
- (void)executeSmartConfig:(NSString *)ssid bssid:(NSString *)bssid password:(NSString *)pwd taskCount:(int)taskCount broadcast:(BOOL)broadcast delegate:(EspTouchDelegateImplement *)delegate;
@end

