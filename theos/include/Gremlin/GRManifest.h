/*
 * Created by Youssef Francis on October 1st, 2012.
 */

#import "GRTask.h"

@interface GRManifest : NSObject

+ (void)addTask:(GRTask*)task;
+ (void)removeTask:(GRTask*)task
			status:(BOOL)status
			 error:(NSError*)error;

+ (NSArray*)recoveredTasks;

@end
