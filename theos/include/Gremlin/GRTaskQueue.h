/*
 * Created by Youssef Francis on September 25th, 2012.
 */

#import "GRTask.h"
#import "GRImporterProtocol.h"

typedef void (^GRImportCompletionBlock)(BOOL, NSError*);

@interface GRTaskQueue : NSOperationQueue

@property (retain) NSMutableDictionary* resources;

+ (GRTaskQueue*)sharedQueue;
- (void)addTask:(GRTask*)task 
       importer:(Class<GRImporter>)Importer
      resources:(NSArray*)resources
completionBlock:(GRImportCompletionBlock)complete;

@end
