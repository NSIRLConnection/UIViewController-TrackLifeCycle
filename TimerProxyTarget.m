//
//  TimerProxyTarget.m
//  
//
//  Created by Michael Yau on 5/26/16.
//  Copyright © 2016 Michael Yau. All rights reserved.
//

#import "TimerProxyTarget.h"

@interface TimerProxyTarget ()

@property (nonatomic, weak) id target;
@property (nonatomic) SEL selector;

@end

@implementation TimerProxyTarget

- (instancetype)initWithTarget:(id)target selector:(SEL)selector {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _target = target;
    _selector = selector;
    
    return self;
}

- (id)init {
    return [self initWithTarget:nil selector:nil];
}


- (void)timerDidFire:(NSTimer *)timer {
    id strongTarget = self.target;
    if (strongTarget) {
        [strongTarget performSelectorOnMainThread:self.selector withObject:nil waitUntilDone:NO];
    }
    else {
        [timer invalidate];
    }
}

@end
