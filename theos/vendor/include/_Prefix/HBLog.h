#include <CoreFoundation/CFLogUtilities.h>

#ifdef __DEBUG__
	#define HB_LOG_FORMAT(color) CFSTR("\e[1;3" #color "m[%s] \e[m\e[0;3" #color "m%s:%d\e[m \e[0;30;4" #color "m%s:\e[m %@")
#else
	#define HB_LOG_FORMAT(color) CFSTR("[%s: %s:%d] %s: %@")
#endif

#define HB_LOG_INTERNAL(color, level, type, ...) CFLog(level, HB_LOG_FORMAT(color), THEOS_INSTANCE_NAME, __BASE_FILE__, __LINE__, type, (__bridge CFStringRef)[NSString stringWithFormat:__VA_ARGS__]);

#ifdef __DEBUG__
	#define HBLogDebug(...) HB_LOG_INTERNAL(6, kCFLogLevelNotice, "DEBUG", __VA_ARGS__)
#else
	#define HBLogDebug(...)
#endif

#define HBLogInfo(...) HB_LOG_INTERNAL(2, kCFLogLevelNotice, "INFO", __VA_ARGS__)
#define HBLogWarn(...) HB_LOG_INTERNAL(3, kCFLogLevelWarning, "WARN", __VA_ARGS__)
#define HBLogError(...) HB_LOG_INTERNAL(1, kCFLogLevelError, "ERROR", __VA_ARGS__)
