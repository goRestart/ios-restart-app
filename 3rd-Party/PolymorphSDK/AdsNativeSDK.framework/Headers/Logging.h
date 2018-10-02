//
//  Logging.h
//  AdsNative-iOS-SDK
//
//  Created by Arvind Bharadwaj on 21/09/15.
//  Copyright (c) 2015 AdsNative. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ADSNATIVE_DEBUG_MODE               1

extern NSString * const kClearErrorLogFormatWithAdUnitID;
extern NSString * const kWarmingUpErrorLogFormatWithAdUnitID;

// Lower = finer-grained logs.
typedef enum
{
    LogLevelAll        = 0,
    LogLevelTrace      = 10,
    LogLevelDebug      = 20,
    LogLevelInfo       = 30,
    LogLevelWarn       = 40,
    LogLevelError      = 50,
    LogLevelFatal      = 60,
    LogLevelOff        = 70
} LogLevel;

LogLevel LogGetLevel(void);
void LogSetLevel(LogLevel level);
void _LogTrace(NSString *format, ...);
void _LogDebug(NSString *format, ...);
void _LogInfo(NSString *format, ...);
void _LogWarn(NSString *format, ...);
void _LogError(NSString *format, ...);
void _LogFatal(NSString *format, ...);

#if ADSNATIVE_DEBUG_MODE && !SPECS

#define LogTrace(...) _LogTrace(__VA_ARGS__)
#define LogDebug(...) _LogDebug(__VA_ARGS__)
#define LogInfo(...) _LogInfo(__VA_ARGS__)
#define LogWarn(...) _LogWarn(__VA_ARGS__)
#define LogError(...) _LogError(__VA_ARGS__)
#define LogFatal(...) _LogFatal(__VA_ARGS__)

#else

#define LogTrace(...) {}
#define LogDebug(...) {}
#define LogInfo(...) {}
#define LogWarn(...) {}
#define LogError(...) {}
#define LogFatal(...) {}

#endif
