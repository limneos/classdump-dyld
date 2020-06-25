/*
 * Created by Youssef Francis on November 4th, 2012.
 */

@protocol GRManifestListenerDelegate
- (void)manifestTasksUpdated:(NSArray*)tasks;
- (void)manifestServerReset;
@end

@interface GRManifestListener : NSObject
+ (BOOL)startListening:(id<GRManifestListenerDelegate>)delegate;
+ (void)stopListening;
@end

