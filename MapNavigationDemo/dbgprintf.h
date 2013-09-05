//
//  dbgprintf.h
//
//
//  Created by laudmankimo on 13-6-11.
//  Copyright (c) 2013年 laudmankimo. All rights reserved.
//

#ifndef dbgprintf_h
#define dbgprintf_h

#ifdef DEBUG
#define dbgprintf(format, ...) NSLog(@"[%s] file:%s, line:%04d, \t"format, __FUNCTION__, __FILE__, __LINE__, ##__VA_ARGS__);
#define LOG_FUNCTION NSLog(@"%s",__FUNCTION__);
#else
#define dbgprintf(format, ...)
#define LOG_FUNCTION
#endif

#endif
