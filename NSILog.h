//
//  NSILog.h
//  NSIHackySack
//
//  Created by Michael Yau on 12/8/15.
//  Copyright © 2015 Michael Yau. All rights reserved.
//

#import <Foundation/Foundation.h>

#if DEBUG
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu-zero-variadic-macro-arguments"
extern void NSILog(NSString *format, ...);
#define SLog(fmt, ...) NSILog(fmt, ##__VA_ARGS__);
#define LLog(fmt, ...) NSILog((@"[Line: %d] %s: " fmt), __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__);
#pragma clang diagnostic pop
#else
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu-zero-variadic-macro-arguments"
#define SLog(fmt, ...)
#define LLog(fmt, ...)
#pragma clang diagnostic pop
#endif
