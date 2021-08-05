//
//  ESPTouchHandler.m
//  EsptouchTest
//
//  Created by iMac on 2021/6/16.
//

#import "ESPTouchHandler.h"


@implementation ESPTouchHandler


- (instancetype)init
{
    self = [super init];
    if (self) {
        self._condition = [[NSCondition alloc] init];
    }
    return self;
}




- (void)executeSmartConfig:(NSString *)ssid bssid:(NSString *)bssid password:(NSString *)pwd taskCount:(int)taskCount broadcast:(BOOL)broadcast delegate:(EspTouchDelegateImplement *)delegate {
    
    NSLog(@"ESPHandler do confirm action...");
    dispatch_queue_t  queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSLog(@"ESPHandler do the execute work...");
        // execute the task
        NSArray *esptouchResultArray = [self executeForResultsWithSsid:ssid bssid:bssid password:pwd taskCount:taskCount broadcast:broadcast delegate:delegate];
        // show the result to the user in UI Main Thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            ESPTouchResult *firstResult = [esptouchResultArray objectAtIndex:0];
            // check whether the task is cancelled and no results received
            if (!firstResult.isCancelled)
            {
                NSMutableString *mutableStr = [[NSMutableString alloc]init];
                NSUInteger count = 0;
                // max results to be displayed, if it is more than maxDisplayCount,
                // just show the count of redundant ones
                const int maxDisplayCount = 5;
                if ([firstResult isSuc]) {
                    for (int i = 0; i < [esptouchResultArray count]; ++i) {
                        ESPTouchResult *resultInArray = [esptouchResultArray objectAtIndex:i];
                        NSString *resultStr = [NSString stringWithFormat:@"Bssid: %@, Address: %@\n", resultInArray.bssid, resultInArray.getAddressString];
                        [mutableStr appendString:resultStr];
                        if (++count >= maxDisplayCount) {
                            break;
                        }
                    }
                    
                    if (count < [esptouchResultArray count]) {
                        [mutableStr appendString:NSLocalizedString(@"EspTouch-more-results-message", nil)];
                    }
                    
                    NSLog(mutableStr);
                } else {
                    NSLog(@"nothing happens");
                }
            }
            
        });
    });

}

- (NSArray *) executeForResultsWithSsid:(NSString *)apSsid bssid:(NSString *)apBssid password:(NSString *)apPwd taskCount:(int)taskCount broadcast:(BOOL)broadcast delegate:(EspTouchDelegateImplement *)delegate
{
    [self._condition lock];
    self._esptouchTask = [[ESPTouchTask alloc]initWithApSsid:apSsid andApBssid:apBssid andApPwd:apPwd];
    // set delegate
    [self._esptouchTask setEsptouchDelegate:delegate];
    [self._esptouchTask setPackageBroadcast:YES];
    [self._condition unlock];
//    ESPTouchResult *ESPTR = self._esptouchTask.executeForResult;
    NSArray * esptouchResults = [self._esptouchTask executeForResults:taskCount];
    NSLog(@"ESPHandler executeForResult() result is: %@",esptouchResults);
    return esptouchResults;
}

- (void) cancel
{
    [self._condition lock];
    if (self._esptouchTask != nil)
    {
        [self._esptouchTask interrupt];
    }
    [self._condition unlock];
}


@end
