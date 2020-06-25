//
//  GAPluginsDestination.h
//  GremlinApp
//
//  Created by Youssef Francis on 10/9/12.
//  Copyright (c) 2012 CocoaNuts. All rights reserved.
//

//#import <Foundation/Foundation.h>

@interface GRDestination : NSObject

@property (retain) NSBundle* bundle;
@property (retain) NSString* rank;
@property (retain) NSArray* resources;
@property (retain) NSString* name;

+ (GRDestination*)destinationForBundle:(NSBundle*)bundle rank:(NSString*)rank;

@end
