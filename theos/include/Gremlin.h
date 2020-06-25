/*
 * Created by Youssef Francis on September 25th, 2012.
 */

#import "GRDestination.h"

@protocol GremlinListener <NSObject>
- (void)gremlinImportWasSuccessful:(NSDictionary*)info;
- (void)gremlinImport:(NSDictionary*)info didFailWithError:(NSError*)error;
@end

@interface Gremlin : NSObject
+ (BOOL)haveGremlin;
+ (BOOL)importFiles:(NSArray*)files;
+ (BOOL)importFileAtPath:(NSString*)path;
+ (BOOL)importFileWithInfo:(NSDictionary*)info;
+ (BOOL)registerNotifications:(id<GremlinListener>)listener;

+ (NSArray*)allAvailableDestinations;
+ (NSArray*)availableDestinationsForFile:(NSString*)path;
+ (GRDestination*)defaultDestinationForFile:(NSString*)path;

+ (NSArray*)getHistory;
@end
