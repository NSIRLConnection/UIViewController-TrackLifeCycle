//
//  NSILog.m
//  NSIHackySack
//
//  Created by Michael Yau on 12/8/15.
//  Copyright © 2015 Michael Yau. All rights reserved.
//

#import "NSILog.h"

#if DEBUG
void NSILog(NSString *format, ...) {
    if (format == nil) {
        printf("nil\n");
        return;
    }
    va_list argList;
    va_start(argList, format);
    NSString *s = [[NSString alloc] initWithFormat:format arguments:argList];
    printf("%s\n", [[s stringByReplacingOccurrencesOfString:@"%%" withString:@"%%%%"] UTF8String]);
    va_end(argList);
}
#endif
