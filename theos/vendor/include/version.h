/**
 * CoreFoundation Version Header
 *
 * by HASHBANG Productions <http://hbang.ws>
 * Public Domain
 *
 * 2.0		478.23
 * 2.1		478.26
 * 2.2		478.29
 * 3.0		478.47
 * 3.1		478.52
 * 3.2		478.61
 * 4.0		550.32
 * 4.1		550.38
 * 4.2		550.52
 * 4.3		550.58
 * 5.0		675.00
 * 5.1		690.10
 * 6.x		793.00
 * 7.0		847.20
 * 7.0.3	847.21
 * 7.1		847.26
 * 8.0		1140.10
 * 8.1		1141.14
 * 8.2		1142.16
 * 8.3		1144.17
 * 8.4		1145.15
 * 9.0		1240.1
 */

/**
 * iOS 2.0 - 4.2 are defined in CoreFoundation/CFBase.h. The format prior to
 * 4.0 is kCFCoreFoundationVersionNumber_iPhoneOS_X_Y. 4.0 and newer have the
 * format kCFCoreFoundationVersionNumber_iOS_X_Y.
 */

#import <CoreFoundation/CFBase.h>

/**
 * The weird thing about those #defines is that some newer ones don't exist in
 * newer SDKs. Let's define version numbers all the way up to the latest.
 */

#ifndef kCFCoreFoundationVersionNumber_iOS_4_3
#define kCFCoreFoundationVersionNumber_iOS_4_3 550.58
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_5_0
#define kCFCoreFoundationVersionNumber_iOS_5_0 675.00
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_5_1
#define kCFCoreFoundationVersionNumber_iOS_5_1 690.10
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_6_0
#define kCFCoreFoundationVersionNumber_iOS_6_0 793.00
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_6_1
#define kCFCoreFoundationVersionNumber_iOS_6_1 793.00
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_7_0
#define kCFCoreFoundationVersionNumber_iOS_7_0 847.20
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_7_0_3
#define kCFCoreFoundationVersionNumber_iOS_7_0_3 847.21
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_7_1
#define kCFCoreFoundationVersionNumber_iOS_7_1 847.26
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_8_0
#define kCFCoreFoundationVersionNumber_iOS_8_0 1140.10
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_8_1
#define kCFCoreFoundationVersionNumber_iOS_8_1 1141.14
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_8_2
#define kCFCoreFoundationVersionNumber_iOS_8_2 1142.16
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_8_3
#define kCFCoreFoundationVersionNumber_iOS_8_3 1144.17
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_8_4
#define kCFCoreFoundationVersionNumber_iOS_8_4 1145.15
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_9_0
#define kCFCoreFoundationVersionNumber_iOS_9_0 1240.1
#endif

#ifndef kCFCoreFoundationVersionNumber10_10
#define kCFCoreFoundationVersionNumber10_10 1151.16
#endif

/**
 * Let's also define some useful functions to check which firmware the user is
 * on. (Note that feature detection is highly recommended where possible)
 */

#define IS_IOS_OR_OLDER(version) (kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber_##version)
#define IS_IOS_OR_NEWER(version) (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_##version)
#define IS_IOS_BETWEEN(start, end) (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_##start && kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber_##end)

/**
 * And let's make equivalent macros for OS X so it doesn't feel lonely.
 */

#define IS_OSX_OR_OLDER (kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber##version)
#define IS_OSX_OR_NEWER(version) (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber##version)
#define IS_OSX_BETWEEN(start, end) (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber##start && kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber##end)
