//
//  TimerProxyTarget.h
//  
//
//  Created by Michael Yau on 5/26/16.
//  Copyright © 2016 Michael Yau. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimerProxyTarget : NSObject

- (instancetype)initWithTarget:(id)target selector:(SEL)selector;

- (void)timerDidFire:(NSTimer *)timer;

@end
