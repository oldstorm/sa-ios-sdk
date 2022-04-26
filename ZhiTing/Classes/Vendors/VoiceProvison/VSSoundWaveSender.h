//
//  VSSoundWaveSender.h
//  TestVoice
//
//  Created by vstarcam on 2020/2/24.
//  Copyright © 2020 godliu. All rights reserved.
//
#if !(TARGET_OS_SIMULATOR)
#import <Foundation/Foundation.h>
//#include "voiceEncoder.h"
#import "voiceEncoder.h"

NS_ASSUME_NONNULL_BEGIN

@interface VSSoundWaveSender : NSObject

- (BOOL)playWiFiMac:(NSString *)wifiMac password:(NSString *)password userId:(NSString *)userId playCount:(NSInteger)playCount;

- (BOOL) isStopped;

- (void)stopPlaying;
@end

NS_ASSUME_NONNULL_END
#endif
