//
//  NSTimer+ProxyTarget.m
//  
//
//  Created by Michael Yau on 5/26/16.
//  Copyright © 2016 Michael Yau. All rights reserved.
//

#import "NSTimer+ProxyTarget.h"
#import "TimerProxyTarget.h"

@implementation NSTimer (ProxyTarget)

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval weakTarget:(id)target selector:(SEL)selector userInfo:(id)userInfo repeats:(BOOL)repeats {
    return [self scheduledTimerWithTimeInterval:timeInterval
                                         target:[[TimerProxyTarget alloc] initWithTarget:target
                                                                                 selector:selector]
                                       selector:@selector(timerDidFire:)
                                       userInfo:userInfo
                                        repeats:repeats];
}

@end
