#if TARGET_OS_IPHONE
@interface NSDistributedNotificationCenter : NSNotificationCenter

@end
#else
#include_next <Foundation/NSDistributedNotificationCenter.h>
#endif
