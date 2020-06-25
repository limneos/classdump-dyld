/*
 * Created by Youssef Francis on October 10th, 2012.
 */

#import <Gremlin/GRDestination.h>
#import "GRImporterProtocol.h"

@interface GRDestination (Import)

- (Class<GRImporter>)importerClass;

@end
