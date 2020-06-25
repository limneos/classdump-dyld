/*
 * Created by Youssef Francis on September 25th,  2012.
 */

#import "GRTask.h"

@protocol GRServerImportDelegate <NSObject>
- (void)importTask:(GRTask*)task;         
@end

@interface GRServer : NSObject

@property (assign) id<GRServerImportDelegate> importDelegate;

+ (GRServer*)sharedServer;
- (void)signalImportCompleteForTask:(GRTask*)task
                             status:(BOOL)status
                              error:(NSError*)error;
- (BOOL)run;

@end
