//
//  TSSAgent.h
//  nitoTV 4
//
//  Created by Kevin Bradley on 1/28/17.
//  Copyright © 2017 Kevin Bradley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSSAgent : NSObject

+ (void)img4TicketForURL:(NSString *)url withECID:(NSString *)ecid completion:(void(^)(NSDictionary *manifest))block;
+ (NSDictionary *)tssDictFromManifest:(NSDictionary *)manifest withChipID:(NSString *)ecid;
+ (NSDictionary *)img4TicketForURL:(NSString *)url withECID:(NSString *)ecid;
@end
