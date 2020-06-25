/*
 * Created by Youssef Francis on September 26th, 2012.
 */

#import "GRDestination.h"

@interface GRPluginScanner : NSObject

+ (NSArray*)allAvailableDestinations;
+ (NSArray*)availableDestinationsForFile:(NSString*)path;
+ (GRDestination*)defaultDestinationForFile:(NSString*)path;

@end
