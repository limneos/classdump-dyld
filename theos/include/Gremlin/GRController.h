/*
 * Created by Youssef Francis on September 26th, 2012.
 */

#import "GRServer.h"

@interface GRController : NSObject <GRServerImportDelegate>

@property (assign) BOOL hasActiveTasks;

+ (GRController*)sharedController;
- (void)processImportRequests;

@end
