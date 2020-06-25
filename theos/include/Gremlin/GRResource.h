/*
 * Created by Youssef Francis on September 28th, 2012.
 */

@interface GRResource : NSLock

+ (void)acquireResources:(NSArray*)resources;
+ (void)relinquishResources:(NSArray*)resources;

@end
